# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="RandomX, CryptoNight, KawPow, AstroBWT, and Argon2 CPU/GPU miner"
HOMEPAGE="https://github.com/xmrig/xmrig"
SRC_URI="https://api.github.com/repos/xmrig/xmrig/tarball/v6.22.2 -> xmrig-6.22.2.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="+ssl"

DEPEND="
	dev-libs/libuv:=
	sys-apps/hwloc:=
	ssl? ( dev-libs/openssl:= )
"

src_unpack() {
	default
	rm -rf ${S}
	mv ${WORKDIR}/xmrig-xmrig-* ${S} || die
}

src_prepare() {
	cmake_src_prepare

	sed -i '/notls/d' cmake/OpenSSL.cmake || die
	sed -i 's/1;/0;/g' src/donate.h || die
}

src_configure() {
	local mycmakeargs=(
		-DWITH_TLS=$(usex ssl)
		-DWITH_OPENCL=OFF
		-DWITH_CUDA=OFF
	)

	cmake_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/xmrig"
	dodoc -r doc/*.md
	einstalldocs
}

pkg_postinst() {
	elog "Increase the vm.nr_hugepages sysctl value so that XMRig can allocate with huge pages."
	elog "CPU specific performance tweaks: sys-apps/msr-tools"
}