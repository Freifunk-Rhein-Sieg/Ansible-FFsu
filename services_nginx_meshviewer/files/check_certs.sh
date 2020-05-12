#!/bin/bash
cd /etc/ssl
 openssl rsa -in key.pem -check
 openssl x509 -in fullchain.pem -text -noout
