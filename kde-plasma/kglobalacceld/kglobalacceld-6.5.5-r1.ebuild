# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit kde6 xdg

DESCRIPTION="Daemon providing Global Keyboard Shortcut (Accelerator) functionality"
HOMEPAGE="https://invent.kde.org/plasma/"
SRC_URI="https://download.kde.org/stable/plasma/6.5.5/kglobalacceld-6.5.5.tar.xz -> kglobalacceld-6.5.5.tar.xz"
SLOT="6"
KEYWORDS="*"
RDEPEND="virtual/kde-seed[gui]
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kcrash:6
	kde-frameworks/kdbusaddons:6
	kde-frameworks/kglobalaccel:6
	kde-frameworks/ki18n:6
	kde-frameworks/kio:6
	kde-frameworks/kservice:6
	kde-frameworks/kwindowsystem:6
	kde-frameworks/kxmlgui:6
	
"
DEPEND="${RDEPEND}
"

src_prepare() {
	kde6_src_prepare
}

