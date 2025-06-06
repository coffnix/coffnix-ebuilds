# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit bash-completion-r1 linux-info meson python-single-r1 vala xdg

DESCRIPTION="Aims to make updating firmware on Linux automatic, safe and reliable"
HOMEPAGE="https://fwupd.org"
SRC_URI="https://github.com/fwupd/fwupd/tarball/2519888ca602e14b38953536a9f13d4464462513 -> fwupd-2.0.10-2519888.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"
IUSE="amt archive bash-completion bluetooth +dell +elogind fastboot flashrom +gnutls gtk-doc introspection logitech lzma +man minimal modemmanager nvme policykit spi +sqlite synaptics test thunderbolt tpm +uefi"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	^^ ( elogind minimal )
	dell? ( uefi )
	minimal? ( !introspection )
	spi? ( lzma )
	synaptics? ( gnutls )
	uefi? ( gnutls )
"
RESTRICT="!test? ( test )"

BDEPEND="$(vala_depend)
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc )
	bash-completion? ( >=app-shells/bash-completion-2.0 )
	introspection? ( dev-libs/gobject-introspection )
	man? (
		app-text/docbook-sgml-utils
		sys-apps/help2man
	)
	test? (
		thunderbolt? ( dev-util/umockdev )
		net-libs/gnutls[tools]
	)
"
COMMON_DEPEND="${PYTHON_DEPS}
	>=app-arch/gcab-1.0
	app-arch/xz-utils
	>=dev-libs/glib-2.58:2
	dev-libs/json-glib
	dev-libs/libgudev:=
	>=dev-libs/libjcat-0.1.4[gpg,pkcs7]
	>=dev-libs/libxmlb-0.1.13:=[introspection?]
	$(python_gen_cond_dep '
		dev-python/pygobject:3[cairo,${PYTHON_USEDEP}]
	')
	>=net-libs/libsoup-2.51.92:2.4[introspection?]
	net-misc/curl
	archive? ( app-arch/libarchive:= )
	dell? ( >=sys-libs/libsmbios-2.4.0 )
	elogind? ( >=sys-auth/elogind-211 )
	flashrom? ( >=sys-apps/flashrom-1.2-r3 )
	gnutls? ( net-libs/gnutls )
	logitech? ( dev-libs/protobuf-c:= )
	lzma? ( app-arch/xz-utils )
	modemmanager? ( net-misc/modemmanager[qmi] )
	policykit? ( >=sys-auth/polkit-0.103 )
	sqlite? ( dev-db/sqlite )
	tpm? ( app-crypt/tpm2-tss:= )
	uefi? (
		sys-apps/fwupd-efi
		sys-boot/efibootmgr
		sys-fs/udisks
		sys-libs/efivar
	)
"
# Block sci-chemistry/chemical-mime-data for bug #701900
RDEPEND="
	!<sci-chemistry/chemical-mime-data-0.1.94-r4
	${COMMON_DEPEND}
	sys-apps/dbus
"

DEPEND="
	${COMMON_DEPEND}
	x11-libs/pango[introspection]
"

pkg_setup() {
	python-single-r1_pkg_setup
	if use nvme ; then
		kernel_is -ge 4 4 || die "NVMe support requires kernel >= 4.4"
	fi
}

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv fwupd-fwupd* "${S}" || die
	fi
}

src_prepare() {
	default
	# c.f. https://github.com/fwupd/fwupd/issues/1414
	sed -e "/test('thunderbolt-self-test', e, env: test_env, timeout : 120)/d" \
		-i plugins/thunderbolt/meson.build || die

	sed -e '/platform-integrity/d' \
		-i plugins/meson.build || die #753521

	sed -e "/install_dir.*'doc'/s/fwupd/${PF}/" \
		-i data/meson.build || die

	vala_src_prepare
}

src_configure() {
	local plugins=(
		-Dplugin_gpio="enabled"
		$(meson_feature fastboot plugin_fastboot)
		$(meson_feature flashrom plugin_flashrom)
		$(meson_feature logitech plugin_logitech_bulkcontroller)
		$(meson_feature modemmanager plugin_modem_manager)
		$(meson_feature nvme plugin_nvme)
		$(meson_feature sqlite)
		$(meson_feature synaptics plugin_synaptics_mst)
		$(meson_feature synaptics plugin_synaptics_rmi)
		$(meson_feature tpm plugin_tpm)
		$(meson_feature uefi plugin_uefi_capsule)
		$(meson_use uefi plugin_uefi_capsule_splash)
		$(meson_feature uefi plugin_uefi_pk)
	)
	use ppc64 && plugins+=( -Dplugin_msr="enabled" )
	use riscv && plugins+=( -Dplugin_msr="enabled" )

	local emesonargs=(
		--localstatedir "${EPREFIX}"/var
		-Dbuild="$(usex minimal standalone all)"
		-Dconsolekit="disabled"
		-Dsystemd="disabled"
		-Dsystemd_syscall_filter="false"
		-Dcurl="enabled"
		-Ddocs="$(usex gtk-doc enabled disabled)"
		-Defi_binary="false"
		-Dsupported_build="enabled"
		$(meson_feature lzma)
		$(meson_feature gnutls)
		$(meson_feature elogind)
		$(meson_feature bluetooth bluez)
		$(meson_feature introspection)
		$(meson_feature policykit polkit)
		$(meson_feature archive libarchive)
		$(meson_use bash-completion bash_completion)
		$(meson_use man)
		$(meson_use test tests)

		${plugins[@]}
	)
	use uefi && emesonargs+=( -Defi_os_dir="funtoo" )
	export CACHE_DIRECTORY="${T}"
	meson_src_configure
}

src_install() {
	meson_src_install

	if ! use minimal ; then
		newinitd "${FILESDIR}"/${PN}-r2 ${PN}

		# Don't timeout when fwupd is running (#673140)
		sed '/^IdleTimeout=/s@=[[:digit:]]\+@=0@' \
			-i "${ED}"/etc/${PN}/fwupd.conf || die
	fi
}

# vim: filetype=ebuild