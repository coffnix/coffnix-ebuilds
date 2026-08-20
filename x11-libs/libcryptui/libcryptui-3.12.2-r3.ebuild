# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

inherit gnome2

DESCRIPTION="User interface components for OpenPGP"
HOMEPAGE="https://wiki.gnome.org/Apps/Seahorse"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1"
SLOT="0"
IUSE="debug +introspection libnotify"
KEYWORDS="*"

# Pull in libnotify-0.7 because it's controlled via an automagic ifdef
COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2
	>=x11-libs/gtk+-3:3[introspection?]
	>=dev-libs/dbus-glib-0.72
	>=app-crypt/gcr-3[gtk]
	x11-libs/libICE
	x11-libs/libSM

	>=app-crypt/gpgme-2.1.2
	>=app-crypt/gnupg-1.4

	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	libnotify? ( >=x11-libs/libnotify-0.7:= )
"

DEPEND="${COMMON_DEPEND}
	app-text/rarian
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
"

# Before 3.1.4, libcryptui was part of seahorse
RDEPEND="${COMMON_DEPEND}
	!<app-crypt/seahorse-3.1.4
"

PATCHES=(
	# Support GnuPG 2.1, in master
	# https://bugzilla.gnome.org/show_bug.cgi?id=745843
	"${FILESDIR}"/${PN}-3.12.2-gnupg-2.1.patch

	# from master, in Debian as well
	"${FILESDIR}"/${PN}-3.12.2-prompt-recipient.patch
	"${FILESDIR}"/${PN}-3.12.2-fix-return-types.patch
	"${FILESDIR}"/${PN}-3.12.2-port-gcr-3.patch

	# Support GnuPG 2.2
	# https://bugs.gentoo.org/show_bug.cgi?id=629572
	"${FILESDIR}"/${PN}-3.12.2-gnupg-2.2.patch

	# Support GnuPG 2.3
	# https://bugs.gentoo.org/820143
	# https://bugs.funtoo.org/browse/FL-10660
	"${FILESDIR}"/${PN}-3.12.2-gnupg-2.3.patch
)

src_prepare() {
	# FIXME: Do not mess with CFLAGS with USE="debug"
	sed -e '/CFLAGS="$CFLAGS -g -O0/d' \
		-e 's/-Werror//' \
		-i configure.ac configure || die "sed failed"

	# GPGME 2.x no longer uses gpgme-config.
	python - "${S}/configure.ac" <<'PY'
import sys

path = sys.argv[1]

with open(path, "r") as f:
    data = f.read()

start = data.find('AC_PATH_PROG(GPGME_CONFIG, gpgme-config, "failed")')
if start == -1:
    raise SystemExit("GPGME configure block start not found")

end_marker = 'SEAHORSE_CFLAGS="$SEAHORSE_CFLAGS $GPGME_CFLAGS"'
end = data.find(end_marker, start)
if end == -1:
    raise SystemExit("GPGME configure block end not found")

replacement = '''PKG_CHECK_MODULES([GPGME], [gpgme >= 1.0.0])
have_gpgme=`$PKG_CONFIG --modversion gpgme`

'''

data = data[:start] + replacement + data[end:]

with open(path, "w") as f:
    f.write(data)
PY

	# GPGME 2.x removed the old trustlist event.
	sed -i \
		'/GPGME_EVENT_NEXT_TRUSTITEM/d' \
		daemon/seahorse-gpgme-operation.c || die "failed to remove obsolete GPGME event"

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--disable-update-mime-database \
		$(use_enable debug) \
		$(use_enable introspection) \
		$(use_enable libnotify)
}
