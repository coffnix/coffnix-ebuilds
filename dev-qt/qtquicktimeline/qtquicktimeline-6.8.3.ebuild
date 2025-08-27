# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Enables keyframe-based animations and parameterization"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtquicktimeline-everywhere-src-6.8.3.tar.xz -> qtquicktimeline-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
RDEPEND="dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild
