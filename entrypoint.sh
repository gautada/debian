#!/bin/bash
#
# entrypoint: Located at `/etc/container/entrypoint` this script is the custom
#             entry for a container as called by `/usr/bin/container-entrypoint` set
#             in the upstream [debian-container](https://github.com/gautada/debian-container).
#             The default template is kept in
#             [gist](https://gist.github.com/gautada/f185700af585a50b3884ad10c2b02f98)

container_entrypoint() {
 /bin/echo "This is the default entrypoint. You should overload the 'container_entrypoint()' function."
 /usr/bin/tail -f /dev/null
}
