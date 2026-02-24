# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="Helpers for scheduling the dark-light cycle"
HOMEPAGE="https://invent.kde.org/plasma/"
SRC_URI="https://download.kde.org/stable/plasma/6.5.5/knighttime-6.5.5.tar.xz -> knighttime-6.5.5.tar.xz"
SLOT="6"
KEYWORDS="*"
RDEPEND="virtual/kde-seed[gui]
	dev-qt/qtpositioning:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kdbusaddons:6
	kde-frameworks/kholidays:6
	kde-frameworks/ki18n:6
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild
