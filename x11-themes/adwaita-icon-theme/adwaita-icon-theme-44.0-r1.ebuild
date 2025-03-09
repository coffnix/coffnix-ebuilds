# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome3

DESCRIPTION="GNOME default icon theme"
HOMEPAGE="https://git.gnome.org/browse/adwaita-icon-theme/"

SRC_URI="https://download.gnome.org/sources/adwaita-icon-theme/44/adwaita-icon-theme-44.0.tar.xz
	branding? ( https://www.mail-archive.com/tango-artists@lists.freedesktop.org/msg00043/tango-gentoo-v1.1.tar.gz )"

LICENSE="
	|| ( LGPL-3 CC-BY-SA-3.0 )
	branding? ( CC-Sampling-Plus-1.0 )
"
SLOT="0"
KEYWORDS="*"

IUSE="branding"

COMMON_DEPEND="
	>=x11-themes/hicolor-icon-theme-0.10
"
DEPEND="${COMMON_DEPEND}
	>=x11-libs/gtk+-3.24.12:3
	gnome-base/librsvg:2
	sys-devel/gettext
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/librsvg:2
	!<x11-themes/gnome-themes-standard-3.14
"
RESTRICT="binchecks strip"

src_prepare() {
	if use branding; then
		for i in 16 22 24 32 48; do
			cp "${WORKDIR}"/tango-gentoo-v1.1/${i}x${i}/gentoo.png \
				"${S}"/Adwaita/${i}x${i}/places/start-here.png \
				|| die "Copying gentoo logos failed"
		done
	fi

	# Ajuste do cursordir
	sed -e 's:^\(cursordir.*\)icons\(.*\):\1cursors/xorg-x11\2:' \
		-i "${S}"/Makefile.am \
		-i "${S}"/Makefile.in || die "Failed to adjust cursordir"

	# Remove width e height dos SVGs simbólicos
	find "${S}/Adwaita/scalable" -name "*.svg" -exec sed -i 's/width="[^"]*" height="[^"]*"//' {} + || die "Failed to adjust SVG sizes"

	gnome3_src_prepare
}

pkg_postinst() {
	gnome3_pkg_postinst
	XDG_UPDATE_ICON_CACHE=$(type -P true)
}
