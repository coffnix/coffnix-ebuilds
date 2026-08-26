# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Command-line interface to various pastebins"
HOMEPAGE="https://github.com/zlin/wgetpaste"
SRC_URI="https://github.com/zlin/wgetpaste/releases/download/${PV}/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="+ssl"

PROPERTIES="test_network"
RESTRICT="test"

RDEPEND="net-misc/wget[ssl?]"

src_prepare() {
	default

	sed -i -e "s:/etc:\"${EPREFIX}\"/etc:g" wgetpaste || die
}

src_test() {
	test/test.sh || die
}

src_install() {
	dobin ${PN}

	insinto /usr/share/zsh/site-functions
	doins _wgetpaste
}

pkg_postinst() {
	einfo "Optional dependency for ANSI color code stripping:"
	einfo "  app-text/ansifilter"
	einfo
	einfo "Optional dependency for xclip support:"
	einfo "  x11-misc/xclip"

	local oldver

	for oldver in ${REPLACING_VERSIONS}; do
		if [[ $(printf '%s\n%s\n' "${oldver}" "2.33-r2" | sort -V | head -n1) == "${oldver}" &&
			${oldver} != "2.33-r2" ]]; then
			ewarn
			ewarn "Sprunge is dead and the service has been dropped from the code. Remove or"
			ewarn "replace sprunge as the default service in the system or user wgetpaste"
			ewarn "config if applicable."
			ewarn
			break
		fi
	done
}
