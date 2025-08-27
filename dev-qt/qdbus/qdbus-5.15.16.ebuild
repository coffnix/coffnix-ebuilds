# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qttools"
inherit desktop qt5-build xdg-utils

DESCRIPTION="Interface to Qt applications communicating over D-Bus"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qttools-everywhere-opensource-src-5.15.16.tar.xz -> qttools-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtxml:5
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qttools-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/qdbus/qdbus
)


# vim: filetype=ebuild
