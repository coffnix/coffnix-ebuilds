# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qttools"
inherit qt5-build

DESCRIPTION="Tool for reporting diagnostic information about Qt and its environment"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qttools-everywhere-opensource-src-5.15.16.tar.xz -> qttools-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="+network +widgets"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5
	network? ( dev-qt/qtnetwork:5[ssl] )
	widgets? ( dev-qt/qtwidgets:5 )
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qttools-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/qtdiag
)
src_prepare() {
	qt_use_disable_mod network network \
	  src/qtdiag/qtdiag.pro
	qt_use_disable_mod widgets widgets \
	  src/qtdiag/qtdiag.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild
