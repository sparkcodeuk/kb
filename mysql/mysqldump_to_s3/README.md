# MySQLdump to S3 backup script

A quick & dirty script for dumping & backing up a MySQL database to AWS S3.

The script dumps the database to the filesystem (gzip compressed), does a basic test to make sure the `mysqldump` completed and then uploads to S3 and securely deletes it from the filesystem.

## Required software packages

* AWS CLI (`aws`)
* MySQL CLI (`mysqldump`)
* `shred` (secure file deletion)

## Usage

The following command will backup the database `example-db` (taken from the `example-db.cnf` filename) to the S3 bucket path `s3://s3-bucket-name/some/prefix/...`:

`mysqldump_to_s3.sh /path/to/example-db.cnf s3-bucket-name/some/prefix`

You will need to configure a MySQL defaults file, e.g., `example-db.cnf` with the appropriate credentials & `mysqldump` config options, the file should be owned and only readable by the user(s) dumping the database.

An example .cnf file configuration:

```text
[mysqldump]
host=YOUR_MYSQL_HOSTNAME.DOMAIN.COM
user=YOUR_MYSQL_USERNAME
password=YOUR_MYSQL_PASSWORD

allow-keywords
complete-insert
extended-insert
quote-names
single-transaction
compress
```
