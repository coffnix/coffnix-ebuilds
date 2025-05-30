# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs flag-o-matic

DESCRIPTION="Utility to change hard drive performance parameters"
HOMEPAGE="https://sourceforge.net/projects/hdparm/"
SRC_URI="https://downloads.sourceforge.net/hdparm/hdparm/hdparm-9.65.tar.gz -> hdparm-9.65.tar.gz"
#SRC_URI="https://sourceforge.net/projects/hdparm/files/hdparm/"

LICENSE="BSD GPL-2" # GPL-2 only
SLOT="0"
KEYWORDS="*"
IUSE="static"

src_prepare() {
	default
	use static && append-ldflags -static
}

src_configure() {
	tc-export CC
	export STRIP=:
}

src_install() {
	into /
	dosbin hdparm contrib/idectl

	newinitd "${FILESDIR}"/hdparm-init-8 hdparm
	newconfd "${FILESDIR}"/hdparm-conf.d.3 hdparm

	doman hdparm.8
	dodoc hdparm.lsm Changelog README.acoustic hdparm-sysconfig
	docinto wiper
	dodoc wiper/{README.txt,wiper.sh}
	docompress -x /usr/share/doc/${PF}/wiper/wiper.sh
}