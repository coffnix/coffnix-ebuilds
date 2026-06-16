# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3

DESCRIPTION="RandomX, CryptoNight, KawPow, AstroBWT, and Argon2 CPU/GPU miner"
HOMEPAGE="https://github.com/xmrig/xmrig"
#SRC_URI="https://api.github.com/repos/xmrig/xmrig/tarball/v${PV} -> xmrig-${PV}.tar.gz"
EGIT_REPO_URI="https://github.com/xmrig/xmrig.git"
EGIT_BRANCH="dev"
EGIT_CLONE_TYPE="shallow"
EGIT_CLONE_DEPTH="1"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="+ssl"

DEPEND="
	dev-libs/libuv:=
	sys-apps/hwloc:=
	ssl? ( dev-libs/openssl:= )
"

#PATCHES=(
#"${FILESDIR}"/xmrig-donate-zero-coffnix.patch
#"${FILESDIR}"/xmrig-aarch64-optimize.patch
#)

#src_unpack() {
#	default
#	rm -rf ${S}
#	mv ${WORKDIR}/xmrig-xmrig-* ${S} || die
#}

#src_prepare() {
#	cmake_src_prepare
#
#	sed -i '/notls/d' cmake/OpenSSL.cmake || die
#	sed -i 's/1;/0;/g' src/donate.h || die
#
#	if [[ ${ARCH} == arm64 ]]; then
#		local march_flag mtune_flag xmrig_arm_flags
#
#		march_flag=$(echo "${CXXFLAGS}" | tr ' ' '\n' | grep '^[-]march=' | tail -n1)
#		mtune_flag=$(echo "${CXXFLAGS}" | tr ' ' '\n' | grep '^[-]mtune=' | tail -n1)
#
#		xmrig_arm_flags="${march_flag}"
#
#		if [[ "${xmrig_arm_flags}" != *"+crypto"* ]]; then
#			xmrig_arm_flags="${xmrig_arm_flags}+crypto"
#		fi
#
#		if [[ -n "${mtune_flag}" ]]; then
#			xmrig_arm_flags="${xmrig_arm_flags} ${mtune_flag}"
#		fi
#
#		sed -i "s|-march=armv8-a+crypto|${xmrig_arm_flags}|g" cmake/cpu.cmake || die
#	fi
#}

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
		-DWITH_GHOSTRIDER=OFF
		-DWITH_KAWPOW=OFF
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
