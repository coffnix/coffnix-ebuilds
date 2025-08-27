# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qttools"
inherit qt5-build

DESCRIPTION="Tools for working with Qt translation data files"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qttools-everywhere-opensource-src-5.15.16.tar.xz -> qttools-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="qml"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtxml:5
	qml? ( dev-qt/qtdeclarative:5 )
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qttools-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/linguist
)
src_prepare() {
	sed -i -e '/SUBDIRS += linguist/d' \
	  src/linguist/linguist.pro || die
	qt_use_disable_mod qml qmldevtools-private \
	  src/linguist/lupdate/lupdate.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild
