# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Provides classes to interact with hardware and virtual serial ports"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtserialport-everywhere-src-6.8.3.tar.xz -> qtserialport-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
RDEPEND="dev-qt/qtbase:6
	virtual/libudev:=
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild
