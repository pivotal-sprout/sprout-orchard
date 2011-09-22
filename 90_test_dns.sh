#!/bin/bash
#
# Used by Jenkins to test our DNS
#
# Very basic.
#
# mavenlink has a wildcard domain, so I use that to bypass our
# cache & forward the query out to the Internet by prepending
# our PID
#
function _host {
  if host $1; then
    : # do nothing
  else
    echo "nslookup $1 FAILED"
    exit 1  # failure, exit non-zero
  fi
}

for host in google.com  \
  pivotallabs.com \
  localhost \
  asdfasdfsdsadf \
  gateway.{boulder,sg,nyc,flood}.pivotallabs.com \
  10.64.0.1 \
  10.66.0.1 \
  10.70.0.1 \
  10.72.0.1 \
  172.17.1.1. \
  127.0.0.1 \
  172.17.1.1 \
  172.17.1.1 \
  c.brightcove.com \
  a$$.mavenlink.com
do
  _host $host
done
