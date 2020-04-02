# openssl-ca-helpers

Some scripts to help convert encoded certificate chains into more readable forms.

Also, OpenSSL's CLI contains commands that provide a complete certificate authority, originally intended as a demonstration but also useful for generating test certificates -- especially if you want to generate your certs using a different library than you're using to consume them. The scripts here can, with a bit of modification, be used to generate some test certificates. Originally, these were intended to work with email SANs rather than the more common domain names.

Scripts based on [the Feisty Duck OpenSSL Cookbook](https://www.feistyduck.com/books/openssl-cookbook/). The [Bulletproof TLS Newsletter](https://www.feistyduck.com/bulletproof-tls-newsletter/) is also highly recommended.
