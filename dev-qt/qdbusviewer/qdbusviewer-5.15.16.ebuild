# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qttools"
inherit desktop qt5-build xdg-utils

DESCRIPTION="Graphical tool that lets you introspect D-Bus objects and messages"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qttools-everywhere-opensource-src-5.15.16.tar.xz -> qttools-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qttools-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/qdbus/qdbusviewer
)
src_install() {
	qt5-build_src_install
	doicon -s 32 src/qdbus/qdbusviewer/images/qdbusviewer.png
	newicon -s 128 src/qdbus/qdbusviewer/images/qdbusviewer-128.png qdbusviewer.png
	make_desktop_entry "${QT5_BINDIR}"/qdbusviewer 'Qt 5 QDBusViewer' qdbusviewer 'Qt;Development'
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
