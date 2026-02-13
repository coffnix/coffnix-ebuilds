# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="Qt component to allow applications to make use of Wayland wl-layer-shell protocol"
HOMEPAGE="https://invent.kde.org/plasma/"
SRC_URI="https://download.kde.org/stable/plasma/6.5.5/layer-shell-qt-6.5.5.tar.xz -> layer-shell-qt-6.5.5.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="wayland"
BDEPEND="wayland? (
	>=dev-libs/wayland-protocols-1.16
	dev-util/wayland-scanner
	)
	
"
RDEPEND="virtual/kde-seed[gui,wayland?]
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild
