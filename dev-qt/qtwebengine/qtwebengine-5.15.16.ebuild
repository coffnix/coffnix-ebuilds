# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit python-any-r1 qt5-build memsaver

DESCRIPTION="Library for rendering dynamic web content in Qt5 C++ and QML applications"
SRC_URI="
https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtwebengine-everywhere-opensource-src-5.15.16.tar.xz -> qtwebengine-everywhere-opensource-src-5.15.16.tar.xz
https://github.com/qt/qtwebengine-chromium/archive/6d29e9cfcfffa7632cc3858ceaf8940677ba9c91.tar.gz -> qtwebengine-chromium-6d29e9cfcfffa7632cc3858ceaf8940677ba9c91.tar.gz"
SLOT="5"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/001-disable-fatal-warnings.patch"
	"${FILESDIR}/002-extra-gn.patch"
	"${FILESDIR}/003-chromium-87-v8-icu68.patch"
	"${FILESDIR}/004-disable-git.patch"
	"${FILESDIR}/005-pdfium-system-lcms2.patch"
	"${FILESDIR}/006-clang14.patch"
	"${FILESDIR}/007-gcc12-includes.patch"
	"${FILESDIR}/008-jumbo-build.patch"
	"${FILESDIR}/009-port-to-pipewire-0.3.patch"
	"${FILESDIR}/010-widevine.patch"
	"${FILESDIR}/011-clang16.patch"
	"${FILESDIR}/qt5-webengine-python3.patch"
)
IUSE="alsa bindist designer geolocation kerberos pulseaudio +system-ffmpeg +system-icu +jumbo-build widgets"
REQUIRED_USE="designer? ( widgets )"
BDEPEND="${PYTHON_DEPS}
	dev-util/gperf
	dev-util/ninja
	dev-util/re2c
	net-libs/nodejs[ssl(+)]
	sys-devel/bison
	
"
RDEPEND="app-arch/snappy:=
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/expat
	dev-libs/libevent:=
	dev-libs/libxml2[icu]
	dev-libs/libxslt
	dev-libs/re2:=
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtwebchannel:5[qml]
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz:=
	media-libs/lcms:2
	media-libs/libjpeg-turbo:=
	media-libs/libpng:0=
	>=media-libs/libvpx-1.5:=[svc(+)]
	media-libs/libwebp:=
	media-libs/mesa[egl,X(+)]
	media-libs/opus
	sys-apps/dbus
	sys-apps/pciutils
	sys-libs/zlib[minizip]
	virtual/libudev
	x11-libs/libdrm
	x11-libs/libxkbfile
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libxkbfile
	alsa? ( media-libs/alsa-lib )
	designer? ( dev-qt/designer:5 )
	geolocation? ( dev-qt/qtpositioning:5 )
	kerberos? ( virtual/krb5 )
	pulseaudio? ( media-sound/pulseaudio:= )
	system-ffmpeg? ( media-video/ffmpeg:0= )
	system-icu? ( >=dev-libs/icu-69.1:= )
	widgets? (
	  dev-qt/qtdeclarative:5[widgets]
	  dev-qt/qtwidgets:5
	)
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qtwebengine-everywhere-src-5.15.16"
pkg_setup() {
	python-any-r1_pkg_setup
}
src_unpack() {
	default
	rm -rf "${S}"/src/3rdparty
	mv qtwebengine-chromium-* "${S}"/src/3rdparty || die
}
src_prepare() {
	# Final link uses lots of file descriptors.
	ulimit -n 2048
	 # This is made from git, and for some reason will fail w/o .git directories.
	mkdir -p .git src/3rdparty/chromium/.git || die
	 # We need to make sure this integrates well into Qt 5.15.2 installation.
	# Otherwise revdeps fail w/o heavy changes. This is the simplest way to do it.
	sed -e "/^MODULE_VERSION/s/5.*/${PV}/" -i .qmake.conf || die
	 if ! use jumbo-build; then
	  sed -i -e 's|use_jumbo_build=true|use_jumbo_build=false|' \
	    src/buildtools/config/common.pri || die
	fi
	 # bug 630834 - pass appropriate options to ninja when building GN
	sed -e "s/\['ninja'/&, '${jobs}', '-l$(makeopts_loadavg "${MAKEOPTS}" 0)', '-v'/" \
	  -i src/3rdparty/chromium/tools/gn/bootstrap/bootstrap.py || die
	 # bug 620444 - ensure local headers are used
	find "${S}" -type f -name "*.pr[fio]" | \
	  xargs sed -i -e 's|INCLUDEPATH += |&$${QTWEBENGINE_ROOT}_build/include $${QTWEBENGINE_ROOT}/include |' || die
	 if use system-icu; then
	  # Sanity check to ensure that bundled copy of ICU is not used.
	  # Whole src/3rdparty/chromium/third_party/icu directory cannot be deleted because
	  # src/3rdparty/chromium/third_party/icu/BUILD.gn is used by build system.
	  # If usage of headers of bundled copy of ICU occurs, then lists of shim headers in
	  # shim_headers("icui18n_shim") and shim_headers("icuuc_shim") in
	  # src/3rdparty/chromium/third_party/icu/BUILD.gn should be updated.
	  local file
	  while read file; do
	    echo "#error This file should not be used!" > "${file}" || die
	  done < <(find src/3rdparty/chromium/third_party/icu -type f "(" -name "*.c" -o -name "*.cpp" -o -name "*.h" ")" 2>/dev/null)
	fi
	 qt_use_disable_config alsa webengine-alsa src/buildtools/config/linux.pri
	qt_use_disable_config pulseaudio webengine-pulseaudio src/buildtools/config/linux.pri
	 qt_use_disable_mod designer webenginewidgets src/plugins/plugins.pro
	 qt_use_disable_mod widgets widgets src/src.pro
	 qt5-build_src_prepare
}
src_configure() {
	export NINJA_PATH=/usr/bin/ninja
	export NINJAFLAGS="${MAKEOPTS}"
	 local myqmakeargs=(
	  --
	  -no-build-qtpdf
	  -printing-and-pdf
	  -system-opus
	  -system-webp
	  $(usex alsa '-alsa' '-no-alsa')
	  $(usex bindist '-no-proprietary-codecs' '-proprietary-codecs')
	  $(usex geolocation '-webengine-geolocation' '-no-webengine-geolocation')
	  $(usex kerberos '-webengine-kerberos' '-no-webengine-kerberos')
	  $(usex pulseaudio '-pulseaudio' '-no-pulseaudio')
	  $(usex system-ffmpeg '-system-ffmpeg' '-qt-ffmpeg')
	  $(usex system-icu '-webengine-icu' '-no-webengine-icu')
	)
	qt5-build_src_configure
}
src_install() {
	qt5-build_src_install
	if [[ ! -f ${D}${QT5_LIBDIR}/libQt5WebEngine.so ]]; then
	  die "${CATEGORY}/${PF} failed to build anything."
	fi
}


# vim: filetype=ebuild
