# Disable connman service at startup
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

# Also, disable the connman-wait-online and connman-vpn services
# to avoid any issues while installing their associated packages
SYSTEMD_AUTO_ENABLE:${PN}-wait-online = "disable"
SYSTEMD_AUTO_ENABLE:${PN}-vpn = "disable"

# Set low alternative priority for resolv-conf to keep systemd by default
ALTERNATIVE_PRIORITY[resolv-conf] = "10"

# As we disable CONNMAN service, we also need to remove the specific
# /etc/tmpfiles.d/connman_resolvconf.conf to let systemd managing /etc/resolv.conf
do_install:append() {
    if [ -f ${D}/${sysconfdir}/tmpfiles.d/connman_resolvconf.conf ]; then
        rm ${D}/${sysconfdir}/tmpfiles.d/connman_resolvconf.conf
    fi
}
