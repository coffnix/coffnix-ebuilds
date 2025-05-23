# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="xml"

inherit gnome3 python-single-r1 toolchain-funcs meson

DESCRIPTION="Introspection system for GObject-based libraries"
HOMEPAGE="https://wiki.gnome.org/Projects/GObjectIntrospection"

LICENSE="LGPL-2+ GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="cairo doc doctool"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

# virtual/pkgconfig needed at runtime, bug #505408
# We force glib and g-i to be in sync by this way as explained in bug #518424
RDEPEND="
	>=dev-libs/gobject-introspection-common-${PV}
	>=dev-libs/glib-2.64.0:2
	virtual/libffi:=
	doctool? ( $(python_gen_cond_dep '
		dev-python/mako[${PYTHON_USEDEP}]
		dev-python/markdown[${PYTHON_USEDEP}]
		')
	)
	virtual/pkgconfig
	${PYTHON_DEPS}
"
# Wants real bison, not virtual/yacc
DEPEND="${RDEPEND}
	>=dev-util/meson-0.55.3
	doc? ( >=dev-util/gtk-doc-1.19
		app-text/docbook-xml-dtd:4.3
		app-text/docbook-xml-dtd:4.5
	)
	sys-devel/bison
	sys-devel/flex
"
# PDEPEND to avoid circular dependencies, bug #391213
PDEPEND="cairo? ( x11-libs/cairo[glib] )"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	# we want to configure the various tools to specifically reference the version of python
	# we are building against. Otherwise, eselect python changes can break gobject-introspection.

	sed -i -e "/PYTHON_CMD/s:python_cmd:'$PYTHON':" tools/meson.build || die
	default
}

src_configure() {
	local mesonargs=(
		$(meson_use cairo) \
		$(meson_use doc gtk_doc) \
		$(meson_use doctool)
		-Dpython="${EPYTHON}"
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	python_fix_shebang "${ED}"/usr/bin/
	python_optimize "${ED}"/usr/$(get_libdir)/gobject-introspection/giscanner

	# Prevent collision with gobject-introspection-common
	rm -v "${ED}"/usr/share/aclocal/introspection.m4 \
		"${ED}"/usr/share/gobject-introspection-1.0/Makefile.introspection || die
	rmdir "${ED}"/usr/share/aclocal || die
}
