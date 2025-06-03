# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools gnome3

DESCRIPTION="Compiler for the GObject type system"
HOMEPAGE="https://wiki.gnome.org/Projects/Vala"

LICENSE="LGPL-2.1"
SLOT="0.54"
KEYWORDS="*"

COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/vala-common-${PV}
	>=media-gfx/graphviz-2.40.1
	>=dev-libs/gobject-introspection-1.66.0:=
"

RDEPEND="
	${COMMON_DEPEND}
	!${CATEGORY}/${PN}:0
	!dev-lang/vala:0.38
"

DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	sys-devel/flex
	virtual/pkgconfig
	virtual/yacc
"

src_configure() {
	# weasyprint enables generation of PDF from HTML
	gnome3_src_configure \
		--disable-unversioned \
		VALAC=: \
		WEASYPRINT=:
}



src_install() {
	default
	find "${D}" -name "*.la" -delete || die

	local VMAJOR=$(ver_cut 1-2)

	dosym vala-${VMAJOR} /usr/bin/vala || die
	dosym valac-${VMAJOR} /usr/bin/valac || die
	dosym vapigen-${VMAJOR} /usr/bin/vapigen || die
	dosym valadoc-${VMAJOR} /usr/bin/valadoc || die
	dosym vala-gen-introspect-${VMAJOR} /usr/bin/vala-gen-introspect || die
}
