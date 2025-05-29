# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="Mobile Broadband Interface Model (MBIM) modem protocol helper library"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/libmbim/ https://gitlab.freedesktop.org/mobile-broadband/libmbim"
SRC_URI="https://gitlab.freedesktop.org/mobile-broadband/libmbim/-/archive/1.32.0/libmbim-1.32.0.tar.bz2 -> libmbim-1.32.0.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND=">=dev-libs/glib-2.56:2
	dev-libs/gobject-introspection"
DEPEND="${RDEPEND}"
BDEPEND="
	app-shells/bash-completion
	dev-util/glib-utils
	virtual/pkgconfig
"