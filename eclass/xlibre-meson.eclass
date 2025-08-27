# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: xlibre-meson.eclass
# @MAINTAINER:
# maintainer-needed@example.com
# @AUTHOR:
# Author: Matt Turner <mattst88@gentoo.org>
# @SUPPORTED_EAPIS: 8
# @PROVIDES: meson meson-multilib
# @BLURB: Reduces code duplication in the X11 ebuilds.
# @DESCRIPTION:
# This eclass makes trivial X ebuilds possible for apps, drivers,
# and more. Many things that would normally be done in various functions
# can be accessed by setting variables instead, such as patching,
# passing options to meson and installing docs.
#
# All you need to do in a basic ebuild is inherit this eclass and set
# DESCRIPTION, KEYWORDS and RDEPEND/DEPEND. If your package is hosted
# with the other X packages, you don't need to set SRC_URI. Pretty much
# everything else should be automatic.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ -z ${_XLIBRE_MESON_ECLASS} ]]; then
_XLIBRE_MESON_ECLASS=1

inherit flag-o-matic

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
fi

# @ECLASS_VARIABLE: XLIBRE_MULTILIB
# @PRE_INHERIT
# @DESCRIPTION:
# If set to 'yes', multilib support for package will be enabled. Set
# before inheriting this eclass.
: "${XLIBRE_MULTILIB:="no"}"

[[ ${XLIBRE_MULTILIB} == yes ]] && inherit meson-multilib || inherit meson

# @ECLASS_VARIABLE: XLIBRE_BASE_INDIVIDUAL_URI
# @PRE_INHERIT
# @DESCRIPTION:
# Set up SRC_URI for individual releases. If set to an empty
# string, no SRC_URI will be provided by the eclass.
: "${XLIBRE_BASE_INDIVIDUAL_URI="https://github.com/X11Libre"}"

# @ECLASS_VARIABLE: XLIBRE_MODULE
# @PRE_INHERIT
# @DESCRIPTION:
# The subdirectory to download source from. Possible settings are app,
# doc, data, util, driver, font, lib, proto, xserver. Set above the
# inherit to override the default autoconfigured module.
: "${XLIBRE_MODULE:="auto"}"
if [[ ${XLIBRE_MODULE} == auto ]]; then
	case "${CATEGORY}/${P}" in
		app-doc/*)               XLIBRE_MODULE=doc/     ;;
		media-fonts/*)           XLIBRE_MODULE=font/    ;;
		x11-apps/*|x11-wm/*)     XLIBRE_MODULE=app/     ;;
		x11-misc/*|x11-themes/*) XLIBRE_MODULE=util/    ;;
		x11-base/*)              XLIBRE_MODULE=         ;;
		x11-drivers/*)           XLIBRE_MODULE=         ;;
		x11-libs/*)              XLIBRE_MODULE=lib/     ;;
		*)                       XLIBRE_MODULE=         ;;
	esac
fi

# @ECLASS_VARIABLE: XLIBRE_PACKAGE_NAME
# @PRE_INHERIT
# @DESCRIPTION:
# For git checkout the git repository might differ from package name.
# This variable can be used for proper directory specification
: "${XLIBRE_PACKAGE_NAME:=${PN}}"
case "${CATEGORY}/${P}" in
	x11-base/xlibre-server-*) 	XLIBRE_PACKAGE_NAME=xserver ;;
esac

HOMEPAGE="https://github.com/X11Libre/${XLIBRE_MODULE}${XLIBRE_PACKAGE_NAME}"

# @ECLASS_VARIABLE: XLIBRE_TARBALL_SUFFIX
# @PRE_INHERIT
# @DESCRIPTION:
# Most XLibre projects provide tarballs as tar.xz. This eclass defaults to tar.gz.
: "${XLIBRE_TARBALL_SUFFIX:="gz"}"

if [[ ${PV} == *9999* ]]; then
	: "${EGIT_REPO_URI:="https://github.com/X11Libre/${XLIBRE_MODULE}${XLIBRE_PACKAGE_NAME}.git"}"
elif [[ -n ${XLIBRE_BASE_INDIVIDUAL_URI} ]]; then
	SRC_URI="${XLIBRE_BASE_INDIVIDUAL_URI}/${XLIBRE_PACKAGE_NAME}/archive/refs/tags/xlibre-${XLIBRE_PACKAGE_NAME}-${PV}.tar.${XLIBRE_TARBALL_SUFFIX}"
	S="${WORKDIR}/${XLIBRE_PACKAGE_NAME}-xlibre-${XLIBRE_PACKAGE_NAME}-${PV}"
fi

: "${SLOT:=0}"

# Set the license for the package. This can be overridden by setting
# LICENSE after the inherit. Nearly all XLibre X packages are under
# the MIT license.
: "${LICENSE:=MIT}"

if [[ ${PN} == xf86-video-* || ${PN} == xf86-input-* ]]; then
	DEPEND+="  x11-base/xorg-proto"
	DEPEND+="  >=x11-base/xlibre-server-1.20:=[xorg]"
	RDEPEND+=" >=x11-base/xlibre-server-1.20:=[xorg]"
	if [[ ${PN} == xf86-video-* ]]; then
		DEPEND+="  >=x11-libs/libpciaccess-0.14"
		RDEPEND+=" >=x11-libs/libpciaccess-0.14"
	fi
fi
BDEPEND+=" virtual/pkgconfig"

# @ECLASS_VARIABLE: XLIBRE_DOC
# @PRE_INHERIT
# @DESCRIPTION:
# Controls the installation of man3 developer documentation. Possible values
# are the name of the useflag or "no". Default value is "no".
: "${XLIBRE_DOC:="no"}"

case ${XLIBRE_DOC} in
	no)
		;;
	*)
		IUSE+=" ${XLIBRE_DOC}"
		;;
esac

debug-print "${LINENO} ${ECLASS} ${FUNCNAME}: DEPEND=${DEPEND}"
debug-print "${LINENO} ${ECLASS} ${FUNCNAME}: RDEPEND=${RDEPEND}"
debug-print "${LINENO} ${ECLASS} ${FUNCNAME}: PDEPEND=${PDEPEND}"
debug-print "${LINENO} ${ECLASS} ${FUNCNAME}: BDEPEND=${BDEPEND}"

# @FUNCTION: xlibre-meson_src_unpack
# @DESCRIPTION:
# Simply unpack source code.
xlibre-meson_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
	else
		unpack ${A}
	fi
}

# @FUNCTION: xlibre-meson_flags_setup
# @INTERNAL
# @DESCRIPTION:
# Set up CFLAGS for a debug build
xlibre-meson_flags_setup() {
	debug-print-function ${FUNCNAME} "$@"

	# Hardened flags break module autoloading et al (also fixes #778494)
	if [[ ${PN} == xlibre-server || ${PN} == xf86-video-* || ${PN} == xf86-input-* ]]; then
		filter-flags -fno-plt
		append-ldflags -Wl,-z,lazy
	fi
}

# @VARIABLE: XLIBRE_CONFIGURE_OPTIONS
# @DEFAULT_UNSET
# @DESCRIPTION:
# Array of an additional options to pass to meson setup.

# @FUNCTION: xlibre-meson_src_configure
# @DESCRIPTION:
# Perform any necessary pre-configuration steps, then run configure
xlibre-meson_src_configure() {
	debug-print-function ${FUNCNAME} "$@"

	xlibre-meson_flags_setup

	local emesonargs=(
		-Ddefault_library=shared
		"${XLIBRE_CONFIGURE_OPTIONS[@]}"
	)

	if [[ ${XLIBRE_MULTILIB} == yes ]]; then
		meson-multilib_src_configure "$@"
	else
		meson_src_configure "$@"
	fi
}

# @FUNCTION: xlibre-meson_src_install
# @DESCRIPTION:
# Install a built package to ${ED}, performing any necessary steps.
xlibre-meson_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${XLIBRE_MULTILIB} == yes ]]; then
		meson-multilib_src_install "$@"
	else
		meson_src_install "$@"
	fi

	# Many X11 libraries unconditionally install developer documentation
	if ! in_iuse doc && [[ -d "${ED}"/usr/share/man/man3 ]]; then
		eqawarn "ebuild should set XLIBRE_DOC=doc since package installs man3 documentation"
	fi

	if in_iuse doc && ! use doc; then
		rm -rf "${ED}"/usr/share/man/man3 || die
		find "${ED}"/usr -type d -empty -delete || die
	fi
}

fi

EXPORT_FUNCTIONS src_unpack src_configure src_install
