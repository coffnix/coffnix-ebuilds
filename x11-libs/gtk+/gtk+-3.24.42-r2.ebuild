# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson virtualx

DESCRIPTION="Gimp ToolKit +"
HOMEPAGE="https://www.gtk.org/"

SRC_URI="https://download.gnome.org/sources/gtk+/${PV%.*}/gtk+-${PV}.tar.xz"

LICENSE="LGPL-2+"
SLOT="3"
IUSE="aqua broadway colord cups +doc examples +introspection test vim-syntax wayland +X xinerama"
REQUIRED_USE="
	|| ( aqua wayland X )
	xinerama? ( X )
	colord? ( cups )
"

KEYWORDS="*"

RESTRICT="!test? ( test )"

COMMON_DEPEND="
	sys-apps/dbus
	>=dev-libs/atk-2.15[introspection?]
	>=dev-libs/fribidi-0.19.7
	>=dev-libs/glib-2.70.0-r1:2=
	media-libs/fontconfig
	>=media-libs/libepoxy-1.4[X(+)?]
	>=x11-libs/cairo-1.16.0[aqua?,glib,svg,X?]
	>=x11-libs/gdk-pixbuf-2.39.2:2[introspection?]
	>=x11-libs/pango-1.44.7[introspection?]
	>=media-libs/harfbuzz-0.9:=
	x11-misc/shared-mime-info
	colord? ( >=x11-misc/colord-0.1.9:0= )
	cups? ( >=net-print/cups-2.0 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	wayland? (
		>=dev-libs/wayland-1.14.91
		>=dev-libs/wayland-protocols-1.16
		media-libs/mesa[wayland]
		>=x11-libs/libxkbcommon-0.2
	)
	X? (
		>=app-accessibility/at-spi2-atk-2.5.3
		media-libs/mesa[X(+)]
		x11-libs/libX11
		>=x11-libs/libXi-1.3
		x11-libs/libXext
		>=x11-libs/libXrandr-1.5
		x11-libs/libXcursor
		x11-libs/libXfixes
		x11-libs/libXcomposite
		x11-libs/libXdamage
		xinerama? ( x11-libs/libXinerama )
	)
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd:4.1.2
	dev-libs/libxslt
	dev-libs/gobject-introspection-common
	>=dev-util/gdbus-codegen-2.48
	dev-util/glib-utils
	>=dev-util/gtk-doc-am-1.20
	doc? (
		>=dev-util/gtk-doc-1.20
		app-text/docbook-xml-dtd:4.3
	)
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
	X? ( x11-base/xorg-proto )
	test? (
		media-fonts/font-misc-misc
		media-fonts/font-cursor-misc
	)
"
RDEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-update-icon-cache-3
	!<gnome-base/gail-1000
	!<x11-libs/vte-0.31.0:2.90
"
PDEPEND="
	gnome-base/librsvg
	>=x11-themes/adwaita-icon-theme-3.14
	vim-syntax? ( app-vim/gtk-syntax )
"

S="${WORKDIR}/gtk+-${PV}"

src_prepare() {
	default

	# Aplica patch para gtk-update-icon-cache (ajuste o nome do patch conforme disponível)
	# eapply "${FILESDIR}"/gtk+-3.24.8-update-icon-cache.patch
}

src_configure() {
	local emesonargs=(
		-Dquartz_backend=$(usex aqua true false)
		-Dbroadway_backend=$(usex broadway true false)
		-Dcolord=$(usex colord yes no)
		-Dprint_backends=$(usex cups "cups,file,lpr" "file,lpr")
		-Dgtk_doc=$(usex doc true false)
		-Dexamples=$(usex examples true false)
		-Dintrospection=$(usex introspection true false)
		-Dtests=$(usex test true false)
		-Dwayland_backend=$(usex wayland true false)
		-Dx11_backend=$(usex X true false)
		-Dxinerama=$(usex xinerama yes no)
		-Dbuiltin_immodules=backend
		-Dman=true
		-Dcloudproviders=false  # Desativado por padrão, não disponível no Funtoo
		-Dprofiler=false        # Desativado por padrão, requer sysprof mais recente
	)
	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_test() {
	virtx meson test -C "${BUILD_DIR}" --timeout-multiplier 4 || die
}

src_install() {
	meson_src_install

	insinto /etc/gtk-3.0
	doins "${FILESDIR}"/settings.ini
	DOCS=( NEWS README.md )
	einstalldocs
}

pkg_postinst() {
	# Atualiza o cache de módulos de entrada
	gnome2_query_immodules_gtk3 || die "Failed to update immodules cache"

	if ! has_version "app-text/evince"; then
		elog "Please install app-text/evince for print preview functionality."
		elog "Alternatively, check 'gtk-print-preview-command' documentation and"
		elog "add it to your settings.ini file."
	fi
}
