# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-mod systemd toolchain-funcs udev user

MY_PV="${PV%_p*}"
MY_BUILD="${PV##*_p}"

MY_PN="VirtualBox"
MY_P="${MY_PN}-${MY_PV}"

S="${WORKDIR}/${MY_P}"

DESCRIPTION="VirtualBox kernel modules and user-space tools for Gentoo guests"
HOMEPAGE="https://www.virtualbox.org/"
SRC_URI="
	https://download.virtualbox.org/virtualbox/${MY_PV}/VirtualBox-${MY_PV}.tar.bz2
		-> VirtualBox-${MY_PV}.tar.bz2
"

LICENSE="GPL-3 LGPL-2.1+ MIT || ( GPL-3 CDDL )"
SLOT="0"
KEYWORDS="*"

IUSE="+dbus systemd X"

RDEPEND="
	X? (
		x11-apps/xrandr
		x11-apps/xrefresh
		x11-libs/libXmu
		x11-libs/libX11
		x11-libs/libXt
		x11-libs/libXext
	)
	sys-libs/pam
	sys-libs/zlib
	dbus? ( sys-apps/dbus )
"

DEPEND="
	${RDEPEND}

	X? (
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-base/xorg-proto
	)

	virtual/linux-sources
"

BDEPEND="
	>=dev-lang/yasm-0.6.2
	>=dev-util/kbuild-0.1.9998.3127
	sys-devel/bin86
	sys-power/iasl
"

PDEPEND="
	X? (
		xlibre-drivers/xf86-video-vbox
	)
"

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"

VBOX_MOD_SRC_DIR="${S}/out/linux.${ARCH}/release/bin/additions/src"

MODULESD_VBOXSF_ALIASES=(
	"fs-vboxsf vboxsf"
)

pkg_setup() {
	export DISTCC_DISABLE=1

	MODULE_NAMES="
		vboxguest(misc:${VBOX_MOD_SRC_DIR}/vboxguest:${VBOX_MOD_SRC_DIR}/vboxguest)
		vboxsf(misc:${VBOX_MOD_SRC_DIR}/vboxsf:${VBOX_MOD_SRC_DIR}/vboxsf)
	"

	if use X ; then
		MODULE_NAMES+=" vboxvideo(misc:${VBOX_MOD_SRC_DIR}/vboxvideo::${VBOX_MOD_SRC_DIR}/vboxvideo)"
	fi

	linux-mod_pkg_setup
}

src_prepare() {
	# Remove bundled kBuild and yasm binaries
	rm -rf kBuild/bin tools || die "failed to remove bundled build tools"

	# Generate Guest Additions kernel module sources
	pushd src/VBox/Additions &>/dev/null || die

	ebegin "Extracting VirtualBox Guest Additions kernel module sources"

	kmk \
		GuestDrivers-src \
		vboxguest-src \
		vboxsf-src \
		vboxvideo-src \
		&>/dev/null

	eend $? || die "failed to extract Guest Additions kernel module sources"

	popd &>/dev/null || die

	# Existing compatibility patch
	pushd "${VBOX_MOD_SRC_DIR}" &>/dev/null || die

	eapply "${FILESDIR}"/vboxguest-6.1.36-log-use-c99.patch

	popd &>/dev/null || die

	# Disable components not used by this Guest Additions package
	cp "${FILESDIR}/${PN}-5-localconfig" LocalConfig.kmk \
		|| die "failed to install LocalConfig.kmk"

	if ! use X ; then
		printf '%s\n' \
			'VBOX_WITH_X11_ADDITIONS :=' \
			>> LocalConfig.kmk \
			|| die
	fi

	# Remove pointless GCC version check
	sed \
		-e '/^check_gcc$/d' \
		-i configure \
		|| die "failed to remove GCC version check"

	# Respect LDFLAGS
	sed \
		-i \
		-e '/TEMPLATE_VBOXR3EXE_LDFLAGS.linux[	 ]*=/ s/$/ $(CCLDFLAGS)/' \
		Config.kmk \
		|| die "failed to patch Config.kmk"

	if [[ -d "${FILESDIR}/patches" ]] ; then
		eapply "${FILESDIR}/patches"
	fi

	eapply_user
}

src_configure() {
	tc-export AR CC CXX LD RANLIB

	local myconf=(
		--nofatal
		--disable-xpcom
		--disable-sdl-ttf
		--disable-pulse
		--disable-alsa
		$(usev !dbus --disable-dbus)

		--with-gcc="$(tc-getCC)"
		--with-g++="$(tc-getCXX)"

		--target-arch="${ARCH}"
		--with-linux="${KV_OUT_DIR}"

		--build-headless
	)

	# Force kBuild to respect Portage flags
	printf '%s\n' \
		"CFLAGS=${CFLAGS}" \
		"CXXFLAGS=${CXXFLAGS}" \
		"CCLDFLAGS=${LDFLAGS}" \
		>> LocalConfig.kmk \
		|| die "failed to append compiler flags to LocalConfig.kmk"

	./configure "${myconf[@]}" \
		|| die "Configure failed"
}

src_compile() {
	source ./env.sh || die "failed to source VirtualBox build environment"

	# Force kBuild to respect MAKEOPTS
	local MAKEJOBS
	local MAKELOAD

	MAKEJOBS=$(
		grep -Eo '(\-j|\-\-jobs)(=?|[[:space:]]*)[[:digit:]]+' <<< "${MAKEOPTS}"
	)

	MAKELOAD=$(
		grep -Eo '(\-l|\-\-load-average)(=?|[[:space:]]*)[[:digit:]]+' <<< "${MAKEOPTS}"
	)

	MAKEOPTS="${MAKEJOBS} ${MAKELOAD}"

	local myemakeargs=(
		VBOX_BUILD_PUBLISHER=_Gentoo
		VBOX_ONLY_ADDITIONS=1

		KBUILD_VERBOSE=2

		AS="$(tc-getCC)"
		CC="$(tc-getCC)"
		CXX="$(tc-getCXX)"
		LD="$(tc-getCC)"

		TOOL_GCC3_CC="$(tc-getCC)"
		TOOL_GCC3_CXX="$(tc-getCXX)"
		TOOL_GCC3_LD="$(tc-getCC)"
		TOOL_GCC3_AS="$(tc-getCC)"
		TOOL_GCC3_AR="$(tc-getAR)"
		TOOL_GCC3_OBJCOPY="$(tc-getOBJCOPY)"

		TOOL_GXX3_CC="$(tc-getCC)"
		TOOL_GXX3_CXX="$(tc-getCXX)"
		TOOL_GXX3_LD="$(tc-getCXX)"
		TOOL_GXX3_AS="$(tc-getCXX)"
		TOOL_GXX3_AR="$(tc-getAR)"
		TOOL_GXX3_OBJCOPY="$(tc-getOBJCOPY)"

		TOOL_GCC3_CFLAGS="${CFLAGS}"
		TOOL_GCC3_CXXFLAGS="${CXXFLAGS}"

		VBOX_GCC_OPT="${CXXFLAGS}"
		VBOX_NM="$(tc-getNM)"

		TOOL_YASM_AS=yasm
	)

	MAKE="kmk" emake "${myemakeargs[@]}"

	# Kernel modules must be compiled after the user-space Guest Additions
	# because generated headers from the first build are required.
	BUILD_PARAMS="
		KERN_DIR=/lib/modules/${KV_FULL}/build
		KERNOUT=${KV_OUT_DIR}
		KBUILD_EXTRA_SYMBOLS=${S}/Module.symvers
	"

	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	cd "${S}/out/linux.${ARCH}/release/bin/additions" \
		|| die "Guest Additions output directory not found"

	# Shared folders mount helper
	insinto /sbin
	newins mount.vboxsf mount.vboxsf
	fperms 4755 /sbin/mount.vboxsf

	# OpenRC service
	if use dbus ; then
		newinitd \
			"${FILESDIR}/${PN}-8.initd" \
			${PN}
	else
		newinitd \
			<(sed 's/ dbus\>//' "${FILESDIR}/${PN}-8.initd") \
			${PN}
	fi

	# VBoxService
	insinto /usr/sbin
	newins VBoxService vboxguest-service
	fperms 0755 /usr/sbin/vboxguest-service

	# VBoxControl
	insinto /usr/bin
	doins VBoxControl
	fperms 0755 /usr/bin/VBoxControl

	# VBoxClient and X11 integration
	if use X ; then
		doins VBoxClient
		fperms 0755 /usr/bin/VBoxClient

		doins VBoxDRMClient
		fperms 4755 /usr/bin/VBoxDRMClient

		pushd "${S}/src/VBox/Additions/x11/Installer" &>/dev/null \
			|| die

		newins 98vboxadd-xclient VBoxClient-all
		fperms 0755 /usr/bin/VBoxClient-all

		popd &>/dev/null || die
	fi

	# udev rules
	local udev_rules_dir
	udev_rules_dir="$(get_udevdir)/rules.d"

	dodir "${udev_rules_dir}"

	printf '%s\n' \
		'KERNEL=="vboxguest", OWNER="vboxguest", GROUP="vboxguest", MODE="0660"' \
		'KERNEL=="vboxuser", OWNER="vboxguest", GROUP="vboxguest", MODE="0660"' \
		> "${ED}/${udev_rules_dir}/60-virtualbox-guest-additions.rules" \
		|| die "failed to install udev rules"

	# Desktop autostart
	if use X ; then
		insinto /etc/xdg/autostart
		doins "${FILESDIR}"/vboxclient.desktop
	fi

	# Sample xorg.conf
	if use X ; then
		insinto /usr/share/doc/${PF}
		doins "${FILESDIR}"/xorg.conf.vbox
	fi

	# systemd support when explicitly enabled
	if use systemd ; then
		systemd_dounit "${FILESDIR}/${PN}.service"
	fi
}

pkg_preinst() {
	enewgroup vboxguest
	enewuser vboxguest -1 /bin/sh /dev/null vboxguest

	# Shared folders automount requires vboxsf
	enewgroup vboxsf
}

pkg_postinst() {
	linux-mod_pkg_postinst
	udev_reload

	if ! use X ; then
		elog "USE flag X is disabled."
		elog "Enable it to install VirtualBox X11 Guest Additions."
	fi

	elog ""
	elog "Please add users to the \"vboxguest\" group so they can"
	elog "use seamless mode, automatic resize and clipboard integration."
	elog ""
	elog "The \"vboxsf\" group is used for VirtualBox shared folders."
	elog ""
	elog "For OpenRC, add the service to the default runlevel with:"
	elog ""
	elog "    rc-update add ${PN} default"
	elog ""
	elog "To use the VirtualBox X driver, the sample configuration is:"
	elog ""
	elog "    /usr/share/doc/${PF}/xorg.conf.vbox"
	elog ""
	elog "Shared folders can be mounted with:"
	elog ""
	elog "    mount -t vboxsf <shared_folder_name> <mount_point>"
	elog ""
	elog "Installed VirtualBox Guest Additions version:"
	elog "    ${MY_PV}"
	elog "Oracle build:"
	elog "    ${MY_BUILD}"
	elog ""
	elog "This package is intended for systems running inside"
	elog "a VirtualBox virtual machine."
	elog ""
}

pkg_postrm() {
	linux-mod_pkg_postrm
	udev_reload
}
