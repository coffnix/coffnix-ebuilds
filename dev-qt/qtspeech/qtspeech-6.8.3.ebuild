# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Provides support for synthesizing speech from text and playing it as audio output"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtspeech-everywhere-src-6.8.3.tar.xz -> qtspeech-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="flite qml +speechd"
RDEPEND="dev-qt/qtbase:6
	dev-qt/qtmultimedia:6
	flite? ( app-accessibility/flite )
	qml? ( dev-qt/qtdeclarative:6 )
	speechd? ( app-accessibility/speech-dispatcher )
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	qt6-build_src_prepare
}
src_configure() {
	local mycmakeargs=(
	  $(cmake_use_find_package qml Qt6Qml)
	  $(qt_feature flite)
	  $(qt_feature speechd)
	  -DQT_FEATURE_flite_alsa=OFF
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild
