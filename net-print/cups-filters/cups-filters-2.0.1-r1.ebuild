# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic

DESCRIPTION="OpenPrinting CUPS filters"
HOMEPAGE="https://github.com/OpenPrinting/cups-filters"
SRC_URI="https://github.com/OpenPrinting/cups-filters/releases/download/2.0.1/cups-filters-2.0.1.tar.xz -> cups-filters-2.0.1.tar.xz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="+foomatic"
RDEPEND=">=net-print/cups-1.7.3
	
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.18.3
	virtual/pkgconfig
	
"
src_configure() {
	local myeconfargs=(
	  --enable-driverless
	  --enable-ghostscript
	  --enable-imagefilters
	  --enable-nls
	  --enable-poppler
	  --enable-universal-cups-filter
	  --disable-individual-cups-filters
	  --disable-mutool
	  --disable-pstops
	  --disable-rastertopwg
	  --disable-static
	  --disable-werror
	  --localstatedir="${EPREFIX}"/var
	  $(use_enable foomatic)
	)
	 econf "${myeconfargs[@]}"
}


# vim: filetype=ebuild
