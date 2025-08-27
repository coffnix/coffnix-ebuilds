# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qttools"
inherit desktop qt5-build xdg-utils

DESCRIPTION="Graphical tool for translating Qt applications"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qttools-everywhere-opensource-src-5.15.16.tar.xz -> qttools-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/designer:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5[png]
	dev-qt/qtprintsupport:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qttools-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/linguist/linguist
)
src_install() {
	qt5-build_src_install
	local size
	for size in 16 32 48 64 128; do
	  newicon -s ${size} src/linguist/linguist/images/icons/linguist-${size}-32.png linguist.png
	done
	make_desktop_entry "${QT5_BINDIR}"/linguist 'Qt 5 Linguist' linguist 'Qt;Development;Translation'
}
pkg_postinst() {
	qt5-build_pkg_postinst
	xdg_icon_cache_update
}
pkg_postrm() {
	qt5-build_pkg_postrm
	xdg_icon_cache_update
}


# vim: filetype=ebuild
