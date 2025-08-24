# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit autotools flag-o-matic

DESCRIPTION="A selection of tools from Debian"
HOMEPAGE="https://packages.qa.debian.org/d/debianutils.html"
SRC_URI="http://ftp.it.debian.org/debian/pool/main/d/debianutils/debianutils_5.23.1.tar.xz -> debianutils_5.23.1.tar.xz"
LICENSE="BSD GPL-2 SMAIL"
SLOT="0"
KEYWORDS="*"
IUSE="+installkernel static"
S="${WORKDIR}/debianutils"
src_prepare() {
	# Avoid adding po4a dependency, upstream refreshes manpages.
	sed -i -e '/SUBDIRS/s|po4a||' Makefile.am || die
	default
	eautoreconf
}
src_configure() {
	use static && append-ldflags -static
	default
}

src_install() {
	into /
	dobin tempfile run-parts
	if use installkernel ; then
	  dosbin installkernel
	fi
	into /usr
	dobin ischroot
	dosbin savelog
	doman ischroot.1 tempfile.1 run-parts.8 savelog.8
	use installkernel && doman installkernel.8
	keepdir /etc/kernel/postinst.d
}


# vim: filetype=ebuild
