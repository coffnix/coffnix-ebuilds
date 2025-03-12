EAPI="7"

inherit user

DESCRIPTION="Init script and user setup for system-wide PulseAudio"
HOMEPAGE="https://vipnix.com.br"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="media-sound/pulseaudio"
RDEPEND="${DEPEND}"

S="${WORKDIR}"




src_install() {
    # Instala o script init
    doinitd "${FILESDIR}/pulse-system"
}

pkg_postinst() {
    enewgroup pulse
	enewgroup pulse-access
    enewuser pulse -1 -1 "/var/run/pulse" pulse
    einfo "PulseAudio system-wide mode has been installed."
    einfo "To start it, run: rc-update add pulse-system default"
    einfo "Then: /etc/init.d/pulse-system start"
    ewarn "Note: System-wide PulseAudio is not recommended for most use cases."
    ewarn "Consider using per-user PulseAudio unless you have specific needs."
}
