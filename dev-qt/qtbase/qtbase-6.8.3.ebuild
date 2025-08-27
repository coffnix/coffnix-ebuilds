# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Qt Cross-platform application development framework"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtbase-everywhere-src-6.8.3.tar.xz -> qtbase-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="+X brotli cups gles2-only gtk gssapi +gui journald libinput libproxy mysql postgres renderdoc +sql sqlite vulkan wayland zstd"
REQUIRED_USE="gui? ( || ( X wayland ) )
sql? ( || ( mysql postgres sqlite ) )
"
BDEPEND="zstd? ( app-arch/libarchive[zstd] )
	
"
RDEPEND="sys-libs/zlib
	dev-libs/openssl
	virtual/libudev:=
	zstd? ( app-arch/zstd:= )
	app-crypt/libb2
	dev-libs/double-conversion:=
	dev-libs/glib:2
	dev-libs/libpcre2:=[pcre16,unicode(+)]
	dev-libs/icu:=
	journald? ( sys-apps/systemd )
	sys-apps/dbus
	gssapi? ( virtual/krb5 )
	gui? (
	  media-libs/fontconfig
	  media-libs/freetype:2
	  media-libs/harfbuzz:=
	  media-libs/libjpeg-turbo:=
	  media-libs/libpng:=
	  x11-libs/libdrm
	  x11-libs/libxkbcommon[X?]
	  X? (
	    x11-libs/libICE
	    x11-libs/libSM
	    x11-libs/libX11
	    x11-libs/libxcb:=
	    x11-libs/xcb-util-cursor
	    x11-libs/xcb-util-image
	    x11-libs/xcb-util-keysyms
	    x11-libs/xcb-util-renderutil
	    x11-libs/xcb-util-wm
	  )
	  app-accessibility/at-spi2-core:2
	  media-libs/mesa[gbm(+)]
	  sys-libs/mtdev
	  libinput? ( dev-libs/libinput:= )
	  gles2-only? ( media-libs/libglvnd )
	  !gles2-only? ( media-libs/libglvnd[X?] )
	  renderdoc? ( media-gfx/renderdoc )
	  vulkan? ( dev-util/vulkan-headers )
	  cups? ( net-print/cups )
	  gtk? (
	    x11-libs/gdk-pixbuf:2
	    x11-libs/gtk+:3[X?,wayland?]
	    x11-libs/pango
	    )
	)
	brotli? ( app-arch/brotli:= )
	libproxy? ( net-libs/libproxy )
	sql? (
	  mysql? ( dev-db/mysql-connector-c:= )
	  postgres? ( dev-db/postgresql:* )
	  sqlite? ( dev-db/sqlite:3 )
	)
	
"
DEPEND="${RDEPEND}
"
PDEPEND="gui? (
	  wayland? ( ~dev-qt/qtwayland-${PV}:6 )
	)
	
"
src_configure() {
	if use gtk; then
	  # defang automagic dependencies (bug #624960)
	  use X || append-cxxflags -DGENTOO_GTK_HIDE_X11
	  use wayland || append-cxxflags -DGENTOO_GTK_HIDE_WAYLAND
	fi
	 local mycmakeargs=(
	  -DBUILD_WITH_PCH=OFF
	  -DINSTALL_ARCHDATADIR="${QT6_ARCHDATADIR}"
	  -DINSTALL_BINDIR="${QT6_BINDIR}"
	  -DINSTALL_DATADIR="${QT6_DATADIR}"
	  -DINSTALL_DOCDIR="${QT6_DOCDIR}"
	  -DINSTALL_EXAMPLESDIR="${QT6_EXAMPLESDIR}"
	  -DINSTALL_INCLUDEDIR="${QT6_HEADERDIR}"
	  -DINSTALL_LIBDIR="${QT6_LIBDIR}"
	  -DINSTALL_LIBEXECDIR="${QT6_LIBEXECDIR}"
	  -DINSTALL_MKSPECSDIR="${QT6_MKSPECSDIR}"
	  -DINSTALL_PLUGINSDIR="${QT6_PLUGINDIR}"
	  -DINSTALL_QMLDIR="${QT6_QMLDIR}"
	  -DINSTALL_SYSCONFDIR="${QT6_SYSCONFDIR}"
	  -DINSTALL_TRANSLATIONSDIR="${QT6_TRANSLATIONDIR}"
	  -DFEATURE_openssl_linked=ON
	  $(qt_feature gui libudev)
	  $(qt_feature zstd)
	   # qtcore
	  -DFEATURE_icu=ON
	  $(qt_feature journald)
	  -DFEATURE_syslog=ON
	   # tools
	  -DQT_FEATURE_androiddeployqt=OFF
	   # modules
	  -DFEATURE_concurrent=ON
	  -DFEATURE_dbus=ON
	  $(qt_feature gui)
	  -DFEATURE_network=ON
	  $(qt_feature sql)
	  -DQT_FEATURE_testlib=ON
	  -DFEATURE_xml=ON
	   # let defaults and/or users control security *FLAGS
	  -DQT_FEATURE_glibc_fortify_source=OFF
	  -DQT_FEATURE_intelcet=OFF
	  -DQT_FEATURE_libcpp_hardening=OFF
	  -DQT_FEATURE_libstdcpp_assertions=OFF
	  -DQT_FEATURE_relro_now_linker=OFF
	  -DQT_FEATURE_stack_clash_protection=OFF
	  -DQT_FEATURE_stack_protector=OFF
	  -DQT_FEATURE_trivial_auto_var_init_pattern=OFF
	   -DQT_INTERNAL_AVOID_OVERRIDING_SYNCQT_CONFIG=ON # would force -O3
	   $(qt_feature brotli)
	  $(qt_feature gssapi)
	  $(qt_feature libproxy)
	)
	 use gui && mycmakeargs+=(
	  $(qt_feature X xcb)
	  $(qt_feature X system_xcb_xinput)
	  $(qt_feature X xkbcommon_x11)
	  $(cmake_use_find_package X X11) # needed for truly no automagic
	  -DFEATURE_eglfs=OFF
	  $(qt_feature gui evdev)
	  $(qt_feature gui mtdev)
	  $(qt_feature libinput)
	  $(qt_feature renderdoc graphicsframecapture)
	  -DFEATURE_tslib=OFF
	  $(qt_feature vulkan)
	  $(qt_feature wayland)
	  $(qt_feature gui widgets)
	  $(qt_feature gui opengl)
	  $(qt_feature gles2-only opengles2)
	  $(qt_feature cups)
	  $(qt_feature gtk gtk3)
	)
	 use sql && mycmakeargs+=(
	  -DQT_FEATURE_sql_db2=OFF # unpackaged
	  -DQT_FEATURE_sql_ibase=OFF # unpackaged
	  -DQT_FEATURE_sql_mimer=OFF # unpackaged
	  -DQT_FEATURE_sql_oci=OFF
	  -DQT_FEATURE_sql_odbc=OFF
	  $(qt_feature mysql sql_mysql)
	  $(qt_feature postgres sql_psql)
	  $(qt_feature sqlite sql_sqlite)
	  $(qt_feature sqlite system_sqlite)
	)
	 qt6-build_src_configure
}


# vim: filetype=ebuild
