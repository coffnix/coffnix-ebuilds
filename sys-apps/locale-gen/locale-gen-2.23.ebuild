# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="Generate locales based upon the config file /etc/locale.gen"
HOMEPAGE="https://gitweb.gentoo.org/proj/locale-gen.git/ https://github.com/gentoo/locale-gen"
SRC_URI="https://api.github.com/repos/gentoo/locale-gen/tarball/refs/tags/locale-gen-2.23 -> locale-gen-2.23-941f508.tar.gz"
LICENSE="GPL-2.0"
SLOT="0"
KEYWORDS="*"
RDEPEND="app-shells/bash
	!!<sys-libs/glibc-2.37-r3
	
"

post_src_unpack() {
	mv gentoo-locale-gen-* ${S}
}


src_install() {
	dosbin locale-gen
	doman *.[0-8]
	insinto /etc
	doins locale.gen
	keepdir /usr/lib/locale
}



# vim: filetype=ebuild
