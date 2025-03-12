# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="AudioProcessing library from the webrtc.org codebase"
HOMEPAGE="https://www.freedesktop.org/software/pulseaudio/webrtc-audio-processing/"
SRC_URI="https://freedesktop.org/software/pulseaudio/${PN}/${P}.tar.xz"

LICENSE="BSD"
SLOT="1"
KEYWORDS="amd64 ~arm64 ~ppc64 x86"
IUSE="cpu_flags_arm_neon"

RDEPEND="dev-cpp/abseil-cpp"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
    "${FILESDIR}/${PN}-1.3-Add-generic-byte-order-and-pointer-size-detection.patch"
    "${FILESDIR}/${PN}-1.3-big-endian-support.patch"
    "${FILESDIR}/${PN}-1.3-x86-no-sse.patch"
    "${FILESDIR}/${PN}-1.3-musl.patch"
    "${FILESDIR}/${PN}-1.3-gcc15-cstdint.patch"
)

DOCS=( AUTHORS NEWS README.md )

src_configure() {
    # Ajuste para x86, se aplicável
    if [[ ${ARCH} == x86 ]] ; then
        # bug #921140
        local -x CPPFLAGS="${CPPFLAGS} -DPFFFT_SIMD_DISABLE"
    fi

    local emesonargs=(
        -Dneon=$(usex cpu_flags_arm_neon yes no)
    )
    meson_src_configure
}
