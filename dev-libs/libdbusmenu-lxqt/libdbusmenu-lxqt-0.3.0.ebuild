# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="LXQt DBusMenu Implementation"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2"
SLOT="0"

RDEPEND=">=dev-qt/qtbase-6.6:6[dbus,widgets]"

PATCHES=( "${FILESDIR}/${PN}-0.1.0-cmake.patch" )
