#!/usr/bin/env bash
# Simple/secure MySQL DB backup to AWS/S3

################################################################################
# Script configuration

# Where `mysqldump` should write the local DB dump to
CFG_LOCAL_DUMP_DIR="/tmp"
################################################################################

set -o pipefail

NOW=$(date +%Y%m%d_%H%M%S)

fatal_error () {
    MESSAGE=$1
    DB_DUMP_PATH=$2

    echo "ERROR: $MESSAGE"

    # Cleanup local DB dump if specified
    if [ ! -z "$DB_DUMP_PATH" ]; then
        rm -f "$DB_DUMP_PATH"

        if [ $? -ne 0 ]; then
            echo "ERROR: failed cleaning up DB dump file, please delete this file manually with: \"shred -fu $DB_DUMP_PATH\""
        fi
    fi

    exit 1
}

# System checks
REQUIRED_COMMANDS=(
    "aws"
    "gzip"
    "mysqldump"
    "shred"
    "zcat"
)

for REQUIRED_COMMAND in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v $REQUIRED_COMMAND > /dev/null 2>&1; then
        fatal_error "$REQUIRED_COMMAND is not installed"
    fi
done

# Arg parsing
if [ $# -ne 2 ]; then
    echo "Usage: $(basename $0) <DB defaults file> <S3 bucket & prefix>"
    exit 1
fi

DB_DEFAULTS_PATH=$1
S3_BUCKET_PATH=$2

if [ ! -f "$DB_DEFAULTS_PATH" ]; then
    fatal_error "DB defaults file does not exist: $DB_DEFAULTS_PATH"
fi

DB_DEFAULTS_FILE=$(basename "$DB_DEFAULTS_PATH")
DB_NAME=$(echo "$DB_DEFAULTS_FILE" | sed -e 's/\.cnf$//')
if [ "${DB_NAME}.cnf" != "$DB_DEFAULTS_FILE" ]; then
    fatal_error "Failed resolving DB name from DB defaults filename"
fi

DB_DUMP_NAME="mysql.${DB_NAME}.${NOW}.sql.gz"
DB_LOCAL_DUMP_PATH="$CFG_LOCAL_DUMP_DIR/$DB_DUMP_NAME"

# Dump DB to filesystem
echo -n "[$(date)]: Dumping DB to $DB_LOCAL_DUMP_PATH: "
touch "$DB_LOCAL_DUMP_PATH"
if [ $? -ne 0 ]; then
    fatal_error "Failed touching DB dump file"
fi

chmod 600 "$DB_LOCAL_DUMP_PATH"
if [ $? -ne 0 ]; then
    fatal_error "Failed chmoding DB dump file" "$DB_LOCAL_DUMP_PATH"
fi

mysqldump --defaults-file="$DB_DEFAULTS_PATH" "$DB_NAME" | gzip -c > "$DB_LOCAL_DUMP_PATH"
if [ $? -ne 0 ]; then
    fatal_error "Failed dumping DB to filesystem" "$DB_LOCAL_DUMP_PATH"
fi
echo "done."

# Test DB dump
echo -n "[$(date)]: Testing DB dump: "
zcat "$DB_LOCAL_DUMP_PATH" | tail -n 1 | grep "^-- Dump completed.*" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    fatal_error "DB dump incomplete or corrupt" "$DB_LOCAL_DUMP_PATH"
fi
echo "done."

# Upload to S3
S3_URI="s3://$S3_BUCKET_PATH/$DB_DUMP_NAME"
echo -n "[$(date)]: Uploading DB dump to S3 $S3_URI: "
aws s3 cp --storage-class "STANDARD_IA" --only-show-errors "$DB_LOCAL_DUMP_PATH" "$S3_URI"
if [ $? -ne 0 ]; then
    fatal_error "Failed copying DB dump to S3" "$DB_LOCAL_DUMP_PATH"
fi
echo "done."

# Securely delete DB dump
echo -n "[$(date)]: Securely deleting DB local dump: "
shred -fu "$DB_LOCAL_DUMP_PATH"
if [ $? -ne 0 ]; then
    fatal_error "Failed deleting DB dump from filesystem, please delete this file manually with: \"shred -fu $DB_LOCAL_DUMP_PATH\""
fi
echo "done."

echo "[$(date)]: Command completed successfully."

