# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2+ )

inherit xdg-utils gnome2 pax-utils python-r1 udev eapi7-ver

MY_PV="${PV%_p*}"
MY_BUILD="${PV##*_p}"
MY_P="${MY_PV}-${MY_BUILD}"

DESCRIPTION="Family of powerful x86 virtualization products for enterprise and home use"
HOMEPAGE="https://www.virtualbox.org/"
SRC_URI="
	https://download.virtualbox.org/virtualbox/${MY_PV}/VirtualBox-${MY_P}-Linux_amd64.run
		-> VirtualBox-${MY_P}-Linux_amd64.run
	https://download.virtualbox.org/virtualbox/${MY_PV}/Oracle_VirtualBox_Extension_Pack-${MY_PV}.vbox-extpack
		-> Oracle_VM_VirtualBox_Extension_Pack-${MY_P}.tar.gz
	sdk? (
		https://download.virtualbox.org/virtualbox/${MY_PV}/VirtualBoxSDK-${MY_P}.zip
			-> VirtualBoxSDK-${MY_P}.zip
	)
"

LICENSE="GPL-2 PUEL"
SLOT="0"
KEYWORDS="*"
IUSE="+additions doc headless python vboxwebsrv rdesktop-vrdp sdk"

DEPEND="
	app-arch/unzip
	${PYTHON_DEPS}
"

RDEPEND="
	!app-emulation/virtualbox-additions
	~app-emulation/virtualbox-modules-${PV}

	!headless? (
		app-crypt/mit-krb5
		dev-libs/glib
		media-libs/fontconfig
		media-libs/freetype
		media-libs/libpng
		media-libs/libsdl[X]
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libXft
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
	)

	dev-libs/libxml2
	sys-fs/lvm2

	x11-libs/libXau
	x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libXdmcp

	${PYTHON_DEPS}
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

S="${WORKDIR}"

QA_PREBUILT="opt/VirtualBox/*"

PYTHON_UPDATER_IGNORE="1"

src_unpack() {
	sh "${DISTDIR}/VirtualBox-${MY_P}-Linux_amd64.run" \
		--noexec \
		--keep \
		--nox11 \
		|| die

	cp -a install/. "${S}/" || die
	rm -rf install || die

	unpack ./VirtualBox.tar.bz2

	mkdir "${S}/Oracle_VirtualBox_Extension_Pack" || die

	pushd "${S}/Oracle_VirtualBox_Extension_Pack" &>/dev/null || die

	unpack "Oracle_VM_VirtualBox_Extension_Pack-${MY_P}.tar.gz"

	popd &>/dev/null || die

	if use sdk ; then
		unpack "VirtualBoxSDK-${MY_P}.zip"
	fi
}

src_configure() {
	:;
}

src_compile() {
	:;
}

src_install() {
	# create VirtualBox configuration files
	insinto /etc/vbox
	newins "${FILESDIR}/${PN}-config" vbox.cfg

	if ! use headless ; then
		newmenu "${FILESDIR}/${PN}.desktop-2" "${PN}.desktop"

		# set up symlinks
		dosym \
			../../../../opt/VirtualBox/virtualbox.xml \
			/usr/share/mime/packages/virtualbox.xml

		local size ico icofile

		for size in 16 24 32 48 64 72 96 128 256 ; do
			pushd "${S}/icons/${size}x${size}" &>/dev/null || die

			if [[ -f "virtualbox.png" ]] ; then
				doicon -s "${size}" virtualbox.png
			fi

			for ico in hdd ova ovf vbox{,-extpack} vdi vdh vmdk ; do
				icofile="virtualbox-${ico}.png"

				if [[ -f "${icofile}" ]] ; then
					doicon -s "${size}" "${icofile}"
				fi
			done

			popd &>/dev/null || die
		done

		doicon -s scalable "${S}/icons/scalable/virtualbox.svg"

		insinto /usr/share/pixmaps
		newins "${S}/icons/48x48/virtualbox.png" "${PN}.png"
	fi

	#
	# Oracle VirtualBox Extension Pack
	#
	# Important:
	# The directory name must match the name declared by ExtPack.xml:
	#
	# Oracle VirtualBox Extension Pack
	#
	# VirtualBox converts spaces to underscores for the ExtensionPacks
	# directory, resulting in:
	#
	# Oracle_VirtualBox_Extension_Pack
	#
	pushd "${S}/Oracle_VirtualBox_Extension_Pack" &>/dev/null || die

	insinto /opt/VirtualBox/ExtensionPacks/Oracle_VirtualBox_Extension_Pack

	doins -r "linux.${ARCH}"
	doins ExtPack* PXE-Intel.rom

	popd &>/dev/null || die

	rm -rf "${S}/Oracle_VirtualBox_Extension_Pack"

	insinto /opt/VirtualBox
	dodir /opt/bin

	if use doc ; then
		dodoc UserManual.pdf

		docompress -x "/usr/share/doc/${PF}/qt"

		docinto qt
		dodoc UserManual.q{ch,hc}
	fi

	if use sdk ; then
		doins -r sdk
	fi

	if use additions ; then
		doins -r additions
	fi

	if use vboxwebsrv ; then
		doins vboxwebsrv

		fowners root:vboxusers /opt/VirtualBox/vboxwebsrv
		fperms 0750 /opt/VirtualBox/vboxwebsrv

		dosym \
			../../opt/VirtualBox/VBox.sh \
			/opt/bin/vboxwebsrv

		newinitd \
			"${FILESDIR}/vboxwebsrv-initd" \
			vboxwebsrv

		newconfd \
			"${FILESDIR}/vboxwebsrv-confd" \
			vboxwebsrv
	fi

	if use rdesktop-vrdp ; then
		doins rdesktop-vrdp
		doins -r rdesktop-vrdp-keymaps

		fperms 0750 /opt/VirtualBox/rdesktop-vrdp

		dosym \
			../../opt/VirtualBox/rdesktop-vrdp \
			/opt/bin/rdesktop-vrdp
	fi

	# This binary package provides VBoxPython2.so.
	use python && doins VBoxPython2.so

	rm -rf \
		src \
		rdesktop* \
		deffiles \
		install* \
		routines.sh \
		runlevel.sh \
		vboxdrv.sh \
		VBox.sh \
		VBox.png \
		vboxnet.sh \
		additions \
		VirtualBox.desktop \
		VirtualBox.tar.bz2 \
		LICENSE \
		VBoxSysInfo.sh \
		vboxwebsrv \
		webtest \
		vbox-create-usb-node.sh \
		90-vbox-usb.fdi \
		uninstall.sh \
		vboxshell.py \
		vboxdrv-pardus.py \
		VBoxPython?_*.so

	if use headless ; then
		rm -rf VirtualBox{,VM} VBoxKeyboard.so
	fi

	doins -r * || die

	# Work around unsupported $ORIGIN/.. in VBoxC.so
	dosym ../VBoxVMM.so \
		/opt/VirtualBox/components/VBoxVMM.so

	dosym ../VBoxRT.so \
		/opt/VirtualBox/components/VBoxRT.so

	dosym ../VBoxDDU.so \
		/opt/VirtualBox/components/VBoxDDU.so

	dosym ../VBoxXPCOM.so \
		/opt/VirtualBox/components/VBoxXPCOM.so

	local each

	for each in \
		VBoxManage \
		VBoxSVC \
		VBoxExtPackHelperApp \
		$(usex headless '' VirtualBox)
	do
		fowners root:vboxusers "/opt/VirtualBox/${each}"
		fperms 0750 "/opt/VirtualBox/${each}"
		pax-mark -m "${ED%/}/opt/VirtualBox/${each}"
	done

	# VBoxNetAdpCtl, VBoxNetDHCP and VBoxNetNAT need SUID root.
	for each in \
		VBoxNetAdpCtl \
		VBoxNetDHCP \
		VBoxNetNAT \
		$(usex headless '' VirtualBoxVM)
	do
		fowners root:vboxusers "/opt/VirtualBox/${each}"
		fperms 4750 "/opt/VirtualBox/${each}"
		pax-mark -m "${ED%/}/opt/VirtualBox/${each}"
	done

	if ! use headless ; then
		fowners root:vboxusers /opt/VirtualBox/VBoxHeadless
		fperms 4510 /opt/VirtualBox/VBoxHeadless
		pax-mark -m "${ED%/}/opt/VirtualBox/VBoxHeadless"

		dosym \
			../VirtualBox/VBox.sh \
			/opt/bin/VirtualBox
	else
		fowners root:vboxusers /opt/VirtualBox/VBoxHeadless
		fperms 4510 /opt/VirtualBox/VBoxHeadless
		pax-mark -m "${ED%/}/opt/VirtualBox/VBoxHeadless"
	fi

	exeinto /opt/VirtualBox

	newexe \
		"${FILESDIR}/${PN}-3-wrapper" \
		"VBox.sh"

	fowners root:vboxusers /opt/VirtualBox/VBox.sh
	fperms 0750 /opt/VirtualBox/VBox.sh

	dosym \
		../VirtualBox/VBox.sh \
		/opt/bin/VBoxManage

	dosym \
		../VirtualBox/VBox.sh \
		/opt/bin/VBoxVRDP

	dosym \
		../VirtualBox/VBox.sh \
		/opt/bin/VBoxHeadless

	# Environment variable for third-party tools
	echo -n "VBOX_APP_HOME=/opt/VirtualBox" \
		> "${T}/90virtualbox" \
		|| die

	doenvd "${T}/90virtualbox"

	local udevdir
	udevdir="$(get_udevdir)"

	insinto "${udevdir}/rules.d"

	doins "${FILESDIR}/10-virtualbox.rules"

	sed \
		"s@%UDEVDIR%@${udevdir}@" \
		-i "${ED%/}${udevdir}/rules.d/10-virtualbox.rules" \
		|| die

	# Move udev scripts into the proper udev directory
	mv \
		"${ED%/}/opt/VirtualBox/VBoxCreateUSBNode.sh" \
		"${ED%/}${udevdir}" \
		|| die

	fperms 0750 "${udevdir}/VBoxCreateUSBNode.sh"
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update

	udevadm control --reload-rules
	udevadm trigger --subsystem-match=usb

	elog ""

	if ! use headless ; then
		elog "To launch VirtualBox just type: \"VirtualBox\""
		elog ""
	fi

	elog "You must be in the vboxusers group to use VirtualBox."
	elog ""
	elog "For advanced networking setups you should emerge:"
	elog "net-misc/bridge-utils and sys-apps/usermode-utilities"
	elog ""
	elog "Please visit https://www.virtualbox.org/wiki/Editions for"
	elog "an overview of the different features of ${PN}."
	elog ""

	if [[ -e "${ROOT}/etc/udev/rules.d/10-virtualbox.rules" ]] ; then
		elog "Please remove:"
		elog ""
		elog "    ${ROOT}/etc/udev/rules.d/10-virtualbox.rules"
		elog ""
		elog "or USB support in ${PN} may not work."
	fi
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
