# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Additional format plugins for the Qt image I/O system"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtimageformats-everywhere-opensource-src-5.15.16.tar.xz -> qtimageformats-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="mng"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5
	media-libs/libwebp:=
	media-libs/tiff:0
	mng? ( media-libs/libmng:= )
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	sed -e 's/qtConfig(jasper)/false:/' \
	  -i src/plugins/imageformats/imageformats.pro || die
	qt_use_disable_config mng mng src/plugins/imageformats/imageformats.pro
	qt5-build_src_configure
}


# vim: filetype=ebuild
