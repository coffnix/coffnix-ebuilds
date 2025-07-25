# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Note: Please bump this in sync with dev-libs/libxml2.

PYTHON_COMPAT=( python3+ )
inherit flag-o-matic gnome.org libtool python-single-r1

DESCRIPTION="XSLT libraries and tools"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libxslt"

LICENSE="MIT"
SLOT="0"
IUSE="crypt debug examples python static-libs"
PDEPEND="python? ( dev-python/libxslt-python )"
BDEPEND=">=virtual/pkgconfig-1"
RDEPEND="
	~dev-libs/libxml2-2.12.4:2
	crypt? ( >=dev-libs/libgcrypt-1.5.3:0= )
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND} ${PYTHON_DEPS}"
SRC_URI="https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.38.tar.xz -> libxslt-1.1.38.tar.xz"
KEYWORDS="*"

src_prepare() {
	default
	elibtoolize
}

src_configure() {
	# Remove this after upstream merge request to add AC_SYS_LARGEFILE lands:
	# https://gitlab.gnome.org/GNOME/libxslt/-/merge_requests/55
	append-lfs-flags

	ECONF_SOURCE="${S}" econf \
		--with-python \
		$(use_with crypt crypto) \
		$(use_with debug) \
		$(use_with debug mem-debug) \
		$(use_enable static-libs static)
}

src_compile() {
	# This generates files which we need to exist in the python bindings:
	( cd ${S}/python && make all-local ) || die

	# No-op Makefile to disable python build. We just want this ^^
	cat > ${S}/python/Makefile << EOF
all :
install :
.PHONY : all
EOF
	# Peform the build, sans python:
	default
}

src_install() {
	emake DESTDIR="${D}" install
	einstalldocs

	if ! use examples ; then
		rm -rf "${ED}"/usr/share/doc/${PF}/tutorial{,2} || die
		rm -rf "${ED}"/usr/share/doc/${PF}/python/examples || die
	fi

	find "${ED}" -type f -name "*.la" -delete || die

	# Install a pre-configured python source distribution for python bindings.
	# The libxml2-python ebuild will use this to build. These bindings have been
	# specifically configured to "match" this libxml2.

	dodir /usr/share/${PN}/bindings/
	# This generates certain data files which the python build uses to bind to the API:
	( cd ${S}/python && ./generator.py ) || die
	tar czvf ${D}/usr/share/${PN}/bindings/${PN}-python-${PV}.tar.gz -C ${S} python || die
}
