# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Serial port abstraction library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtserialport-everywhere-opensource-src-5.15.17.tar.xz -> qtserialport-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	virtual/libudev:=
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	# make sure we link against libudev
	sed -i -e 's/:qtConfig(libudev)//' \
	  src/serialport/serialport-lib.pri || die
	qt5-build_src_prepare
}


# vim: filetype=ebuild
