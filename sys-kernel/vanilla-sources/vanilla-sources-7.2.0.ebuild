# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

KERNEL_TRIPLET="${PV%.0}"
MACARONI_KTYPE="vanilla"
MACARONI_KVER="${PV}"
MACARONI_KSUFFIX="mark"

EXTRAVERSION="-vanilla-mark"

MOD_DIR_NAME="${PV}-${MACARONI_KTYPE}-${MACARONI_KSUFFIX}"
LINUX_SRCDIR="linux-${PV}"

inherit check-reqs eutils ego savedconfig

DESCRIPTION="Vanilla Sources (and optional binary kernel)"
HOMEPAGE="https://kernel.org"
SRC_URI="https://mirrors.edge.kernel.org/pub/linux/kernel/v7.x/linux-${KERNEL_TRIPLET}.tar.xz -> linux-${KERNEL_TRIPLET}.tar.xz"

LICENSE="GPL-2"
SLOT="7.2"
KEYWORDS="*"

IUSE="acpi-ec binary btrfs custom-cflags dracut ec2 +logo luks lvm mdadm savedconfig sshd sign-modules symlink zfs"

REQUIRED_USE="
	binary? (
		^^ ( dracut )
		btrfs? ( dracut )
		mdadm? ( dracut )
		luks? ( dracut )
		lvm? ( dracut )
		sshd? ( dracut )
	)
	sshd? ( binary )
"

RESTRICT="binchecks strip"

BDEPEND="
	virtual/libelf
	sys-apps/gawk
	binary? (
		app-admin/whip
		sys-apps/whip-catalog
		sys-kernel/dracut
		virtual/dracut-mark
	)
	sign-modules? ( sys-apps/findutils )
"

RDEPEND="
	btrfs? ( sys-fs/btrfs-progs )
	zfs? ( sys-fs/zfs )
	luks? ( sys-fs/cryptsetup )
	lvm? ( sys-fs/lvm2 )
	mdadm? ( sys-fs/mdadm )
"

S="${WORKDIR}/linux-${KERNEL_TRIPLET}"

tweak_config() {
	einfo "Setting $2=$3 in kernel config."

	case "$2" in
		*\*)
			local base="${2%\*}"
			sed -i -e "s/^${base}\(.*\)=.*/${base}\1=${3}/g" "$1"
			;;
		*)
			sed -i -e "/^${2}=/d" "$1"
			echo "${2}=${3}" >> "$1"
			;;
	esac
}

get_vendor() {
	local vendor_string

	vendor_string=$(grep -m1 "vendor_id" /proc/cpuinfo | cut -d ':' -f 2 | tr -d '[:space:]')

	if [[ "${vendor_string}" == *"GenuineIntel"* ]]; then
		echo "INTEL"
	elif [[ "${vendor_string}" == *"AuthenticAMD"* ]]; then
		echo "AMD"
	else
		echo ""
	fi
}

set_kernel_arch() {
	if [ "${REAL_ARCH}" = x86 ]; then
		KERN_ARCH="i686"
	elif [ "${REAL_ARCH}" = amd64 ]; then
		KERN_ARCH="x86_64"
	elif [ "${REAL_ARCH}" = arm ]; then
		KERN_ARCH="arm"
	elif [ "${REAL_ARCH}" = arm64 ]; then
		KERN_ARCH="aarch64"
	else
		die "Architecture '${REAL_ARCH}' not handled in ebuild"
	fi

	KERN_SUFFIX="${MACARONI_KTYPE}-${KERN_ARCH}-${MACARONI_KVER}-${MACARONI_KSUFFIX}"

	export KERN_ARCH
	export KERN_SUFFIX
}

pkg_pretend() {
	if use binary; then
		CHECKREQS_DISK_BUILD="6G"
		check-reqs_pkg_setup
		echo "binary"
	fi
}

get_certs_dir() {
	for subdir in $PF $P linux; do
		certdir=/etc/kernel/certs/$subdir

		if [ -d $certdir ]; then
			if [ ! -e $certdir/signing_key.pem ]; then
				eerror "$certdir exists but missing signing key; exiting."
				exit 1
			fi

			echo $certdir
			return
		fi
	done
}

pkg_setup() {
	export REAL_ARCH="$ARCH"

	unset ARCH
	unset LDFLAGS

	export FEATURESET="standard"

	set_kernel_arch
}

src_prepare() {
	default

	eapply_user

	if use custom-cflags; then
		if ver_test "${PV}" -ge 7.2; then
			eapply "${FILESDIR}/7.2+/more-ISA-levels-and-uarches-for-kernel-7.2.x+.patch" \
				|| die "use-patch 7.2+/more-ISA-levels-and-uarches-for-kernel-7.2.x+.patch failed"
		elif ver_test "${PV}" -ge 7.1; then
			eapply "${FILESDIR}/7.1+/more-ISA-levels-and-uarches-for-kernel-7.1.x+.patch" \
				|| die "use-patch 7.1+/more-ISA-levels-and-uarches-for-kernel-7.1.x+.patch failed"
		else
			eapply "${FILESDIR}/6.16+/more-ISA-levels-and-uarches-for-kernel-6.16+.patch" \
				|| die "use-patch 6.16+/more-ISA-levels-and-uarches-for-kernel-6.16+.patch failed"
		fi
	fi

	cd "${S}" || die

	rm -f .config >/dev/null
	make mrproper || die "make mrproper failed"

	sed -i \
		-e "s/^EXTRAVERSION[[:space:]]*=.*/EXTRAVERSION = ${EXTRAVERSION}/" \
		Makefile || die "failed to set kernel EXTRAVERSION"

	if use savedconfig; then
		einfo "Restoring saved .config ..."

		restore_config .config

		yes "" | make olddefconfig >/dev/null 2>&1 || die

		rm -rf \
			include/config/ \
			include/generated/autoconf.h \
			include/generated/rustc_cfg \
			include/config/*/ \
			2>/dev/null || true
	else
		if [ "${REAL_ARCH}" = amd64 ]; then
			local kern_arch_dir="x86"
			local defconfig="x86_64_defconfig"
		elif [ "${REAL_ARCH}" = x86 ]; then
			local kern_arch_dir="x86"
			local defconfig="i386_defconfig"
		elif [ "${REAL_ARCH}" = arm64 ]; then
			local kern_arch_dir="arm64"
			local defconfig="defconfig"
		elif [ "${REAL_ARCH}" = arm ]; then
			local kern_arch_dir="arm"
			local defconfig="defconfig"
		else
			die "No defconfig found for architecture ${REAL_ARCH}"
		fi

		cp \
			"${WORKDIR}/linux-${KERNEL_TRIPLET}/arch/${kern_arch_dir}/configs/${defconfig}" \
			.config || die
	fi

	tweak_config .config CONFIG_DEBUG* n
	tweak_config .config CONFIG_MODULE_COMPRESS* n
	tweak_config .config CONFIG_MODULE_COMPRESS_NONE y
	tweak_config .config CONFIG_CRYPTO_CRC32C y

	if use acpi-ec; then
		tweak_config .config CONFIG_ACPI_EC_DEBUGFS m
		tweak_config .config CONFIG_DEBUG_FS y
	fi

	if use custom-cflags; then
		MARCH=""

		for _flag in $(python3 -c 'import portage; print(portage.settings["CFLAGS"])'); do
			[[ "$_flag" == -march=* ]] && MARCH="$_flag" && break
		done

		if [ -n "$MARCH" ]; then
			CONFIG_MARCH=""

			if [ "${KERN_ARCH}" = "x86_64" ] || [ "${KERN_ARCH}" = "i686" ]; then
				declare -A MARCH_MAP

				while IFS= read -r line; do
					cfg=$(echo "$line" | grep -oP 'CONFIG_M[A-Z0-9_]+')
					mch=$(echo "$line" | sed 's/.*-march=//;s/[[:space:]].*//')

					[[ "$mch" == "native" ]] && continue

					[ -n "$cfg" ] && [ -n "$mch" ] && MARCH_MAP[$mch]=$cfg
				done < <(
					grep -E '^\s+cflags-\$\(CONFIG_M' arch/x86/Makefile |
						grep 'march='
				)

				SUBARCH=$(echo "$MARCH" | sed 's/.*-march=//')

				if [ "${MARCH_MAP[$SUBARCH]}" ]; then
					CONFIG_MARCH="${MARCH_MAP[$SUBARCH]}"
					einfo "Optimizing kernel for ${CONFIG_MARCH} (matched -march=${SUBARCH})"
				elif [[ "$MARCH" =~ (native) ]] && [ -n "$(get_vendor)" ]; then
					VENDOR=$(get_vendor)
					CONFIG_MARCH="CONFIG_MNATIVE_${VENDOR}"
					einfo "Detected -march=native on ${VENDOR}, using ${CONFIG_MARCH}"
				fi

				if [ -z "$CONFIG_MARCH" ] && [ -n "$(get_vendor)" ]; then
					VENDOR=$(get_vendor)
					CONFIG_MARCH="CONFIG_MNATIVE_${VENDOR}"
					einfo "Subarch '${SUBARCH}' not mapped, using ${CONFIG_MARCH}"
				fi

			elif [ "${KERN_ARCH}" = "arm" ] || [ "${KERN_ARCH}" = "aarch64" ]; then
				if [[ $MARCH =~ (native) ]]; then
					ARM_VENDOR=""

					if [ -f /proc/cpuinfo ]; then
						ARM_VENDOR=$(
							grep "CPU implementer" /proc/cpuinfo |
								head -1 |
								awk '{print $3}'
						)

						case $ARM_VENDOR in
							0x41) ARM_VENDOR="arm";;
							0x43) ARM_VENDOR="cavium";;
							0x46) ARM_VENDOR="freescale";;
							0x49) ARM_VENDOR="intel";;
							0x4d) ARM_VENDOR="motorola";;
							0x50) ARM_VENDOR="primecell";;
							0x51) ARM_VENDOR="arm";;
							0x56) ARM_VENDOR="marvell";;
							0x58) ARM_VENDOR="amd";;
							0x69) ARM_VENDOR="intel";;
							0x6b) ARM_VENDOR="broadcom";;
							0x6c) ARM_VENDOR="nvidia";;
							0x70) ARM_VENDOR="apm";;
							0xc0) ARM_VENDOR="qualcomm";;
							*) ;;
						esac
					fi

					if [ -n "$ARM_VENDOR" ]; then
						ARM_CONFIG="CONFIG_${ARM_VENDOR^^}_OPTIMIZED"

						if grep -q "${ARM_CONFIG}" arch/arm/Makefile 2>/dev/null \
							|| grep -q "${ARM_CONFIG}" arch/arm64/Makefile 2>/dev/null; then
							einfo "Detected -march=native on ARM ${ARM_VENDOR}, using ${ARM_CONFIG}"
							CONFIG_MARCH="${ARM_CONFIG}"
						else
							ewarn "No ${ARM_VENDOR} optimized config found, compiling generic ARM kernel."
						fi
					else
						ewarn "Could not detect ARM vendor for native optimization, compiling generic kernel."
					fi
				else
					ARM_SUBARCH="$(echo ${MARCH} | sed 's/march=//;s/-//g')"
					ARM_CONFIG="CONFIG_CPU_${ARM_SUBARCH^^}"

					if grep -q "${ARM_CONFIG}" arch/arm/Makefile 2>/dev/null \
						|| grep -q "${ARM_CONFIG}" arch/arm64/Makefile 2>/dev/null; then
						einfo "Optimizing ${KERN_ARCH} kernel for ${ARM_CONFIG}"
						CONFIG_MARCH="${ARM_CONFIG}"
					else
						ewarn "Could not find optimized settings for ${MARCH}, compiling generic ${KERN_ARCH} kernel."
					fi
				fi
			else
				ewarn "Custom-cflags not supported for architecture ${KERN_ARCH}, compiling generic kernel."
			fi

			if [ -n "$CONFIG_MARCH" ]; then
				tweak_config .config CONFIG_GENERIC_CPU n
				tweak_config .config "$CONFIG_MARCH" y
			elif [ -z "$MARCH_MAP[$SUBARCH]" ] && [ -z "$CONFIG_MARCH" ]; then
				ewarn "No optimization found for ${MARCH}, compiling generic kernel."
			fi
		fi
	fi

	if use ec2; then
		tweak_config .config CONFIG_BLK_DEV_NVME y
		tweak_config .config CONFIG_XEN_BLKDEV_FRONTEND y
		tweak_config .config CONFIG_XEN_BLKDEV_BACKEND y
		tweak_config .config CONFIG_IXGBEVF y
	fi

	if use logo; then
		tweak_config .config CONFIG_LOGO y

		cp \
			"${FILESDIR}/latest/macaroni-os_logo_clut224.ppm" \
			"${S}/drivers/video/logo/logo_linux_clut224.ppm" \
			|| die

		ewarn "Linux kernel frame buffer boot logo is now enabled with a custom MacaroniOS pixmap."
		ewarn "The new logo can be viewed at /usr/src/linux/drivers/video/logo/logo_linux_clut224.ppm"
		ewarn "Remove the quiet kernel parameter (from params in /etc/boot.conf, and re-run boot-update)."
		ewarn "This will ensure the custom kernel logo is displayed during boot over frame buffer."
		ewarn ""
	fi

	if use sign-modules; then
		certs_dir=$(get_certs_dir)

		if [ -z "$certs_dir" ]; then
			eerror "No certs dir found in /etc/kernel/certs; aborting."
			die
		fi

		tweak_config .config CONFIG_MODULE_SIG y
		tweak_config .config CONFIG_MODULE_SIG_FORCE n
		tweak_config .config CONFIG_MODULE_SIG_ALL n
		tweak_config .config CONFIG_MODULE_SIG_HASH "sha512"
		tweak_config .config CONFIG_MODULE_SIG_KEY "${certs_dir}/signing_key.pem"
		tweak_config .config CONFIG_SYSTEM_TRUSTED_KEYRING y
		tweak_config .config CONFIG_SYSTEM_EXTRA_CERTIFICATE y
		tweak_config .config CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE 4096
		tweak_config .config CONFIG_MODULE_SIG_SHA512 y

		echo
		einfo "Using certificate directory of $certs_dir for kernel module signing."
		echo

		ewarn "This kernel will ALLOW non-signed modules to be loaded with a WARNING."
		ewarn "To enable strict enforcement, YOU MUST add module.sig_enforce=1 as a kernel boot"
		ewarn "parameter (to params in /etc/boot.conf, and re-run boot-update.)"
		ewarn ""
	fi

	yes "" | make oldconfig >/dev/null 2>&1 || die

	rm -rf \
		include/config/ \
		include/generated/autoconf.h \
		include/generated/rustc_cfg \
		include/config/*/ \
		2>/dev/null || true

	cp .config "${T}/config" || die
}

src_compile() {
	! use binary && return

	cd "${S}" || die

	make mrproper || die "make mrproper failed"

	install -d "${WORKDIR}/build"

	cp "${T}/config" "${WORKDIR}/build/.config" \
		|| die "couldn't copy kernel config"

	if [ "${REAL_ARCH}" = amd64 ] || [ "${REAL_ARCH}" = x86 ]; then
		make ${MAKEOPTS} \
			O="${WORKDIR}/build" \
			bzImage || die "kernel build failure"

		make ${MAKEOPTS} \
			O="${WORKDIR}/build" \
			modules || die "modules build failure"

	elif [ "${REAL_ARCH}" = arm64 ]; then
		make ${MAKEOPTS} \
			O="${WORKDIR}/build" \
			Image modules dtbs || die "kernel build failure"

	elif [ "${REAL_ARCH}" = arm ]; then
		make ${MAKEOPTS} \
			O="${WORKDIR}/build" \
			zImage modules dtbs || die "kernel build failure"

	else
		die "Binary kernel build not supported for architecture ${REAL_ARCH}"
	fi
}

src_install() {
	dodir /usr/src

	cp -a \
		"${S}" \
		"${D}/usr/src/${LINUX_SRCDIR}" \
		|| die

	cd "${D}/usr/src/${LINUX_SRCDIR}" || die

	make mrproper || die

	cp "${T}/config" .config || die

	use binary || return

	make ${MAKEOPTS} \
		O="${WORKDIR}/build" \
		INSTALL_MOD_PATH="${D}" \
		modules_install || die "modules install failure"

	insinto /boot

	if [ "${REAL_ARCH}" = amd64 ] || [ "${REAL_ARCH}" = x86 ]; then
		newins \
			"${WORKDIR}/build/arch/x86/boot/bzImage" \
			"vmlinuz-${KERN_SUFFIX}.tmp"

	elif [ "${REAL_ARCH}" = arm64 ]; then
		newins \
			"${WORKDIR}/build/arch/arm64/boot/Image" \
			"vmlinuz-${KERN_SUFFIX}.tmp"

	elif [ "${REAL_ARCH}" = arm ]; then
		newins \
			"${WORKDIR}/build/arch/arm/boot/zImage" \
			"vmlinuz-${KERN_SUFFIX}.tmp"

	else
		die "Binary kernel installation not supported for architecture ${REAL_ARCH}"
	fi

	newins \
		"${WORKDIR}/build/System.map" \
		"System.map-${KERN_SUFFIX}.tmp"

	newins \
		"${WORKDIR}/build/.config" \
		"config-${KERN_SUFFIX}.tmp"

	make prepare || die
	make scripts || die
	make modules_prepare || die

	rm -f "${D}"/lib/modules/*/source || die
	rm -f "${D}"/lib/modules/*/build || die

	local moddir
	moddir="$(make -s -C "${WORKDIR}/build" kernelrelease)" || die

	ln -s \
		"/usr/src/${LINUX_SRCDIR}" \
		"${D}/lib/modules/${moddir}/source" || die

	ln -s \
		"/usr/src/${LINUX_SRCDIR}" \
		"${D}/lib/modules/${moddir}/build" || die

	cp \
		"${WORKDIR}/build/System.map" \
		"${D}/usr/src/${LINUX_SRCDIR}/" || die

	cp \
		"${WORKDIR}/build/Module.symvers" \
		"${D}/usr/src/${LINUX_SRCDIR}/" || die

	if use sign-modules; then
		find "${D}/lib/modules" \
			-iname '*.ko' \
			! -iname '*.ko.xz' \
			-exec "${WORKDIR}/build/scripts/sign-file" sha512 \
			"${certs_dir}/signing_key.pem" \
			"${certs_dir}/signing_key.x509" {} \; || die

		exeinto "/usr/src/${LINUX_SRCDIR}/scripts"
		doexe "${WORKDIR}/build/scripts/sign-file"
	fi

	mv \
		"${D}/lib/modules/${moddir}" \
		"${D}/lib/modules/${moddir}.tmp" || die
}

pkg_postinst() {
	if use binary; then
		ego_pkg_preinst

		if use dracut; then
			if [[ -f "/boot/initramfs-${KERN_SUFFIX}" ]]; then
				rm -f "/boot/initramfs-${KERN_SUFFIX}.old"

				mv \
					"/boot/initramfs-${KERN_SUFFIX}" \
					"/boot/initramfs-${KERN_SUFFIX}.old" || die
			fi
		fi

		for i in vmlinuz System.map config; do
			if [[ -f "/boot/${i}-${KERN_SUFFIX}" ]]; then
				if use savedconfig; then
					if [[ -f "/boot/${i}-${KERN_SUFFIX}.old" ]]; then
						rm "/boot/${i}-${KERN_SUFFIX}.old"
					fi

					einfo "Preserving /boot/${i}-${KERN_SUFFIX}"

					mv \
						"/boot/${i}-${KERN_SUFFIX}" \
						"/boot/${i}-${KERN_SUFFIX}.old" || die
				else
					rm "/boot/${i}-${KERN_SUFFIX}" || die
				fi
			fi

			mv \
				"/boot/${i}-${KERN_SUFFIX}.tmp" \
				"/boot/${i}-${KERN_SUFFIX}" || die
		done

		if [[ -d "/lib/modules/${MOD_DIR_NAME}" ]]; then
			if use savedconfig; then
				if [[ -d "/lib/modules/${MOD_DIR_NAME}.old" ]]; then
					rm -r "/lib/modules/${MOD_DIR_NAME}.old"
				fi

				einfo "Preserving /lib/modules/${MOD_DIR_NAME}"

				mv \
					"/lib/modules/${MOD_DIR_NAME}" \
					"/lib/modules/${MOD_DIR_NAME}.old" || die
			else
				rm -r "/lib/modules/${MOD_DIR_NAME}" || die
			fi
		fi

		mv \
			"/lib/modules/${MOD_DIR_NAME}.tmp" \
			"/lib/modules/${MOD_DIR_NAME}" || die

		if use dracut; then
			dracut_modules_pre="
				$(use btrfs && echo btrfs)
				$(use luks && echo crypt)
				$(use lvm && echo lvm)
				$(use mdadm && echo mdraid)
				$(use sshd && echo sshd)
			"

			dracut_drivers_pre="
				$(use luks && echo dm-crypt)
			"

			DRACUT_ADD_MODULES="$(echo ${dracut_modules_pre} | xargs)" \
			DRACUT_ADD_DRIVERS="$(echo ${dracut_drivers_pre} | xargs)" \
			KVER="${KERN_ARCH}-${MACARONI_KVER}" \
			KTYPE="${MACARONI_KTYPE}" \
			KSUFFIX="${MACARONI_KSUFFIX}" \
			KMODDIR="/lib/modules/${MOD_DIR_NAME}" \
			whip h initramfs.generate_with_dracut || die
		fi

		if [[ -d "${ROOT%/}/lib/modules/${MOD_DIR_NAME}" ]]; then
			depmod -a "${MOD_DIR_NAME}" || die
		fi
	fi

	if use symlink; then
		local linux_link="${ROOT%/}/usr/src/linux"

		if [[ -e "${linux_link}" || -h "${linux_link}" ]]; then
			rm -f "${linux_link}" || die
		fi

		ln -s \
			"${LINUX_SRCDIR}" \
			"${linux_link}" || die

		einfo "${linux_link} -> ${LINUX_SRCDIR}"
	fi

	if use binary; then
		ego_pkg_postinst
	fi
}

# vim: filetype=ebuild
