# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit meson gnome3 python-any-r1 toolchain-funcs

DESCRIPTION="GTK is a multi-platform toolkit for creating graphical user interfaces"
HOMEPAGE="https://www.gtk.org/ https://gitlab.gnome.org/GNOME/gtk/"
SRC_URI="https://download.gnome.org/sources/gtk/4.21/gtk-4.21.4.tar.xz -> gtk-4.21.4.tar.xz"
LICENSE="LGPL-2+"
SLOT="4"
KEYWORDS="*"
IUSE="aqua broadway cloudproviders colord cups cups examples
gstreamer gtk-doc +introspection sysprof vulkan wayland
+X
"
REQUIRED_USE="|| ( aqua wayland X )
gtk-doc? ( introspection )
"
# Commons depends
CDEPEND="dev-libs/glib:2
	x11-libs/cairo[aqua?,glib,X?]
	x11-libs/pango[introspection?]
	dev-libs/fribidi
	media-libs/harfbuzz:=
	x11-libs/gdk-pixbuf:2[introspection?]
	media-libs/libpng:=
	media-libs/tiff:=
	media-libs/libjpeg-turbo:=
	gnome-base/librsvg:2
	media-libs/libepoxy[egl(+),X(+)?]
	media-libs/graphene[introspection?]
	app-text/iso-codes
	x11-misc/shared-mime-info
	cloudproviders? ( net-libs/libcloudproviders )
	colord? ( x11-misc/colord:= )
	cups? ( net-print/cups )
	examples? ( gnome-base/librsvg:2 )
	gstreamer? (
	  media-libs/gstreamer
	  media-libs/gst-plugins-bad
	  || (
	    media-libs/gst-plugins-base[gles2]
	    media-libs/gst-plugins-base[opengl]
	  )
	)
	introspection? ( dev-libs/gobject-introspection:= )
	vulkan? ( media-libs/vulkan-loader[wayland?,X?] )
	wayland? (
	  dev-libs/wayland
	  dev-libs/wayland-protocols
	  media-libs/mesa[wayland]
	  x11-libs/libxkbcommon
	)
	X? (
	  media-libs/fontconfig
	  media-libs/mesa[X(+)]
	  x11-libs/libX11
	  x11-libs/libXi
	  x11-libs/libXext
	  x11-libs/libXcursor
	  x11-libs/libXfixes
	  x11-libs/libXdamage
	  x11-libs/libXinerama
	)
	
"
BDEPEND="dev-libs/gobject-introspection-common
	introspection? (
	  ${PYTHON_DEPS}
	  $(python_gen_any_dep '
	    dev-python/pygobject:3[${PYTHON_USEDEP}]
	  ')
	)
	dev-python/docutils
	dev-util/gdbus-codegen
	sys-devel/gettext
	virtual/pkgconfig
	gtk-doc? ( dev-util/gi-docgen )
	vulkan? ( media-libs/shaderc )
	wayland? ( dev-util/wayland-scanner )
	
"
RDEPEND="${CDEPEND}
	dev-util/gtk-update-icon-cache
	
"
DEPEND="${CDEPEND}
	x11-libs/libdrm
	sys-kernel/linux-headers
	sysprof? ( dev-util/sysprof )
	X? ( x11-base/xorg-proto )
	
"
PDEPEND="x11-themes/adwaita-icon-theme
	
"
pkg_setup() {
	use introspection && python-any-r1_pkg_setup
}
src_prepare() {
	default
	xdg_environment_reset
	# Nothing should use gtk4-update-icon-cache and an unversioned one
	# is shipped by dev-util/gtk-update-icon-cache
	sed -i \
	  -e '/gtk4-update-icon-cache/d' \
	  docs/reference/gtk/meson.build \
	  tools/meson.build \
	  || die
}
src_configure() {
	local emesonargs=(
	  # GDK backends
	  $(meson_use X x11-backend)
	  $(meson_use wayland wayland-backend)
	  $(meson_use broadway broadway-backend)
	  -Dwin32-backend=false
	  -Dandroid-backend=false
	  $(meson_use aqua macos-backend)
	  # Media backends
	  $(meson_feature gstreamer media-gstreamer)
	  # Print backends
	  -Dprint-cpdb=disabled
	  $(meson_feature cups print-cups)
	  $(meson_feature vulkan)
	  $(meson_feature cloudproviders)
	  $(meson_feature sysprof)
	  -Dtracker=disabled  # tracker3 is not packaged in Gentoo yet
	  $(meson_feature colord)
	  -Dandroid-runtime=disabled
	  $(meson_feature introspection)
	  $(meson_use gtk-doc documentation)
	  -Dscreenshots=false
	  -Dman-pages=true
	  -Dprofile=default
	  $(meson_use examples build-demos)
	  $(meson_use examples build-examples)
	  -Dbuild-testsuite=false
	  -Dbuild-tests=false
	)
	meson_src_configure
}
src_install() {
	meson_src_install
	if use gtk-doc; then
	  mkdir -p "${ED}"/usr/share/gtk-doc/html/ || die
	  mv "${ED}"/usr/share/doc/{gtk4,gsk4,gdk4{,-wayland,-x11}} "${ED}"/usr/share/gtk-doc/html/ || die
	fi
}
pkg_preinst() {
	gnome3_pkg_preinst
}
pkg_postinst() {
	gnome3_pkg_postinst
	if ! has_version "app-text/evince"; then
	  elog "Please install app-text/evince for print preview functionality."
	  elog "Alternatively, check \"gtk-print-preview-command\" documentation and"
	  elog "add it to your settings.ini file."
	fi
}
pkg_postrm() {
	gnome3_pkg_postrm
}


# vim: filetype=ebuild
