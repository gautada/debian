#!/bin/bash

__os_stable_version() {
 curl --location --silent https://deb.debian.org/debian/dists/stable/Release | grep "^Version:" | awk '{print $2}'
}

__os_running_version() {
 /bin/cat /etc/debian_version
}

__health_check() {
 _health_assert "$(__os_stable_version)" "$(__os_running_version)" "OS Stable version must equal running version"
 _health_assert "$(_docker_latest_version 'library/debian')" "$(__os_running_version)" "Docker latest image version must equal running version"
 _health_assert "$(_docker_latest_version 'gautada/debian')" "$(__os_running_version)" "Container latest image version must equal running version"
}
