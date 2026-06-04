# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

QA_PREBUILT="/usr/bin/upx"

inherit pax-utils

DESCRIPTION="UPX - the Ultimate Packer for eXecutables"
HOMEPAGE="https://upx.github.io"

SRC_URI="
amd64? ( https://github.com/upx/upx/releases/download/v5.1.1/upx-5.1.1-amd64_linux.tar.xz -> upx-bin-5.1.1-amd64_linux.tar.xz )
x86? ( https://github.com/upx/upx/releases/download/v5.1.1/upx-5.1.1-i386_linux.tar.xz -> upx-bin-5.1.1-i386_linux.tar.xz )
arm? ( https://github.com/upx/upx/releases/download/v5.1.1/upx-5.1.1-arm_linux.tar.xz -> upx-bin-5.1.1-arm_linux.tar.xz )
arm64? ( https://github.com/upx/upx/releases/download/v5.1.1/upx-5.1.1-arm64_linux.tar.xz -> upx-bin-5.1.1-arm64_linux.tar.xz )
"

LICENSE="NOASSERTION"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

S="${WORKDIR}/upx-5.1.1-arm_linux"

src_unpack() {
	default

	local d
	d="$(find "${WORKDIR}" -maxdepth 1 -type d -name 'upx-5.1.1-*linux' | head -n 1)"

	if [[ -z "${d}" ]]; then
		die "UPX source directory not found"
	fi

	mv "${d}" "${S}" || die
}

src_install() {
	dobin upx

	pax-mark -m "${ED}/usr/bin/upx" || die

	doman upx.1
	dodoc NEWS README*

	if use doc ; then
		local HTML_DOCS=( upx-doc.html )
		einstalldocs
	fi
}
