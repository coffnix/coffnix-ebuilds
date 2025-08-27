# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="xml(+)"
inherit flag-o-matic multiprocessing optfeature prefix python-any-r1 qt6-build toolchain-funcs

DESCRIPTION="Library for rendering dynamic web content in Qt C++ and QML applications"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtwebengine-everywhere-src-6.8.3.tar.xz -> qtwebengine-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="designer geolocation kerberos pipewire pulseaudio vaapi vulkan"
BDEPEND="$(python_gen_any_dep 'dev-python/html5lib[${PYTHON_USEDEP}]')
	dev-util/gperf
	net-libs/nodejs
	sys-devel/bison
	sys-devel/flex
	
"
RDEPEND="app-arch/snappy:=
	dev-libs/expat
	dev-libs/icu:=
	dev-libs/libevent:=
	dev-libs/libxml2[icu]
	dev-libs/libxslt
	dev-libs/nspr
	dev-libs/nss
	dev-qt/qtbase:6[gui,vulkan?]
	dev-qt/qtdeclarative:6
	dev-qt/qtwebchannel:6[qml]
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz:=
	media-libs/lcms:2
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	media-libs/libwebp:=
	media-libs/mesa[gbm(+)]
	media-libs/openjpeg:2=
	media-libs/opus
	media-libs/tiff:=
	sys-apps/dbus
	sys-apps/pciutils
	sys-devel/gcc:*
	sys-libs/zlib:=[minizip]
	virtual/libudev
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libdrm
	x11-libs/libxcb:=
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	media-libs/alsa-lib
	designer? ( dev-qt/qttools:6[designer] )
	geolocation? ( dev-qt/qtpositioning:6 )
	kerberos? ( virtual/krb5 )
	pipewire? ( media-video/pipewire )
	pulseaudio? ( media-sound/pulseaudio )
	vaapi? ( x11-libs/libva:=[X] )
	
"
DEPEND="${RDEPEND}
	media-libs/libglvnd
	xlibre-base/xorg-proto
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libxshmfence
	vaapi? (
	  vulkan? ( dev-util/vulkan-headers )
	)
	
"
src_configure() {
	local mycmakeargs=(
	  -DFEATURE_qtpdf_build=ON
	  -DQT_FEATURE_pdf_v8=ON
	  -DQT_FEATURE_qtwebengine_build=ON
	  $(cmake_use_find_package designer Qt6Designer)
	  -DFEATURE_webengine_build_ninja=OFF
	  -DFEATURE_webengine_system_alsa=ON
	  -DFEATURE_webengine_proprietary_codecs=ON
	  $(qt_feature geolocation webengine_geolocation)
	  $(qt_feature kerberos webengine_kerberos)
	  $(qt_feature pulseaudio webengine_system_pulseaudio)
	  $(qt_feature pipewire webengine_webrtc_pipewire)
	  -DFEATURE_webengine_system_icu=OFF
	  $(qt_feature vaapi webengine_vaapi)
	  $(qt_feature !vaapi webengine_system_libvpx)
	  $(qt_feature vulkan webengine_vulkan)
	  -DQT_FEATURE_webengine_embedded_build=OFF
	  -DQT_FEATURE_webengine_extensions=ON
	  # TODO: it may be possible to make x11 optional since 6.8+
	  -DQT_FEATURE_webengine_ozone_x11=ON
	  -DQT_FEATURE_webengine_pepper_plugins=ON
	  -DQT_FEATURE_webengine_printing_and_pdf=ON
	  -DQT_FEATURE_webengine_spellchecker=ON
	  -DQT_FEATURE_webengine_webchannel=ON
	  -DQT_FEATURE_webengine_webrtc=ON
	  -DFEATURE_webengine_system_glib=ON
	  -DQT_FEATURE_webengine_system_ffmpeg=OFF
	  -DQT_FEATURE_webengine_system_re2=OFF
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild
