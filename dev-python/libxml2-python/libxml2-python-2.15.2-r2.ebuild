# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit meson python-r1

DESCRIPTION="Python binding of XML C parser and toolkit"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libxml2/-/wikis/home"
SRC_URI="https://download.gnome.org/sources/libxml2/${PV%.*}/libxml2-${PV}.tar.xz -> libxml2-${PV}.tar.xz"

SLOT="2"
KEYWORDS="*"
IUSE="+icu +lzma readline static-libs"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	=dev-libs/libxml2-${PV}:=[lzma?,icu?,readline?,static-libs?]
	!<dev-python/libxml2-python-2.15.0
"

DEPEND="${RDEPEND}"

BDEPEND="
	app-doc/doxygen
"

S="${WORKDIR}/libxml2-${PV}"

src_prepare() {
	default

	sed -e "/^dir_doc/ s/meson.project_name()$/\'${PF}\'/" -i meson.build || die

	# Permit to compile libxml2 on stage3 without git installed.
	# Hack git command with echo in order to print an empty string.
	sed -e 's|git|echo|g' -e 's|describe||g' -i meson.build || die
}

python_configure() {
	BUILD_DIR="${WORKDIR}/${P}-build-${EPYTHON}"

	mkdir -p "${T}/python-${EPYTHON}" || die
	ln -snf "$(command -v "${EPYTHON}")" "${T}/python-${EPYTHON}/python3" || die
	ln -snf "$(command -v "${EPYTHON}")" "${T}/python-${EPYTHON}/python" || die

	local -x PATH="${T}/python-${EPYTHON}:${PATH}"
	local -x PYTHON="${EPYTHON}"
	local -x PYTHON_FOR_BUILD="${EPYTHON}"

	local emesonargs=(
		-Ddefault_library=$(usex static-libs both shared)
		-Ddocs=disabled
		$(meson_feature icu)
		$(meson_feature readline)
		$(meson_feature readline history)
		-Dpython=enabled
		-Dschematron=enabled
		-Dlegacy=disabled
	)

	meson_src_configure
}

src_configure() {
	python_foreach_impl python_configure
}

python_compile() {
	BUILD_DIR="${WORKDIR}/${P}-build-${EPYTHON}"
	meson_src_compile
}

src_compile() {
	python_foreach_impl python_compile
}

python_install() {
	BUILD_DIR="${WORKDIR}/${P}-build-${EPYTHON}"
	meson_src_install
}

src_install() {
	python_foreach_impl python_install

	rm -f "${ED}"/usr/bin/xml2-config || die
	rm -f "${ED}"/usr/bin/xmlcatalog || die
	rm -f "${ED}"/usr/bin/xmllint || die
	rm -f "${ED}"/usr/bin/xml2-config-meson || die

	rm -rf "${ED}"/usr/include || die

	rm -f "${ED}"/usr/$(get_libdir)/libxml2.so* || die
	rm -rf "${ED}"/usr/$(get_libdir)/pkgconfig || die
	rm -rf "${ED}"/usr/$(get_libdir)/cmake || die
}

# vim: filetype=ebuild
