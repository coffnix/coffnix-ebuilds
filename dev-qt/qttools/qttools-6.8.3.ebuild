# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Qt Tools Collection"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qttools-everywhere-src-6.8.3.tar.xz -> qttools-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="+assistant designer distancefieldgenerator +gui +linguist"
RDEPEND="dev-qt/qtbase:6
	assistant? ( dev-qt/qtbase:6[sql,sqlite] )
	designer? (
	  dev-qt/qtbase:6[zstd]
	  app-arch/zstd:=
	)
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local mycmakeargs=(
	  $(qt_feature assistant)
	  $(qt_feature designer)
	  $(qt_feature distancefieldgenerator)
	  $(qt_feature linguist)
	  # TODO?: package litehtml, but support for latest releases seem
	  # to lag behind and bundled may work out better for now
	  # https://github.com/litehtml/litehtml/issues/266
	  $(usev assistant -DCMAKE_DISABLE_FIND_PACKAGE_litehtml=ON)
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild
