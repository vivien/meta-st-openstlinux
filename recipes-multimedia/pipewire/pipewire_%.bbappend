# Overwrite pipewire configuration
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://system.pa.conf"

PACKAGECONFIG:class-target ??= " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'zeroconf', 'avahi', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez bluez-opus ${BLUETOOTH_AAC}', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd systemd-user-service', '', d)} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'alsa vulkan pulseaudio', d)} \
    ${PIPEWIRE_SESSION_MANAGER} \
    ${FFMPEG_AVAILABLE} avahi flatpak gstreamer gsettings jack libusb pw-cat raop sndfile v4l2 udev volume webrtc-echo-cancelling libcamera readline \
"

do_install:append() {
    # create directory for system-wide pipewire configuration
    install -d "${D}${sysconfdir}/pipewire"

    install -m 0644 "${D}${datadir}/pipewire/pipewire.conf" "${D}${sysconfdir}/pipewire/pipewire.conf"
    sed -i 's/#default.clock.max-quantum   = 2048/default.clock.max-quantum   = 1024/' "${D}${sysconfdir}/pipewire/pipewire.conf"
    sed -i 's/#default.clock.allowed-rate.*$/default.clock.allowed-rates = [ 48000 44100]/' "${D}${sysconfdir}/pipewire/pipewire.conf"
    sed -i "s|^priority = .*$|priority = 88|g" ${D}${datadir}/alsa-card-profile/mixer/paths/analog-output-speaker.conf

    # install configuration files related to PulseAudio-compatible server
    install -d "${D}${sysconfdir}/pipewire/pipewire-pulse.conf.d"

    install -m 0644 "${WORKDIR}/system.pa.conf" "${D}${sysconfdir}/pipewire/pipewire-pulse.conf.d"

    # add ALSA specific configuration files if present
    if [ -d "${D}${datadir}/alsa/alsa.conf.d" ]; then
        install -d "${D}${sysconfdir}/alsa/conf.d"

        for conffile in $(find "${D}${datadir}/alsa/alsa.conf.d" -type f -name "*.conf"); do
            ln -s "$(echo $conffile | sed "s,${D},,")" "${D}${sysconfdir}/alsa/conf.d"
        done
    fi
}

CONFFILES:${PN} += "${sysconfdir}/pipewire/pipewire.conf"
FILES:${PN} += " \
    ${sysconfdir}/pipewire \
"

FILES:${PN}-alsa += "\
    ${sysconfdir}/alsa/conf.d/* \
"
