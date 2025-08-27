# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Bluetooth and NFC support library for the Qt framework"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtconnectivity-everywhere-src-6.8.3.tar.xz -> qtconnectivity-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="nfc"
# Commons depends
CDEPEND="dev-qt/qtbase:6
	net-wireless/bluez:=
	nfc? (
	  net-wireless/neard
	  sys-apps/pcsc-lite
	)
	
"
RDEPEND="${CDEPEND}
"
DEPEND="${CDEPEND}
"
src_configure() {
	local mycmakeargs=(
	  $(qt_feature nfc pcsclite)
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild
