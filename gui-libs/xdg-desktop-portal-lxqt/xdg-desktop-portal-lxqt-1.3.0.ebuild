# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Backend implementation for xdg-desktop-portal using Qt/KF5/libfm-qt"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1"
SLOT="0"

BDEPEND=">=dev-util/lxqt-build-tools-2.3.0"
DEPEND="
	>=dev-qt/qtbase-6.6:6[dbus,gui,widgets]
	kde-frameworks/kwindowsystem:6
	>=x11-libs/libfm-qt-2.3:=
"
RDEPEND="${DEPEND}
	sys-apps/xdg-desktop-portal
"
