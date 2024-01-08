# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} != *9999* ]]; then
	QT5_KDEPATCHSET_REV=1
	KEYWORDS="amd64 ~arm arm64 ~hppa ppc64 ~sparc x86"
fi

QT5_MODULE="qttools"
inherit desktop qt5-build xdg-utils

DESCRIPTION="Tool for viewing on-line documentation in Qt help file format"

IUSE=""

DEPEND="
	=dev-qt/qtcore-5.15.11*:5=
	=dev-qt/qtgui-5.15.11*[png]
	=dev-qt/qthelp-5.15.11*
	=dev-qt/qtnetwork-5.15.11*
	=dev-qt/qtprintsupport-5.15.11*
	=dev-qt/qtsql-5.15.11*[sqlite]
	=dev-qt/qtwidgets-5.15.11*
"
RDEPEND="${DEPEND}
	!dev-qt/${PN}:5
	!<dev-qt/qtchooser-66-r2
"

QT5_TARGET_SUBDIRS=(
	src/assistant/assistant
)

src_prepare() {
	sed -e "s/qtHaveModule(webkitwidgets)/false/g" \
		-i src/assistant/assistant/assistant.pro || die

	qt5-build_src_prepare
}

src_install() {
	qt5-build_src_install
	qt5_symlink_binary_to_path assistant

	doicon -s 32 src/assistant/assistant/images/assistant.png
	newicon -s 128 src/assistant/assistant/images/assistant-128.png assistant.png
	make_desktop_entry "${QT5_BINDIR}"/assistant 'Qt 5 Assistant' assistant 'Qt;Development;Documentation'
}

pkg_postinst() {
	qt5-build_pkg_postinst
	xdg_icon_cache_update
}

pkg_postrm() {
	qt5-build_pkg_postrm
	xdg_icon_cache_update
}
