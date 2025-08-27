# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Text-to-speech library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtspeech-everywhere-opensource-src-5.15.16.tar.xz -> qtspeech-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="alsa flite"
RDEPEND="app-accessibility/speech-dispatcher
	dev-qt/qtcore:5
	flite? (
	  app-accessibility/flite[alsa?]
	  dev-qt/qtmultimedia:5[alsa?]
	  alsa? ( media-libs/alsa-lib )
	)
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	qt_use_disable_config flite flite \
	  src/plugins/tts/tts.pro
	qt_use_disable_config alsa flite_alsa \
	  src/plugins/tts/flite/flite.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild
