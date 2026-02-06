# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="RandomX, CryptoNight, KawPow, AstroBWT, and Argon2 CPU/GPU miner"
HOMEPAGE="https://github.com/xmrig/xmrig"
SRC_URI="https://api.github.com/repos/xmrig/xmrig/tarball/v${PV} -> xmrig-${PV}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="+ssl optimized"

DEPEND="
	dev-libs/libuv:=
	sys-apps/hwloc:=
	ssl? ( dev-libs/openssl:= )
"

PATCHES=(
	"${FILESDIR}"/xmrig-donate-zero-coffnix.patch
)

src_unpack() {
	default
	rm -rf "${S}"
	mv "${WORKDIR}"/xmrig-xmrig-* "${S}" || die
}

src_prepare() {
	cmake_src_prepare

	sed -i '/notls/d' cmake/OpenSSL.cmake || die
	sed -i 's/1;/0;/g' src/donate.h || die

	if use optimized; then
		local ecflags ecxxflags
		ecflags="$(emerge --info 2>/dev/null | sed -n 's/^CFLAGS="\([^"]*\)".*/\1/p')"
		ecxxflags="$(emerge --info 2>/dev/null | sed -n 's/^CXXFLAGS="\([^"]*\)".*/\1/p')"

		[[ -n ${ecflags} ]] || die "não consegui ler CFLAGS do emerge --info"
		[[ -n ${ecxxflags} ]] || die "não consegui ler CXXFLAGS do emerge --info"

		# escape pro sed
		ecflags=${ecflags//\\/\\\\}
		ecflags=${ecflags//&/\\&}
		ecxxflags=${ecxxflags//\\/\\\\}
		ecxxflags=${ecxxflags//&/\\&}

		# substitui os hardcodes armv7 e os genéricos do processor
		sed -i \
			-e "s|set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} -march=armv7-a -mfpu=neon[^\"]*\")|set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} ${ecflags}\")|g" \
			-e "s|set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -march=armv7-a -mfpu=neon[^\"]*\")|set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} ${ecxxflags} -flax-vector-conversions\")|g" \
			-e "s|set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} -mfpu=neon -march=\${CMAKE_SYSTEM_PROCESSOR}[^\"]*\")|set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} ${ecflags}\")|g" \
			-e "s|set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -mfpu=neon -march=\${CMAKE_SYSTEM_PROCESSOR}[^\"]*\")|set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} ${ecxxflags}\")|g" \
			cmake/flags.cmake || die
	fi
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
