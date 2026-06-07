EAPI="7"

DESCRIPTION="Official motd Vipnix Linux based on MacaroniOS"
HOMEPAGE="https://vipnix.com.br"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}"

src_compile() {
	einfo "Nothing to compile, install files only"
}

src_install() {
	insinto /etc/profile.d
	doins "${FILESDIR}/vipnix.sh"

	insinto /etc/update-motd.d
	doins "${FILESDIR}/30-vipnix-sysinfo"

	insinto /etc/vipnix
	doins "${FILESDIR}/logo.ascii"
}
