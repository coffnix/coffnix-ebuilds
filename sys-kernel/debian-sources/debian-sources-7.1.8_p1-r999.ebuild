# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
KERNEL_TRIPLET="7.1.8"
MACARONI_KTYPE="debian"
MACARONI_KSUFFIX="debian1-mark"
REVISION_SUFFIX="-sid"
EXTRAVERSION="-sid-debian1-mark"
LINUX_SRCDIR="linux-7.1.8-sid-debian1-mark"
MOD_DIR_NAME="7.1.8-sid-debian1-mark"
inherit check-reqs eutils ego savedconfig

DESCRIPTION="Debian Sources (and optional binary kernel)"
HOMEPAGE="https://packages.debian.org/unstable/kernel/"
SRC_URI="
https://deb.debian.org/debian/pool/main/l/linux/linux_7.1.8-1.debian.tar.xz -> linux_7.1.8-1.debian.tar.xz
https://mirrors.edge.kernel.org/pub/linux/kernel/v7.x/linux-7.1.8.tar.xz -> linux-7.1.8.tar.xz"
LICENSE="GPL-2"
SLOT=""sid/7.1.8_p1""
KEYWORDS="*"
IUSE="acpi-ec binary btrfs custom-cflags dracut ec2 +logo luks lvm mdadm savedconfig sshd sign-modules zfs"
REQUIRED_USE="binary? (
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
RDEPEND="sys-apps/gawk
	dracut? (
		sys-apps/whip-catalog
		sys-kernel/dracut
		virtual/dracut-mark
	)
	
"
DEPEND="virtual/libelf
	btrfs? ( sys-fs/btrfs-progs )
	zfs? ( sys-fs/zfs )
	luks? ( sys-fs/cryptsetup )
	lvm? ( sys-fs/lvm2 )
	mdadm? ( sys-fs/mdadm )
	
"
S="${WORKDIR}/linux-${KERNEL_TRIPLET}"
# Helper functions
get_patch_list() {
	[[ -z "${1}" ]] && die "No patch series file specified"
	local patch_series="${1}"
	while read line ; do
		if [[ "${line:0:1}" != "#" ]] ; then
			echo "${line}"
		fi
	done < "${patch_series}"
}

tweak_config() {
	einfo "Setting $2=$3 in kernel config."
	case "$2" in
		*\*)
			# Wildcard: expand to sed pattern (e.g., CONFIG_DEBUG* → CONFIG_DEBUG.*)
			local base="${2%\*}"
			sed -i -e "s/^${base}\(.*\)=.*/${base}\1=${3}/g" "$1"
			;;
		*)
			# Exact: remove old line, append new
			sed -i -e "/^${2}=/d" "$1"
			echo "${2}=${3}" >> "$1"
			;;
	esac
}

get_vendor() {
	vendor_string=$(grep vendor /proc/cpuinfo | uniq | cut -d ':' -f 2)
	vendor=$([[ ${vendor_string^^} =~ (INTEL)|(AMD) ]] && echo ${BASH_REMATCH[0]})
	echo $vendor
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	if use binary ; then
		CHECKREQS_DISK_BUILD="6G"
		check-reqs_pkg_setup
		echo "binary"
	fi
}

get_certs_dir() {
	# find a certificate dir in /etc/kernel/certs/ that contains signing cert for modules.
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
	unset ARCH; unset LDFLAGS #will interfere with Makefile if set
	export FEATURESET="standard"
}

src_prepare() {
	default
	# Apply Debian patchset
	for debpatch in $( get_patch_list "${WORKDIR}/debian/patches/series" ); do
		eapply -p1 "${WORKDIR}/debian/patches/${debpatch}"
	done

	# do not include debian devs certificates
	rm -rf "${WORKDIR}"/debian/certs

	# remove references to debian uefi certs
	sed -i -e 's|\${CURDIR}\/debian\/certs\/debian-uefi-certs\.pem||g' "${WORKDIR}"/debian/rules.gen

	cd "${S}" || die
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile || die
	sed -i -e 's:#export\tINSTALL_PATH:export\tINSTALL_PATH:' Makefile || die
	rm -f .config >/dev/null
	cp -a "${WORKDIR}"/debian "${T}"
	make -s mrproper || die "make mrproper failed"
	cp -aR "${WORKDIR}"/debian "${S}"/debian

# patches common to all kernel versions

	# Apply USE-gated patches (applied before kernel config)
	if use custom-cflags; then
		eapply "${FILESDIR}/7.1+/more-ISA-levels-and-uarches-for-kernel-7.1.x+.patch" || die "use-patch 7.1+/more-ISA-levels-and-uarches-for-kernel-7.1.x+.patch failed"
	fi

	# patches for this particular branch (applied via PATCHES array, not here)

	if use savedconfig; then
		einfo Restoring saved .config ...
		restore_config .config
	else
		cp "${FILESDIR}"/config-extract-6.6 ./config-extract || die
		chmod +x config-extract || die
	fi

	# Set up arch-specific variables and this will fail if run in pkg_setup()
	# since ARCH can be unset there:
	if [ "${REAL_ARCH}" = x86 ]; then
		export DEB_ARCH="i386"
		export DEB_SUBARCH="686-pae"
		export KERN_ARCH="i686"
	elif [ "${REAL_ARCH}" = amd64 ]; then
		export DEB_ARCH="amd64"
		export DEB_SUBARCH="amd64"
		export KERN_ARCH="x86_64"
	elif [ "${REAL_ARCH}" = arm ]; then
		export DEB_ARCH="arm"
		export DEB_SUBARCH="arm"
		export KERN_ARCH="arm"
	elif [ "${REAL_ARCH}" = arm64 ]; then
		export DEB_ARCH="arm64"
		export DEB_SUBARCH="arm64"
		export KERN_ARCH="aarch64"
	else
		die "Architecture '${REAL_ARCH}' not handled in ebuild"
	fi
	# like "debian-x86_64-6.12.38-trixie-debian1-mark"
	# EXTRAVERSION/MOD_DIR_NAME/REVISION_SUFFIX provided by generator (use ${PR} from ebuild filename)
	# MACARONI_KVER = KERNEL_TRIPLET + REVISION_SUFFIX (no duplicate ARCH)
	MACARONI_KVER="${KERNEL_TRIPLET}${REVISION_SUFFIX}"
	export KERN_SUFFIX="${MACARONI_KTYPE}-${KERN_ARCH}-${MACARONI_KVER}-${MACARONI_KSUFFIX}"

	if ! use savedconfig; then
		./config-extract ${DEB_ARCH} ${FEATURESET} ${DEB_SUBARCH} || die
	fi

	# Apply unconditional options (wildcards supported, applied in order)
	tweak_config .config CONFIG_DEBUG* n
	tweak_config .config CONFIG_MODULE_COMPRESS* n
	tweak_config .config CONFIG_MODULE_COMPRESS_NONE y
	tweak_config .config CONFIG_CRYPTO_CRC32C y

	# Apply USE-gated kernel config options
	if use acpi-ec; then
		tweak_config .config CONFIG_ACPI_EC_DEBUGFS m
		tweak_config .config CONFIG_DEBUG_FS y  # custom-cflags
	fi  # if ne $name "unconditional"
	if use custom-cflags; then
		# Detect architecture and apply custom-cflags optimization (ISA patch applied via use_patches in src_prepare)
		# Extract -march flag from CFLAGS using bash word splitting (handles tabs/spaces/quotes)
		MARCH=""
		for _flag in $(python3 -c 'import portage; print(portage.settings["CFLAGS"])'); do
			[[ "$_flag" == -march=* ]] && MARCH="$_flag" && break
		done

		if [ -n "$MARCH" ]; then
			CONFIG_MARCH=""
			if [ "${KERN_ARCH}" = "x86_64" ] || [ "${KERN_ARCH}" = "i686" ]; then
				# Build march-to-CONFIG mapping from arch/x86/Makefile (after ISA patch applied)
				# Exclude "-march=native" entries: they map multiple configs (CONFIG_MNATIVE_INTEL,
				# CONFIG_MNATIVE_AMD) to the same "native" key, causing last-write-wins collisions.
				# Those are handled separately by the vendor-detection fallback below.
				declare -A MARCH_MAP
				while IFS= read -r line; do
					cfg=$(echo "$line" | grep -oP 'CONFIG_M[A-Z0-9_]+')
					mch=$(echo "$line" | sed 's/.*-march=//;s/[[:space:]].*//')
					# Skip "native" — handled by vendor detection
					[[ "$mch" == "native" ]] && continue
					[ -n "$cfg" ] && [ -n "$mch" ] && MARCH_MAP[$mch]=$cfg
				done < <(grep -E '^\s+cflags-\$\(CONFIG_M' arch/x86/Makefile | grep 'march=')

				# Extract subarch from -march=subarch
				SUBARCH=$(echo "$MARCH" | sed 's/.*-march=//')

				# Try exact match first
				if [ "${MARCH_MAP[$SUBARCH]}" ]; then
					CONFIG_MARCH="${MARCH_MAP[$SUBARCH]}"
					einfo "Optimizing kernel for ${CONFIG_MARCH} (matched -march=${SUBARCH})"
				elif [[ "$MARCH" =~ (native) ]] && [ -n "$(get_vendor)" ]; then
					VENDOR=$(get_vendor)
					CONFIG_MARCH="CONFIG_MNATIVE_${VENDOR}"
					einfo "Detected -march=native on ${VENDOR}, using ${CONFIG_MARCH}"
				fi

				# Fallback: vendor native if specific match failed
				if [ -z "$CONFIG_MARCH" ] && [ -n "$(get_vendor)" ]; then
					VENDOR=$(get_vendor)
					CONFIG_MARCH="CONFIG_MNATIVE_${VENDOR}"
					einfo "Subarch '${SUBARCH}' not mapped, using ${CONFIG_MARCH}"
				fi
			elif [ "${KERN_ARCH}" = "arm" ] || [ "${KERN_ARCH}" = "aarch64" ]; then
				# ARM architecture - check for vendor-specific optimization
				if [[ $MARCH =~ (native) ]]; then
					ARM_VENDOR=""
					if [ -f /proc/cpuinfo ]; then
						ARM_VENDOR=$(grep "CPU implementer" /proc/cpuinfo | head -1 | awk '{print $3}')
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
						if grep -q "${ARM_CONFIG}" arch/arm/Makefile 2>/dev/null || grep -q "${ARM_CONFIG}" arch/arm64/Makefile 2>/dev/null; then
							einfo "Detected -march=native on ARM ${ARM_VENDOR}, using ${ARM_CONFIG}"
							CONFIG_MARCH="${ARM_CONFIG}"
						else
							ewarn "No ${ARM_VENDOR} optimized config found, compiling generic ARM kernel."
						fi
					else
						ewarn "Could not detect ARM vendor for native optimization, compiling generic kernel."
					fi
				else
					# ARM specific subarch - try to match to kernel config
					ARM_SUBARCH="$(echo ${MARCH} | sed 's/march=//;s/-//g')"
					ARM_CONFIG="CONFIG_CPU_${ARM_SUBARCH^^}"
					if grep -q "${ARM_CONFIG}" arch/arm/Makefile 2>/dev/null || grep -q "${ARM_CONFIG}" arch/arm64/Makefile 2>/dev/null; then
						einfo "Optimizing ${KERN_ARCH} kernel for ${ARM_CONFIG}"
						CONFIG_MARCH="${ARM_CONFIG}"
					else
						ewarn "Could not find optimized settings for ${MARCH}, compiling generic ${KERN_ARCH} kernel."
					fi
				fi
			else
				ewarn "Custom-cflags not supported for architecture ${KERN_ARCH}, compiling generic kernel."
			fi

			# Apply if found
			if [ -n "$CONFIG_MARCH" ]; then
				tweak_config .config CONFIG_GENERIC_CPU n
				tweak_config .config "$CONFIG_MARCH" y
			elif [ -z "$MARCH_MAP[$SUBARCH]" ] && [ -z "$CONFIG_MARCH" ]; then
				ewarn "No optimization found for ${MARCH}, compiling generic kernel."
			fi
		fi  # custom-cflags
	fi  # if ne $name "unconditional"
	if use ec2; then
		tweak_config .config CONFIG_BLK_DEV_NVME y
		tweak_config .config CONFIG_XEN_BLKDEV_FRONTEND y
		tweak_config .config CONFIG_XEN_BLKDEV_BACKEND y
		tweak_config .config CONFIG_IXGBEVF y  # custom-cflags
	fi  # if ne $name "unconditional"
	if use logo; then
		tweak_config .config CONFIG_LOGO y
		cp "${FILESDIR}"/latest/macaroni-os_logo_clut224.ppm "$S"/drivers/video/logo/logo_linux_clut224.ppm || die
		ewarn "Linux kernel frame buffer boot logo is now enabled with a custom MacaroniOS pixmap."
		ewarn "The new logo can be viewed at /usr/src/linux/drivers/video/logo/logo_linux_clut224.ppm"
		ewarn "Remove the quiet kernel parameter (from params in /etc/boot.conf, and re-run boot-update)."
		ewarn "This will ensure the custom kernel logo is displayed during boot over frame buffer."
		ewarn ""  # custom-cflags
	fi  # if ne $name "unconditional"
	if use sign-modules; then
		tweak_config .config CONFIG_MODULE_SIG y
		tweak_config .config CONFIG_MODULE_SIG_FORCE n
		tweak_config .config CONFIG_MODULE_SIG_ALL n
		tweak_config .config CONFIG_MODULE_SIG_HASH "sha512"
		tweak_config .config CONFIG_MODULE_SIG_KEY "${certs_dir}/signing_key.pem"
		tweak_config .config CONFIG_SYSTEM_TRUSTED_KEYRING y
		tweak_config .config CONFIG_SYSTEM_EXTRA_CERTIFICATE y
		tweak_config .config CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE 4096
		tweak_config .config CONFIG_MODULE_SIG_SHA512 y
		certs_dir=$(get_certs_dir)
		echo
		if [ -z "$certs_dir" ]; then
			eerror "No certs dir found in /etc/kernel/certs; aborting."
			die
		else
			einfo "Using certificate directory of $certs_dir for kernel module signing."
		fi
		echo
		ewarn "This kernel will ALLOW non-signed modules to be loaded with a WARNING."
		ewarn "To enable strict enforcement, YOU MUST add module.sig_enforce=1 as a kernel boot"
		ewarn "parameter (to params in /etc/boot.conf, and re-run boot-update.)"
		ewarn ""  # custom-cflags
	fi  # if ne $name "unconditional"  # if ne $name "unconditional"  # range $name, $opts := .Values.kernel_config_options

	# get config into good state:
	yes "" | make oldconfig >/dev/null 2>&1 || die
	cp .config "${T}"/config || die
	make -s mrproper || die "make mrproper failed"
}

src_compile() {
	! use binary && return
	install -d "${WORKDIR}"/build
	cp "${T}"/config "${WORKDIR}"/build/.config || die "couldn't copy kernel config"
	make ${MAKEOPTS} O="${WORKDIR}"/build bzImage || die "kernel build failure"
	make ${MAKEOPTS} O="${WORKDIR}"/build modules || die "modules build failure"
}

src_install() {
	# copy sources into place:
	dodir /usr/src
	cp -a "${S}" "${D}"/usr/src/${LINUX_SRCDIR} || die
	cd "${D}"/usr/src/${LINUX_SRCDIR}
	# prepare for real-world use and 3rd-party module building:
	make mrproper || die
	cp "${T}"/config .config || die
	cp -a "${T}"/debian debian || die

	# if we didn't compile a kernel, we're done. The kernel source tree is left in
	# an unconfigured state - you can't compile 3rd-party modules against it yet.
	use binary || return
	make ${MAKEOPTS} O="${WORKDIR}"/build INSTALL_MOD_PATH="${D}" modules_install || die "modules install failure"
	insinto /boot
	newins ${WORKDIR}/build/arch/x86/boot/bzImage "vmlinuz-${KERN_SUFFIX}.tmp"
	newins ${WORKDIR}/build/System.map "System.map-${KERN_SUFFIX}.tmp"
	newins ${WORKDIR}/build/.config "config-${KERN_SUFFIX}.tmp"
	make prepare || die
	make scripts || die
	# FL-8004: In Linux 5.10, module.lds is generated by 'modules_prepare',
	# so we need to run it as well to be able to compile modules
	make modules_prepare || die

	# module symlink fixup:
	rm -f "${D}"/lib/modules/*/source || die
	rm -f "${D}"/lib/modules/*/build || die
	cd "${D}"/lib/modules
	local moddir="$(make -s -C "${WORKDIR}"/build kernelrelease)"
	ln -s /usr/src/${LINUX_SRCDIR} "${D}"/lib/modules/${moddir}/source || die
	ln -s /usr/src/${LINUX_SRCDIR} "${D}"/lib/modules/${moddir}/build || die
	# Move to .tmp so Portage tracks it; pkg_postinst renames to MOD_DIR_NAME
	mv "${D}"/lib/modules/${moddir}{,.tmp} || die
	# Fixes FL-14
	cp "${WORKDIR}/build/System.map" "${D}/usr/src/${LINUX_SRCDIR}/" || die
	cp "${WORKDIR}/build/Module.symvers" "${D}/usr/src/${LINUX_SRCDIR}/" || die
	if use sign-modules; then
		# FIXME: only signs uncompressed .ko modules; compressed .ko.xz are skipped.
		# Requires kernel >= 6.12+ CONFIG_MODULE_COMPRESS_XZ support detection.
		find "${D}"/lib/modules -iname *.ko ! -iname *.ko.xz \
				-exec ${WORKDIR}/build/scripts/sign-file sha512 \
				$certs_dir/signing_key.pem $certs_dir/signing_key.x509 {} \; || die
		# install the sign-file executable for future use.
		exeinto /usr/src/${LINUX_SRCDIR}/scripts
		doexe ${WORKDIR}/build/scripts/sign-file
	fi
	# The following line associates the .tmp dir with this package, so that
	# when the package is uninstalled, the modules are not removed.
	# Otherwise, modules for the current running kernel might be erased!
	mv "${D}"/lib/modules/${moddir}{,.tmp}
}

pkg_postinst() {
	# Ensure that /boot is mounted in this phase
	ego_pkg_preinst

	# Back up existing initramfs as .old before generating a new one
	if use binary && use dracut; then
		INITRAMFS_GRUB_NAME="initramfs-${KERN_ARCH}-${MACARONI_KVER}-${MACARONI_KSUFFIX}.img"

		if [[ -f "/boot/${INITRAMFS_GRUB_NAME}" ]]; then
			rm -f "/boot/${INITRAMFS_GRUB_NAME}.old"
			einfo "Preserving: mv /boot/${INITRAMFS_GRUB_NAME} /boot/${INITRAMFS_GRUB_NAME}.old"
			mv "/boot/${INITRAMFS_GRUB_NAME}" "/boot/${INITRAMFS_GRUB_NAME}.old" || die
		fi
	fi

	# Pattern: install everything as .tmp in src_install, move to real names here.
	# Portage tracks .tmp files; on uninstall it removes them, but the real
	# files (moved into place by postinst) are not tracked by portage.
	# If the destination already exists, erase stale .old first, then back up as .old.
	if use binary; then
		# Move boot files from .tmp to real names (back up existing as .old)
		for i in vmlinuz System.map config; do
			if [[ -f "/boot/${i}-${KERN_SUFFIX}.tmp" ]]; then
				if [[ -f "/boot/${i}-${KERN_SUFFIX}" ]]; then
					rm -f "/boot/${i}-${KERN_SUFFIX}.old"
					einfo "Preserving: mv /boot/${i}-${KERN_SUFFIX}{,.old}"
					mv "/boot/${i}-${KERN_SUFFIX}" "/boot/${i}-${KERN_SUFFIX}.old" || die
				fi
				mv "/boot/${i}-${KERN_SUFFIX}.tmp" "/boot/${i}-${KERN_SUFFIX}" || die
			fi
		done

		# Move modules from .tmp to real name (back up existing as .old)
		local tmp_moddir
		tmp_moddir="$(ls -d /lib/modules/*.tmp 2>/dev/null | head -1)"
		if [[ -n "$tmp_moddir" ]]; then
			if [[ -d "/lib/modules/${MOD_DIR_NAME}" ]]; then
				rm -rf "/lib/modules/${MOD_DIR_NAME}.old"
				einfo "Preserving: mv /lib/modules/${MOD_DIR_NAME}{,.old}"
				mv "/lib/modules/${MOD_DIR_NAME}" "/lib/modules/${MOD_DIR_NAME}.old" || die
			fi
			mv "$tmp_moddir" "/lib/modules/${MOD_DIR_NAME}" || die
		fi
	fi

	# Finally, generate a new initramfs with dracut, via whip
	# NOTE: For now, the initramfs is generic.
	if use binary && use dracut; then
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

		INITRAMFS_WHIP_NAME="initramfs-${KERN_SUFFIX}"
		INITRAMFS_GRUB_NAME="initramfs-${KERN_ARCH}-${MACARONI_KVER}-${MACARONI_KSUFFIX}.img"

		DRACUT_ADD_MODULES="$(echo ${dracut_modules_pre} | xargs)" \
		DRACUT_ADD_DRIVERS="$(echo ${dracut_drivers_pre} | xargs)" \
		KVER="${KERN_ARCH}-${MACARONI_KVER}" \
		KTYPE="${MACARONI_KTYPE}" \
		KSUFFIX="${MACARONI_KSUFFIX}" \
		KMODDIR="/lib/modules/${MOD_DIR_NAME}" \
		whip h initramfs.generate_with_dracut || die

		if [[ -f "/boot/${INITRAMFS_WHIP_NAME}" ]]; then
			mv "/boot/${INITRAMFS_WHIP_NAME}" "/boot/${INITRAMFS_GRUB_NAME}" || die
		elif [[ -f "/boot/${INITRAMFS_GRUB_NAME}" ]]; then
			:
		else
			eerror "Initramfs not found: /boot/${INITRAMFS_WHIP_NAME}"
			eerror "Expected final path: /boot/${INITRAMFS_GRUB_NAME}"
			die "initramfs generation failed"
		fi

		chmod 644 "/boot/${INITRAMFS_GRUB_NAME}" || die
	fi

	if use binary && [[ -h /usr/src/linux ]]; then
		rm /usr/src/linux || die
	fi

	if use binary && [[ ! -e /usr/src/linux ]]; then
		ewarn "With binary use flag enabled /usr/src/linux"
		ewarn "symlink automatically set to debian kernel"
		ewarn "If you have external modules, don't forget to rebuild them with:"
		ewarn ""
		ewarn "  emerge @module-rebuild"
		ewarn ""
		ln -sf "${LINUX_SRCDIR}" /usr/src/linux || die
	fi

	if [ -e /lib/modules ]; then
		depmod -a "${MOD_DIR_NAME}" || die
	fi

	# Update bootloader and unmount /boot
	ego_pkg_postinst
}

# vim: filetype=ebuild
