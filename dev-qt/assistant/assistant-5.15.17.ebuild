# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qttools"
inherit desktop qt5-build xdg-utils

DESCRIPTION="Tool for viewing on-line documentation in Qt help file format"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qttools-everywhere-opensource-src-5.15.17.tar.xz -> qttools-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5[png]
	dev-qt/qthelp:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsql:5[sqlite]
	dev-qt/qtwidgets:5
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qttools-everywhere-src-5.15.17"
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


# vim: filetype=ebuild
