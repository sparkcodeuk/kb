# SSL Snakeoil Certificate Generator

Requires `openssl` CLI tools to be installed.

* Copy the `req.conf.dist` file to `req.conf`
* Configure the `req_distinguished_name` section of the file with the organisation's details
  * NOTE: The `CN` (common name) should be left as `snakeoil.THEPRIMARYDOMAIN.COM` so it's obvious in the browser you're using a snakeoil certificate
* Configure the `alt_names` section with all the domains you want in the SSL SAN certificate
  * The `DNS.1` entry should be the primary domain
  * The subsequent entries can be other domains you need to support
* Run `generate_snakeoil_cert.sh` to generate the necessary SSL certificate files
* Install the certificate where you need
