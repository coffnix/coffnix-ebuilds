# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Qt module enables peer-to-peer communication between a server (QML/C++ application) and a client"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtwebchannel-everywhere-src-6.8.3.tar.xz -> qtwebchannel-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="qml"
RDEPEND="dev-qt/qtbase:6
	qml? ( dev-qt/qtdeclarative:6 )
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	local mycmakeargs=(
	  $(cmake_use_find_package qml Qt6Qml)
	)
	qt6-build_src_prepare
}


# vim: filetype=ebuild
