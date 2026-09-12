# Distributed under the terms of the GNU General Public License v2

EAPI=7

DOCS_BUILDER=doxygen

inherit cmake user

DESCRIPTION="The secure, private, untraceable cryptocurrency"
HOMEPAGE="https://www.getmonero.org"

#SRC_URI="https://github.com/monero-project/monero/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="https://downloads.getmonero.org/cli/monero-source-v${PV}.tar.bz2 -> ${P}.tar.bz2"

S="${WORKDIR}/monero-source-v${PV}"
KEYWORDS="*"

LICENSE="BSD MIT"
SLOT="0"
IUSE="+daemon hw-wallet readline +tools +wallet-cli +wallet-rpc +aes"
REQUIRED_USE="|| ( daemon tools wallet-cli wallet-rpc )"
RESTRICT="test"

DEPEND="
	app-crypt/libmd
	dev-libs/boost:=[nls]
	dev-libs/libsodium:=
	dev-libs/libbsd
	dev-libs/openssl:=
	dev-libs/randomx:=
	dev-libs/rapidjson
	dev-libs/supercop-monero
	net-dns/unbound:=[threads]
	net-libs/miniupnpc:=
	net-libs/zeromq:=
	readline? ( sys-libs/readline:= )
	hw-wallet? (
		dev-libs/hidapi
		dev-libs/protobuf:=
		virtual/libusb:1
	)
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-0.18.5.0-unbundle-dependencies.patch
)

pkg_setup() {
	if use daemon; then
		enewgroup monero
		enewuser monero -1 -1 /var/lib/monero monero
	fi
}

src_prepare() {
	sed -i "s/unknown/gentoo-${PR}/g" cmake/GitVersion.cmake || die

	einfo "Monero build: CHOST=${CHOST}"
	einfo "Monero build: ARCH=${ARCH}"

	if [[ ${ARCH} == arm64 ]]; then
		einfo "ARM64 detected, applying Monero ARM64 fixes"

		# Monero 0.18.5.1 forces C++14
		sed -i \
			's/set(CMAKE_CXX_STANDARD 14)/set(CMAKE_CXX_STANDARD 17)/' \
			CMakeLists.txt || die

		# Do not append Monero's ARM architecture flag.
		# Keep -march/-mtune from Portage CFLAGS/CXXFLAGS.
		sed -i \
			's/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARCH_FLAG}")/# ARM64: use Portage CXXFLAGS/' \
			CMakeLists.txt || die

		# Same for C flags if Monero adds ARCH_FLAG there.
		sed -i \
			's/set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ARCH_FLAG}")/# ARM64: use Portage CFLAGS/' \
			CMakeLists.txt || die

		# RandomX also hardcodes armv8-a+crypto
		sed -i \
			's/add_flag("-march=armv8-a+crypto")//' \
			external/randomx/CMakeLists.txt || die

		einfo "ARM64 patch verification:"
		grep -n 'CMAKE_CXX_STANDARD' CMakeLists.txt | head
		grep -n 'ARCH_FLAG' CMakeLists.txt | grep 'CMAKE_.*FLAGS' || true

		if grep -Rqs -- '-march=armv8-a+crypto' .; then
			ewarn "Still found -march=armv8-a+crypto:"
			grep -Rni -- '-march=armv8-a+crypto' . || true
		else
			einfo "OK: no hardcoded -march=armv8-a+crypto remains"
		fi
	fi

	cmake_src_prepare
}

src_configure() {
	append-cflags -std=gnu17
	append-cxxflags -std=gnu++17

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DBUILD_DOCUMENTATION=OFF
		-DMANUAL_SUBMODULES=ON
		-DUSE_CCACHE=OFF
		-DNO_AES=$(usex !aes)
		-DUSE_DEVICE_TREZOR=$(usex hw-wallet)
		-DUSE_READLINE=$(usex readline)
		-DCMAKE_CXX_STANDARD=17
		-DCMAKE_POLICY_DEFAULT_CMP0148=NEW
		-DSTACK_TRACE=OFF
		-DCMAKE_CXX_STANDARD_REQUIRED=ON
		-DCMAKE_CXX_EXTENSIONS=ON
	)

	use elibc_musl && mycmakeargs+=( -DSTACK_TRACE=OFF )

	cmake_src_configure
}

src_compile() {
	local targets=()
	use daemon && targets+=(monerod)
	use wallet-cli && targets+=(monero-wallet-cli)
	use wallet-rpc && targets+=(monero-wallet-rpc)
	use tools && targets+=(
		blockchain_ancestry
		blockchain_blackball
		blockchain_db
		blockchain_depth
		blockchain_export
		blockchain_import
		blockchain_prune
		blockchain_prune_known_spent_data
		blockchain_stats
		blockchain_usage
	)
	targets+=(device)

	cmake_build "${targets[@]}"
	docs_compile
}

src_install() {
	einstalldocs

	# Install all binaries.
	find "${BUILD_DIR}/bin/" -type f -executable -print0 |
		while IFS= read -r -d '' line; do
			dobin "$line"
		done

	if use daemon; then
		dodoc utils/conf/monerod.conf

		# data-dir
		keepdir /var/lib/monero
		fowners monero:monero /var/lib/monero
		fperms 0755 /var/lib/monero

		# log-file dir
		keepdir /var/log/monero
		fowners monero:monero /var/log/monero
		fperms 0755 /var/log/monero

		# /etc/monero/monerod.conf
		insinto /etc/monero
		doins "${FILESDIR}"/monerod.conf

		# OpenRC
		newconfd "${FILESDIR}"/monerod-0.18.4.0.confd monerod
		newinitd "${FILESDIR}"/monerod-0.18.4.0.initd monerod

		# systemd
		systemd_dounit "${FILESDIR}"/monerod.service
	fi
}

pkg_postinst() {
	if use daemon; then
		elog "To get sync status and other stats run"
		elog "   $ monerod status"
		elog
		elog "The Monero blockchain can take up a lot of space (250 GiB) and is stored"
		elog "in /var/lib/monero by default. You may want to enable pruning by adding"
		elog "'prune-blockchain=1' to /etc/monero/monerod.conf to prune the blockchain"
		elog "or move the data directory to another disk."
	fi
}
