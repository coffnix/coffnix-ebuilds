# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DOCS_BUILDER=doxygen

inherit cmake user

DESCRIPTION="The secure, private, untraceable cryptocurrency"
HOMEPAGE="https://www.getmonero.org"
SRC_URI="https://github.com/monero-project/monero/archive/v${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="*"
LICENSE="BSD MIT"
SLOT="0"

IUSE="+daemon hw-wallet readline +tools wallet-cli +wallet_api cpu_flags_x86_aes"
REQUIRED_USE="|| ( daemon tools wallet-cli )"
RESTRICT="test"

DEPEND="
	app-crypt/libmd
	dev-libs/boost:=[nls]
	dev-libs/libsodium:=
	dev-libs/libbsd
	dev-libs/openssl:=
	dev-libs/randomx
	dev-libs/rapidjson
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
	"${FILESDIR}"/${PN}-0.18.3.3-miniupnp-api-18.patch
	"${FILESDIR}"/${PN}-0.18.4.0-unbundle-dependencies.patch
)

pkg_setup() {
	if use daemon; then
		enewgroup monero
		enewuser monero -1 -1 /var/lib/monero monero
	fi
}

src_prepare() {
	sed -i "s/unknown/gentoo-${PR}/g" cmake/GitVersion.cmake || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=17
		-DBUILD_SHARED_LIBS=OFF
		-DBUILD_DOCUMENTATION=OFF
		-DMANUAL_SUBMODULES=ON
		-DUSE_CCACHE=OFF
		-DNO_AES=$(usex !cpu_flags_x86_aes)
		-DUSE_DEVICE_TREZOR=$(usex hw-wallet)
		-DUSE_READLINE=$(usex readline)
	)

	use elibc_musl && mycmakeargs+=( -DSTACK_TRACE=OFF )

	cmake_src_configure "${mycmakeargs[@]}"
}

src_compile() {
	local targets=(
		$(usev daemon)
		$(usev wallet_api)
	)

	use tools && targets+=(
		blockchain_{ancestry,blackball,db,depth,export,import,prune,prune_known_spent_data,stats,usage}
	)

	cmake_build "${targets[@]}"
	docs_compile
}

src_install() {
	einstalldocs

	find "${BUILD_DIR}/bin/" -type f -executable -print0 |
		while IFS= read -r -d '' line; do
			dobin "$line"
		done

	if use daemon; then
		dodoc utils/conf/monerod.conf

		keepdir /var/lib/monero
		fowners monero:monero /var/lib/monero
		fperms 0755 /var/lib/monero

		keepdir /var/log/monero
		fowners monero:monero /var/log/monero
		fperms 0755 /var/log/monero

		insinto /etc/monero
		doins "${FILESDIR}"/monerod.conf

		newconfd "${FILESDIR}"/monerod-0.18.4.0.confd monerod
		newinitd "${FILESDIR}"/monerod-0.18.4.0.initd monerod
		systemd_dounit "${FILESDIR}"/monerod.service
	fi
}

pkg_postinst() {
	if use daemon; then
		elog "To get sync status and other stats run"
		elog "   \$ monerod status"
		elog
		elog "The Monero blockchain can take up a lot of space (250 GiB) and is stored"
		elog "in /var/lib/monero by default. You may want to enable pruning by adding"
		elog "'prune-blockchain=1' to /etc/monero/monerod.conf to prune the blockchain"
		elog "or move the data directory to another disk."
	fi
}
