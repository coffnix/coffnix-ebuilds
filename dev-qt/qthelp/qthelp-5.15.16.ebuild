# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qttools"
inherit qt5-build

DESCRIPTION="Qt5 module for integrating online documentation into applications"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qttools-everywhere-opensource-src-5.15.16.tar.xz -> qttools-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtsql:5[sqlite]
	dev-qt/qtwidgets:5
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qttools-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/assistant/help
	src/assistant/qcollectiongenerator
	src/assistant/qhelpgenerator
)


# vim: filetype=ebuild
