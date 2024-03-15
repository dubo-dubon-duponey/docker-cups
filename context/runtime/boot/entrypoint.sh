#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)"
readonly root
# shellcheck source=/dev/null
. "$root/helpers.sh"
# shellcheck source=/dev/null
. "$root/mdns.sh"

# Necessary for adding printers
helpers::dir::writable /etc/cups

# mDNS
mdns::start::dbus
mdns::start::avahi

post::config(){
  sleep 10
  cupsctl --share-printers --remote-any
  # --remote-admin
  # lpinfo -m to get models
  # XXX well - not exactly a generic solution right?
  lpadmin -p "Magnetosphere" -D "Magnetosphere" \
    -v "usb://Brother/HL-L2340D%20series" \
    -m drv:///brlaser.drv/brl2340d.ppd \
    -u allow:all \
    -o cupsIPPSupplies=true \
    -o cupsSNMPSupplies=true \
    -o PageSize=Legal \
    -E
}

post::config &
#exec cupsd -c /config/cups/main.conf -f "$@"
exec cupsd -f "$@"
