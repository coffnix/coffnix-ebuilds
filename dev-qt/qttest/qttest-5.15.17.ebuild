# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qtbase"
inherit qt5-build

DESCRIPTION="Unit testing library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtbase-everywhere-opensource-src-5.15.17.tar.xz -> qtbase-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qtbase-everywhere-src-5.15.17"
QT5_TARGET_SUBDIRS=(
	src/testlib
)
QT5_GENTOO_PRIVATE_CONFIG=(
	:testlib
)


# vim: filetype=ebuild
