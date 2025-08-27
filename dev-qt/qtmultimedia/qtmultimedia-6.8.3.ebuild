# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Multimedia (audio, video, radio, camera) library for the Qt framework"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtmultimedia-everywhere-src-6.8.3.tar.xz -> qtmultimedia-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="alsa ffmpeg gstreamer pulseaudio qml vaapi"
BDEPEND="dev-qt/qtshadertools:6
	
"
RDEPEND="dev-qt/qtbase:6[gui,vulkan]
	alsa? (
	  !pulseaudio? ( media-libs/alsa-lib )
	)
	ffmpeg? (
	  dev-qt/qtbase:6[X]
	  media-video/ffmpeg:=[vaapi?]
	  x11-libs/libX11
	  x11-libs/libXext
	  x11-libs/libXrandr
	)
	gstreamer? (
	  dev-libs/glib:2
	  media-libs/gst-plugins-bad:1.0
	  media-libs/gst-plugins-base:1.0[X,egl,opengl,wayland]
	  media-libs/gstreamer:1.0
	)
	media-libs/libglvnd
	pulseaudio? ( media-sound/pulseaudio )
	qml? (
	  dev-qt/qtdeclarative:6
	  dev-qt/qtquick3d:6
	)
	
"
DEPEND="${RDEPEND}
	xlibre-base/xorg-proto
	sys-kernel/linux-headers
	dev-util/vulkan-headers
	
"
src_configure() {
	# eigen + ppc32 seems broken w/ -maltivec (forced by Qt, bug #943402)
	use ppc && append-cppflags -DEIGEN_DONT_VECTORIZE
	 local mycmakeargs=(
	  -DFEATURE_linux_v4l=TRUE
	  # Android
	  -DFEATURE_opensles=FALSE
	  # Depdencyless
	  -DFEATURE_spatialaudio=TRUE
	  # MacOS
	  -DFEATURE_videotoolbox=FALSE
	  -DFEATURE_wasm=FALSE
	  -DQT_NO_STRIP_WRAPPER=TRUE
	  $(cmake_use_find_package qml Qt6Qml)
	  $(qt_feature ffmpeg)
	  #$(qt_feature gstreamer)
	  -DFEATURE_no-gstreamer=TRUE
	  $(qt_feature pulseaudio)
	  $(qt_feature vaapi)
	)
	# ALSA backend is experimental off-by-default and can take priority
	# causing problems (bug #935146), disable if USE=pulseaudio is set
	# (also do not want unnecessary usage of ALSA plugins -> pulse)
	if use alsa && use pulseaudio; then
	  # einfo should be enough given pure-ALSA users tend to disable pulse
	  einfo "Warning: USE=alsa is ignored when USE=pulseaudio is set"
	  mycmakeargs+=( -DQT_FEATURE_alsa=OFF )
	else
	  mycmakeargs+=( $(qt_feature alsa) )
	fi
	qt6-build_src_configure
}


# vim: filetype=ebuild
