#!/bin/sh
#
# This shell script is part of the version mechanism of the base container. This
# file can and should be overridden by the downstream container to provide the
# specific software running in the container should simply print a clean version
# number to stdout.

# Print the Debian version number
cat /etc/debian_version

