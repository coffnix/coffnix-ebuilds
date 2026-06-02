# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit distutils-r1 meson

DESCRIPTION="Python binding of XML C parser and toolkit"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libxml2/-/wikis/home"
SRC_URI="https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.2.tar.xz -> libxml2-2.15.2.tar.xz"
SLOT="2"
KEYWORDS="*"
IUSE="+icu +lzma readline static-libs"
RDEPEND="=dev-libs/libxml2-2.15.2:=[lzma?,icu?,readline?,static-libs?]
	!<dev-python/libxml2-python-2.15.0
"
DEPEND="${RDEPEND}
	app-doc/doxygen
	!<dev-python/libxml2-python-2.15.0
"
S="${WORKDIR}/libxml2-2.15.2"
src_prepare() {
	default
	sed -i "/subdir('doc')/d" meson.build || die
	sed -e "/^dir_doc/ s/meson.project_name()$/\'${PF}\'/" -i meson.build || die
	# Permit to compile libxml2 on stage3 without git installed.
	# Hack git command with echo in order to print an empty string.
	sed -e 's|git|echo|g' -e 's|describe||g' -i meson.build || die
}
src_configure() {
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
	export S="${S}/python"
	distutils-r1_src_configure
}
src_compile() {
	meson_src_compile
}
src_install() {
	meson_src_install
	# Remove files supplied by libxml2 library
	rm -r "${ED}"/usr/{$(get_libdir),bin,include} || die
}


# vim: filetype=ebuild
