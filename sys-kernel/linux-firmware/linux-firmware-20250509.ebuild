# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit ego

DESCRIPTION="Linux firmware files"
HOMEPAGE="https://git.kernel.org/?p=linux/kernel/git/firmware/linux-firmware.git"
SRC_URI="https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/linux-firmware-20250509.tar.gz -> linux-firmware-20250509.tar.gz
"

LICENSE="GPL-2 GPL-2+ GPL-3 BSD MIT MPL-1.1 linux-fw-redistributable BSD-2 BSD-4 ISC no-source-code"
SLOT="0"
IUSE="initramfs"
KEYWORDS="*"
RESTRICT="strip test"
QA_PREBUILT="*"

BDEPEND="initramfs? ( app-arch/cpio ) app-misc/rdfind"
RDEPEND="initramfs? ( !<=app-admin/ego-2.8.5 )"

PATCHES=(
	"${FILESDIR}"/${PN}-copy-firmware.patch
)

src_prepare() {
	default

	if use initramfs; then
		if [[ -d "${S}/amd-ucode" ]]; then
			local UCODETMP="${T}/ucode_tmp"
			local UCODEDIR="${UCODETMP}/kernel/x86/microcode"
			mkdir -p "${UCODEDIR}" || die
			echo 1 > "${UCODETMP}/early_cpio"

			local amd_ucode_file="${UCODEDIR}/AuthenticAMD.bin"
			cat "${S}"/amd-ucode/*.bin > "${amd_ucode_file}" || die "Failed to concat amd cpu ucode"

			if [[ ! -s "${amd_ucode_file}" ]]; then
				die "Sanity check failed: '${amd_ucode_file}' is empty!"
			fi

			pushd "${UCODETMP}" &>/dev/null || die
			find . -print0 | cpio --quiet --null -o -H newc -R 0:0 > "${S}"/amd-uc.img
			popd &>/dev/null || die
			if [[ ! -s "${S}/amd-uc.img" ]]; then
				die "Failed to create '${S}/amd-uc.img'!"
			fi
		else
			# If this will ever happen something has changed which
			# must be reviewed
			die "'${S}/amd-ucode' not found!"
		fi
	fi

	echo "# Remove files that shall not be installed from this list." > ${PN}.conf
	find * ! -type d ! \( -name ${PN}.conf -o -name amd-uc.img \) >> ${PN}.conf
}

src_install() {
	./copy-firmware.sh -v "${ED}/lib/firmware" || die

	if use initramfs ; then
		insinto /lib/firmware/amd-ucode
		doins "${S}"/amd-uc.img
	fi
}

pkg_preinst() {
	# Make sure /boot is available if needed.
	use initramfs && ego_pkg_preinst

	# Fix 'symlink is blocked by a directory' Bug #871315 on Gentoo and FL-10491 on Funtoo
	if has_version "<${CATEGORY}/${PN}-20220913-r1" ; then
		rm -rf "${EROOT}"/lib/firmware/qcom/LENOVO/21BX*
	fi


}

pkg_postinst() {
	# Don't forget to umount /boot if it was previously mounted by us.
	use initramfs && ego_pkg_postinst
}

pkg_prerm() {
	# Make sure /boot is mounted so that we can remove /boot/amd-uc.img!
	use initramfs && ego_pkg_prerm
}

pkg_postrm() {
	# Don't forget to umount /boot if it was previously mounted by us.
	use initramfs && ego_pkg_postrm
}