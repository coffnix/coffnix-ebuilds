# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Plugins for additional image formats: TIFF, MNG, TGA, WBMP"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtimageformats-everywhere-src-6.8.3.tar.xz -> qtimageformats-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="mng"
RDEPEND="dev-qt/qtbase:6[gui]
	media-libs/libwebp:=
	media-libs/tiff:=
	mng? ( media-libs/libmng:= )
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local mycmakeargs=(
	  -DQT_FEATURE_jasper=OFF
	  $(qt_feature mng)
	  -DQT_FEATURE_tiff=ON
	  -DQT_FEATURE_webp=ON
	  -DQT_FEATURE_system_tiff=ON
	  -DQT_FEATURE_system_webp=ON
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild
