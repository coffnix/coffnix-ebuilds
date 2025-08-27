# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qttools"
inherit desktop qt5-build xdg-utils

DESCRIPTION="WYSIWYG tool for designing and building graphical user interfaces with QtWidgets"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qttools-everywhere-opensource-src-5.15.16.tar.xz -> qttools-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="declarative"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5[png]
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	declarative? ( dev-qt/qtdeclarative:5[widgets] )
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qttools-everywhere-src-5.15.16"
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


# vim: filetype=ebuild
