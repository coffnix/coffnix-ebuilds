# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Classes for displaying the contents of SVG files"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtsvg-everywhere-src-6.8.3.tar.xz -> qtsvg-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
RDEPEND="dev-qt/qtbase:6
	sys-libs/zlib
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild
