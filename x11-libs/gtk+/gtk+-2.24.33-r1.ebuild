# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic gnome3 readme.gentoo-r1 virtualx

DESCRIPTION="Gimp ToolKit +"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="*"

IUSE="aqua cups examples +introspection test vim-syntax xinerama"
REQUIRED_USE="xinerama? ( !aqua )"

# Testes não são bem mantidos upstream
RESTRICT="test"

DEPEND="
	>=dev-libs/atk-2.10.0[introspection?]
	>=dev-libs/glib-2.62.2:2
	>=media-libs/fontconfig-2.10.92
	>=x11-libs/cairo-1.16.0[aqua?,svg]
	>=x11-libs/gdk-pixbuf-2.39.2:2[introspection?]
	>=x11-libs/pango-1.44.7[introspection?]
	x11-misc/shared-mime-info
	cups? ( >=net-print/cups-1.7.1-r2 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0 )
	!aqua? (
		>=x11-libs/libXrender-0.9.8
		>=x11-libs/libX11-1.6.2
		>=x11-libs/libXi-1.7.2
		>=x11-libs/libXext-1.3.2
		>=x11-libs/libXrandr-1.5
		>=x11-libs/libXcursor-1.1.14
		>=x11-libs/libXfixes-5.0.1
		>=x11-libs/libXcomposite-0.4.4-r1
		>=x11-libs/libXdamage-1.1.4-r1
		xinerama? ( >=x11-libs/libXinerama-1.1.3 )
	)
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd:4.1.2
	app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.20
	>=sys-devel/gettext-0.18.3
	virtual/pkgconfig
	!aqua? (
		>=x11-proto/xextproto-7.2.1-r1
		>=x11-proto/xproto-7.0.24
		>=x11-proto/inputproto-2.3
		>=x11-proto/damageproto-1.2.1
		xinerama? ( >=x11-proto/xineramaproto-1.2.1 )
	)
	test? (
		x11-themes/hicolor-icon-theme
		media-fonts/font-misc-misc
		media-fonts/font-cursor-misc
	)
"
RDEPEND="${DEPEND}
	>=dev-util/gtk-update-icon-cache-2
	!<gnome-base/gail-1000
	!<dev-util/gtk-builder-convert-${PV}
	!<x11-libs/vte-0.28.2-r201:0
	x11-themes/gnome-themes-standard
"
PDEPEND="
	x11-themes/gtk-engines-adwaita
	>=x11-themes/adwaita-icon-theme-3.14
	gnome-base/librsvg
	vim-syntax? ( app-vim/gtk-syntax )
"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="To make the gtk2 file chooser use 'current directory' mode by default,
edit ~/.config/gtk-2.0/gtkfilechooser.ini to contain the following:
[Filechooser Settings]
StartupMode=cwd"

src_prepare() {
	# Remover arquivos gerados que podem causar conflitos
	rm -f gdk/gdkmarshalers.{c,h} gtk/gtkmarshal.{c,h} gtk/gtkmarshalers.{c,h} \
		perf/marshalers.{c,h} gtk/gtkaliasdef.c gtk/gtkalias.h || die

	# Desativar documentação não mantida
	sed -e "s/^\(SUBDIRS =.*\)tutorial\(.*\)$/\1\2/" -i docs/Makefile.{am,in} || die
	sed -e "s/^\(SUBDIRS =.*\)faq\(.*\)$/\1\2/" -i docs/Makefile.{am,in} || die

	# Evitar otimizações agressivas que causam falhas
	replace-flags -O3 -O2
	strip-flags

	if ! use test; then
		# Desativar testes se não desejado
		sed -e "s/^\(SRC_SUBDIRS =.*\)tests\(.*\)$/\1\2/" -i Makefile.{am,in} || die
		sed -e "s/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/" -i gdk/Makefile.{am,in} gtk/Makefile.{am,in} || die
	else
		# Desativar testes problemáticos
		sed 's:\(g_test_add_func ("/ui-tests/keys-events.*\):/*\1*/:g' -i gtk/tests/testing.c || die
		sed '/TEST_PROGS.*recentmanager/d' -i gtk/tests/Makefile.am || die
		sed '/^TEST_PROGS =/,+3 s/recentmanager//' -i gtk/tests/Makefile.in || die
		sed 's:\({ "GtkFileChooserButton".*},\):/*\1*/:g' -i gtk/tests/object.c || die
		sed -i -e 's:pltcheck.sh:$(NULL):g' gtk/Makefile.am || die
		if ! has_version 'x11-libs/gtk+:2'; then
			ewarn "Desativando testes de UI porque gtk+:2 não está instalado."
			sed '/g_test_add_func.*ui-tests/ d' -i gtk/tests/testing.c || die
		fi
	fi

	if ! use examples; then
		# Desativar exemplos se não desejado
		sed -e "s/^\(SRC_SUBDIRS =.*\)demos\(.*\)$/\1\2/" -i Makefile.{am,in} || die
	fi

	# Corrigir comando inválido 'no' no Makefile.am
	sed -i -e 's/no --force/$(GTK_UPDATE_ICON_CACHE) --force/' gtk/Makefile.am || die "Failed to fix 'no' command in Makefile"

	# Aplicar patches
	eapply "${FILESDIR}/${PN}-2.24.24-out-of-source.patch"
	eapply "${FILESDIR}/${PN}-2.24.31-update-icon-cache.patch"
	eapply "${FILESDIR}"/${PN}-2.24.33-respect-NM.patch # requires eautoreconf
	eapply "${FILESDIR}"/${PN}-2.24.33-Fix-casts.patch

	eautoreconf
	gnome3_src_prepare
}

src_configure() {
	[[ ${ARCH} == ppc64 ]] && append-flags -mminimal-toc

	local myconf=(
		$(usex aqua --with-gdktarget=quartz --with-gdktarget=x11)
		$(usex aqua "" --with-xinput)
		$(use_enable cups cups auto)
		$(use_enable introspection)
		$(use_enable xinerama)
		--disable-papi
		--enable-man
		--with-xml-catalog="${EPREFIX}/etc/xml/catalog"
		CUPS_CONFIG="${EPREFIX}/usr/bin/cups-config"
	)

	ECONF_SOURCE="${S}" econf "${myconf[@]}"

	# Workaround para gtk-doc fora de fonte
	for d in gdk gtk libgail-util; do
		ln -s "${S}/docs/reference/${d}/html" "docs/reference/${d}/html" || die
	done
}

src_test() {
	virtx emake check
}

src_install() {
	gnome3_src_install

	# Configurações padrão do GTK2
	echo 'gtk-fallback-icon-theme = "gnome"' > "${T}/gtkrc"
	echo 'gtk-theme-name = "Adwaita"' >> "${T}/gtkrc"
	echo 'gtk-icon-theme-name = "Adwaita"' >> "${T}/gtkrc"
	echo 'gtk-cursor-theme-name = "Adwaita"' >> "${T}/gtkrc"
	insinto /usr/share/gtk-2.0
	doins "${T}/gtkrc"

	einstalldocs

	# Remover gtk-builder-convert, que é um pacote separado
	rm -f "${ED}/usr/bin/gtk-builder-convert" "${ED}/usr/share/man/man1/gtk-builder-convert.*" || die

	readme.gentoo_create_doc
}

pkg_preinst() {
	gnome3_pkg_preinst
	local cache="usr/$(get_libdir)/gtk-2.0/2.10.0/immodules.cache"
	if [[ -e "${EROOT}${cache}" ]]; then
		cp "${EROOT}${cache}" "${ED}/${cache}" || die
	else
		touch "${ED}/${cache}" || die
	fi
}

pkg_postinst() {
	gnome3_pkg_postinst
	gnome3_query_immodules_gtk2 || ewarn "Failed to update immodules cache"

	local GTK2_CONFDIR="/etc/gtk-2.0/${CHOST}"
	if [[ -e "${EROOT}${GTK2_CONFDIR}/gtk.immodules" ]]; then
		elog "Removing deprecated file ${EROOT}${GTK2_CONFDIR}/gtk.immodules"
		rm -f "${EROOT}${GTK2_CONFDIR}/gtk.immodules"
	fi
	if [[ -e "${EROOT}/etc/gtk-2.0/gtk.immodules" ]]; then
		elog "Removing deprecated file ${EROOT}/etc/gtk-2.0/gtk.immodules"
		rm -f "${EROOT}/etc/gtk-2.0/gtk.immodules"
	fi
	if [[ -e "${EROOT}${GTK2_CONFDIR}/gdk-pixbuf.loaders" || -e "${EROOT}/etc/gtk-2.0/gdk-pixbuf.loaders" ]]; then
		elog "Removing deprecated gdk-pixbuf.loaders files"
		rm -f "${EROOT}${GTK2_CONFDIR}/gdk-pixbuf.loaders" "${EROOT}/etc/gtk-2.0/gdk-pixbuf.loaders"
	fi

	if [[ -d "${EROOT}/usr/lib/gtk-2.0/2.[^1]*" ]]; then
		elog "Rebuild packages installed in ${EROOT}/usr/lib/gtk-2.0/2.[^1]* with: emerge -va1 \$(qfile -qC ${EPREFIX}/usr/lib/gtk-2.0/2.[^1]*)"
	fi

	if ! has_version "app-text/evince"; then
		elog "Install app-text/evince for print preview, or set gtk-print-preview-command in gtkrc."
	fi

	readme.gentoo_print_elog
}

pkg_postrm() {
	gnome3_pkg_postrm
	if [[ -z "${REPLACED_BY_VERSION}" ]]; then
		rm -f "${EROOT}usr/$(get_libdir)/gtk-2.0/2.10.0/immodules.cache"
	fi
}
