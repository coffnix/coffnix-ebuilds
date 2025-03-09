# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes"
GNOME3_EAUTORECONF="yes"

inherit flag-o-matic gnome3 virtualx

DESCRIPTION="Gimp ToolKit +"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2+"
SLOT="3"
IUSE="aqua broadway cloudprint colord cups +doc examples +introspection test vim-syntax wayland +X xinerama"
REQUIRED_USE="
	|| ( aqua wayland X )
	xinerama? ( X )
	colord? ( cups )
"

KEYWORDS="*"

# Upstream wants us to do their job:
# https://bugzilla.gnome.org/show_bug.cgi?id=768662#c1
RESTRICT="test"

# FIXME: introspection data is built against system installation of gtk+:3,
# bug #????
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

	cloudprint? (
		>=net-libs/rest-0.7
		>=dev-libs/json-glib-1.0 )
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
	doc? (	>=dev-util/gtk-doc-1.20
			app-text/docbook-xml-dtd:4.3 )
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
	X? ( x11-base/xorg-proto )
	test? (
		media-fonts/font-misc-misc
		media-fonts/font-cursor-misc )
"
# gtk+-3.2.2 breaks Alt key handling in <=x11-libs/vte-0.30.1:2.90
# gtk+-3.3.18 breaks scrolling in <=x11-libs/vte-0.31.0:2.90
RDEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-update-icon-cache-3
	!<gnome-base/gail-1000
	!<x11-libs/vte-0.31.0:2.90
"
# librsvg for svg icons (PDEPEND to avoid circular dep), bug #547710
PDEPEND="
	gnome-base/librsvg
	>=x11-themes/adwaita-icon-theme-3.14
	vim-syntax? ( app-vim/gtk-syntax )
"

strip_builddir() {
	local rule=$1
	shift
	local directory=$1
	shift
	sed -e "s/^\(${rule} =.*\)${directory}\(.*\)$/\1\2/" -i $@ \
		|| die "Could not strip director ${directory} from build."
}

src_prepare() {
	# -O3 and company cause random crashes in applications. Bug #133469
	replace-flags -O3 -O2
	strip-flags

	if ! use test ; then
		# don't waste time building tests
		strip_builddir SRC_SUBDIRS testsuite Makefile.{am,in}

		# the tests dir needs to be build now because since commit
		# 7ff3c6df80185e165e3bf6aa31bd014d1f8bf224 tests/gtkgears.o needs to be there
		# strip_builddir SRC_SUBDIRS tests Makefile.{am,in}
	fi

	if ! use examples; then
		# don't waste time building demos
		strip_builddir SRC_SUBDIRS demos Makefile.{am,in}
		strip_builddir SRC_SUBDIRS examples Makefile.{am,in}
	fi


	# gtk-update-icon-cache is installed by dev-util/gtk-update-icon-cache
	eapply "${FILESDIR}"/${PN}-3.24.8-update-icon-cache.patch

	# Fix broken autotools logic
	eapply "${FILESDIR}"/${PN}-3.22.20-libcloudproviders-automagic.patch

	gnome3_src_prepare
}

src_configure() {
	local myconf=(
		$(use_enable aqua quartz-backend)
		$(use_enable broadway broadway-backend)
		$(use_enable cloudprint)
		$(use_enable colord)
		$(use_enable cups cups auto)
		$(use_enable doc gtk-doc)
		$(use_enable introspection)
		$(use_enable wayland wayland-backend)
		$(use_enable X x11-backend)
		$(use_enable X xcomposite)
		$(use_enable X xdamage)
		$(use_enable X xfixes)
		$(use_enable X xkb)
		$(use_enable X xrandr)
		$(use_enable xinerama)
		# cloudprovider is not packaged in Gentoo yet
		--disable-cloudproviders
		--disable-papi
		# sysprof integration needs >=sysprof-3.33.2
		--disable-profiler
		--enable-man
		--with-xml-catalog="${EPREFIX}"/etc/xml/catalog
		# need libdir here to avoid a double slash in a path that libtool doesn't
		# grok so well during install (// between $EPREFIX and usr ...)
		# TODO: Is this still the case?
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		CUPS_CONFIG="${EPREFIX}/usr/bin/${CHOST}-cups-config"
	)

	if use wayland; then
		myconf+=(
			# Include wayland immodule into gtk itself, to avoid problems like
			# https://gitlab.gnome.org/GNOME/gnome-shell/issues/109 from a
			# user overridden GTK_IM_MODULE envvar
			--with-included-immodules=wayland
		)
	fi;

	ECONF_SOURCE=${S} gnome3_src_configure "${myconf[@]}"

	# work-around gtk-doc out-of-source brokedness
	local d
	for d in gdk gtk libgail-util; do
		ln -s "${S}"/docs/reference/${d}/html docs/reference/${d}/html || die
	done
}

src_test() {
	"${EROOT}/${GLIB_COMPILE_SCHEMAS}" --allow-any-name "${S}/gtk" || die
	GSETTINGS_SCHEMA_DIR="${S}/gtk" virtx emake check
}

src_install() {
	gnome3_src_install

	insinto /etc/gtk-3.0
	doins "${FILESDIR}"/settings.ini
	# Skip README.{in,commits,win32} that would get installed by default
	DOCS=( AUTHORS ChangeLog NEWS README )
	einstalldocs
}

pkg_postinst() {
	gnome3_pkg_postinst

	if ! has_version "app-text/evince"; then
		elog "Please install app-text/evince for print preview functionality."
		elog "Alternatively, check \"gtk-print-preview-command\" documentation and"
		elog "add it to your settings.ini file."
	fi
}
