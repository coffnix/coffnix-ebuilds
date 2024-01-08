# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} != *9999* ]]; then
	QT5_KDEPATCHSET_REV=1
	KEYWORDS="amd64 arm arm64 ~hppa ~loong ppc ppc64 ~riscv x86"
fi

QT5_MODULE="qttools"
inherit desktop qt5-build xdg-utils

DESCRIPTION="WYSIWYG tool for designing and building graphical user interfaces with QtWidgets"

IUSE="declarative"

DEPEND="
	=dev-qt/qtcore-5.15.11*:5=
	=dev-qt/qtgui-5.15.11*:5=[png]
	=dev-qt/qtnetwork-5.15.11*
	=dev-qt/qtprintsupport-5.15.11*
	=dev-qt/qtwidgets-5.15.11*
	=dev-qt/qtxml-5.15.11*
	declarative? ( =dev-qt/qtdeclarative-5.15.11*[widgets] )
"
RDEPEND="${DEPEND}"

QT5_TARGET_SUBDIRS=(
	src/designer
)

src_prepare() {
	qt_use_disable_mod declarative quickwidgets \
		src/designer/src/plugins/plugins.pro

	sed -e "s/qtHaveModule(webkitwidgets)/false/g" \
		-i src/designer/src/plugins/plugins.pro || die

	qt5-build_src_prepare
}

src_install() {
	qt5-build_src_install
	qt5_symlink_binary_to_path designer 5

	doicon -s 128 src/designer/src/designer/images/designer.png
	make_desktop_entry "${QT5_BINDIR}"/designer 'Qt 5 Designer' designer 'Qt;Development;GUIDesigner'
}

pkg_postinst() {
	qt5-build_pkg_postinst
	xdg_icon_cache_update
}

pkg_postrm() {
	qt5-build_pkg_postrm
	xdg_icon_cache_update
}
