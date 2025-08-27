# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qtbase"
inherit qt5-build

DESCRIPTION="Interface to Qt applications communicating over D-Bus"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtbase-everywhere-opensource-src-5.15.17.tar.xz -> qtbase-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	sys-apps/dbus
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qtbase-everywhere-src-5.15.17"
QT5_TARGET_SUBDIRS=(
	src/dbus
	src/tools/qdbusxml2cpp
	src/tools/qdbuscpp2xml
)
QT5_GENTOO_CONFIG=(
	:dbus
	:dbus-linked:
)
QT5_GENTOO_PRIVATE_CONFIG=(
	:dbus
	:dbus-linked
)
src_configure() {
	local myconf=(
	  -dbus-linked
	)
	qt5-build_src_configure
}


# vim: filetype=ebuild
