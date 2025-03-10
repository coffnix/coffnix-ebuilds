# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit systemd

DESCRIPTION="Portable sound event library"
HOMEPAGE="http://0pointer.de/lennart/projects/libcanberra/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"
IUSE="alsa gnome gstreamer +gtk2 +gtk3 oss pulseaudio +sound tdb udev"

DEPEND="
	dev-libs/libltdl:0
	media-libs/libvorbis
	alsa? (
		media-libs/alsa-lib
		udev? ( virtual/libudev )
	)
	gstreamer? ( media-libs/gstreamer:1.0 )
	gtk2? (
		>=dev-libs/glib-2.32:2
		>=x11-libs/gtk+-2.20.0:2
		x11-libs/libX11
	)
	gtk3? (
		>=dev-libs/glib-2.32:2
		x11-libs/gtk+:3[X]
		x11-libs/libX11
	)
	pulseaudio? ( >=media-sound/pulseaudio-0.9.11 )
	tdb? ( sys-libs/tdb )
"
RDEPEND="${DEPEND}
	gnome? (
		gnome-base/dconf
		gnome-base/gsettings-desktop-schemas
	)
	sound? ( x11-themes/sound-theme-freedesktop )
"
BDEPEND="
	app-arch/xz-utils
	virtual/pkgconfig
"

REQUIRED_USE="udev? ( alsa )"

PATCHES=(
	# gtk: Don't assume all GdkDisplays are GdkX11Displays: broadway/wayland (from 'master')
	"${FILESDIR}/${PN}-0.30-wayland.patch"
)

src_configure() {
	local myconf=(
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
		$(use_enable alsa)
		$(use_enable oss)
		$(use_enable pulseaudio pulse)
		$(use_enable gstreamer)
		$(use_enable gtk2 gtk)
		$(use_enable gtk3)
		$(use_enable tdb)
		$(use_enable udev)
		--disable-lynx
		--disable-gtk-doc
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
	)

	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

src_install() {
	# Disable parallel installation until bug #253862 is solved
	emake DESTDIR="${D}" -j1 install

	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die

	# Adicionar script para desktops além do GNOME (bug #520550)
	exeinto /etc/X11/xinit/xinitrc.d
	newexe "${FILESDIR}"/libcanberra-gtk-module.sh 40-libcanberra-gtk-module
}
