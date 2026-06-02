# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QA_PREBUILT="/opt/bin/upx"
inherit pax-utils

DESCRIPTION="UPX - the Ultimate Packer for eXecutables"
HOMEPAGE="https://upx.github.io"
SRC_URI="
amd64? ( https://github.com/upx/upx/releases/download/v5.0.2/upx-5.0.2-amd64_linux.tar.xz -> upx-bin-5.0.2-amd64_linux.tar.xz )
arm? ( https://github.com/upx/upx/releases/download/v5.0.2/upx-5.0.2-armeb_linux.tar.xz -> upx-bin-5.0.2-armeb_linux.tar.xz )
arm64? ( https://github.com/upx/upx/releases/download/v5.0.2/upx-5.0.2-arm64_linux.tar.xz -> upx-bin-5.0.2-arm64_linux.tar.xz )"
LICENSE="NOASSERTION"
SLOT="0"
KEYWORDS="*"
IUSE="doc"
post_src_unpack() {
	mv upx-* "${S}" || die
}
src_install() {
	into /usr
	dobin upx
	pax-mark -m "${ED}"/opt/bin/upx
	doman upx.1
	dodoc NEWS README*
	if use doc ; then
	  local HTML_DOCS=( upx-doc.html )
	  einstalldocs
	fi
}


# vim: filetype=ebuild
