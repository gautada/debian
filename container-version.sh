#!/bin/bash
# Script that provides the container version scheme. As the 
# container version is a complex thing meaning that it is 
# a  
os_name() {
 echo "debian"
}

os_version() {
 /bin/cat /etc/debian_version
}

os_build() {
 /bin/cat /etc/debian-build 2>/dev/null || echo "unknown"
}

base_version() {
 echo "$(os_name)-$(os_version).$(os_build)"
}

container_name() {
 /bin/cat /etc/container/name
}

container_build() {
 /bin/cat /etc/container/build	
}
