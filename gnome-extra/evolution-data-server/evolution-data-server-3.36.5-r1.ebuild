# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
VALA_USE_DEPEND="vapigen"

inherit db-use flag-o-matic gnome3 python-any-r1 systemd vala virtualx cmake-utils

DESCRIPTION="Evolution groupware backend"
HOMEPAGE="https://wiki.gnome.org/Apps/Evolution"

LICENSE="|| ( LGPL-2 LGPL-3 ) BSD Sleepycat"
SLOT="0/62"
KEYWORDS="*"

IUSE="api-doc-extras -berkdb +gnome-online-accounts +gtk +google +introspection ipv6 ldap kerberos vala +weather"
REQUIRED_USE="vala? ( introspection )"

gdata_depend=">=dev-libs/libgdata-0.17.7:="
RDEPEND="
	>=app-crypt/gcr-3.4
	>=app-crypt/libsecret-0.5[crypt]
	>=dev-db/sqlite-3.7.17:=
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libical-3.0.7:=
	>=dev-libs/libxml2-2
	>=dev-libs/nspr-4.4:=
	>=dev-libs/nss-3.9:=
	>=net-libs/libsoup-2.42:2.4
	dev-libs/icu:=
	sys-libs/zlib:=
	virtual/libiconv
	berkdb? ( =sys-libs/db-18.1*:18.1 )
	gtk? (
		>=app-crypt/gcr-3.4[gtk]
		>=x11-libs/gtk+-3.24.12:3
	)
	google? (
		>=dev-libs/json-glib-1.0.4
		>=net-libs/webkit-gtk-2.11.91:4
		${gdata_depend}
	)
	gnome-online-accounts? (
		>=net-libs/gnome-online-accounts-3.8:=
		${gdata_depend} )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	kerberos? ( virtual/krb5:= )
	ldap? ( >=net-nds/openldap-2:= )
	weather? ( >=dev-libs/libgweather-3.10:2= )
	>=media-libs/libcanberra-0.2.5
"

DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	dev-util/gperf
	>=dev-util/gtk-doc-am-1.14
	>=dev-util/intltool-0.35.5
	>=gnome-base/gnome-common-2
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

RESTRICT="test"

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	find "${S}" -type f -name '*.[ch]' -exec sed -i 's/\boff64_t\b/goffset/g' {} +
	# Corrige erros de compatibilidade com Vala >=0.52
	find . -name '*.vala' -exec sed -i \
		-e 's/\[GtkChild\] *\(.*\)/[GtkChild] unowned \1/' \
		-e 's/ref \([a-zA-Z_][a-zA-Z0-9_]*\)/\1/g' {} + || die "Failed to patch Vala code"

	# Substitui off_t por goffset nos headers e fontes
	einfo "Substituindo off_t por goffset nos fontes relevantes..."
	find "${S}"/src -type f \( -name '*.c' -o -name '*.h' -o -name '*.vala' -o -name '*.metadata' \) \
		-exec sed -i 's/\boff_t\b/goffset/g' {} + || die "falha ao substituir off_t por goffset"

	# Copia metadados personalizados
	cp "${FILESDIR}/camel-1.2.metadata" "${S}/src/vala/" || die "Failed to copy camel-1.2.metadata"
	export VAPIGEN_EXTRA_ARGS="--metadata=${S}/src/vala/camel-1.2.metadata"

	export VALAC=/usr/bin/vala-0.54
	export VAPIGEN=/usr/bin/vapigen-0.54
	export XDG_DATA_DIRS="${EPREFIX}/usr/share:${XDG_DATA_DIRS}"
	export GI_TYPELIB_PATH="${EPREFIX}/usr/lib64/girepository-1.0"

	eapply "${FILESDIR}"/3.36.5-gtk-doc-1.32-compat.patch
	eapply "${FILESDIR}"/vala.patch

	use vala && vala_src_prepare
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DSYSCONF_INSTALL_DIR="/etc"
		-DENABLE_GOA=$(usex gnome-online-accounts)
		-DENABLE_OAUTH2=ON
		-DENABLE_GTK=$(usex gtk)
		-DENABLE_GTK_DOC=$(usex api-doc-extras)
		-DENABLE_INTROSPECTION=$(usex introspection)
		-DENABLE_IPV6=$(usex ipv6)
		-DENABLE_VALA_BINDINGS=$(usex vala)
		-DENABLE_WEATHER=$(usex weather)
		-DWITH_PRIVATE_DOCS=$(usex api-doc-extras "ON" "OFF")
		-DWITH_OPENLDAP=$(usex ldap "ON" "OFF")
		-DWITH_KRB5=$(usex kerberos "ON" "OFF")
		-DWITH_KRB5_LIBS=$(usex kerberos "${EPREFIX}"/usr/$(get_libdir) "")
		-DWITH_CFLAGS=$(usex berkdb "-I$(db_includedir)" "")
		-DENABLE_LARGEFILE=ON
		-DENABLE_SMIME=ON
		-DWITH_SYSTEMDUSERUNITDIR="$(systemd_get_userunitdir)"
		-DWITH_PHONENUMBER=OFF
		-DENABLE_EXAMPLES=OFF
		-DENABLE_UOA=OFF
		-DENABLE_LIBCANBERRA=ON
		-Denable-installed-tests=false
	)

	if use berkdb; then
		mycmakeargs+=(
			-DWITH_LIBDB=/usr
			-DWITH_LIBDB_CFLAGS=-I/usr/include/db18.1
			-DWITH_LIBDB_LIBS=-ldb-18.1
		)
	else
		mycmakeargs+=( -DWITH_LIBDB=OFF )
	fi

	if use google || use gnome-online-accounts; then
		mycmakeargs+=( -DENABLE_GOOGLE=ON )
	else
		mycmakeargs+=( -DENABLE_GOOGLE=OFF )
	fi

	cmake-utils_src_configure
}

src_test() {
	unset ORBIT_SOCKETDIR
	unset SESSION_MANAGER
	virtx emake check
}

src_compile() {
	cmake-utils_src_compile || die "compile falhou"
}

src_install() {
	addwrite /usr/share/glib-2.0/schemas/org.gnome.Evolution.DefaultSources.gschema.xml
	addwrite /usr/share/glib-2.0/schemas/org.gnome.evolution-data-server.gschema.xml
	addwrite /usr/share/glib-2.0/schemas/org.gnome.evolution-data-server.calendar.gschema.xml
	addwrite /usr/share/glib-2.0/schemas/org.gnome.evolution.eds-shell.gschema.xml
	addwrite /usr/share/glib-2.0/schemas/org.gnome.evolution-data-server.addressbook.gschema.xml
	addwrite /usr/share/glib-2.0/schemas/org.gnome.evolution.shell.network-config.gschema.xml
	addwrite /usr/share/glib-2.0/schemas/

	cmake-utils_src_install

	if use ldap; then
		insinto /etc/openldap/schema
		doins "${FILESDIR}"/calentry.schema
		dosym /usr/share/${PN}/evolutionperson.schema /etc/openldap/schema/evolutionperson.schema
	fi
}
