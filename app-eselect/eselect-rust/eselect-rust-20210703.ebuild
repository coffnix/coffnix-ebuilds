# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools

DESCRIPTION="Eselect module for management of multiple Rust versions"
HOMEPAGE="https://gitweb.gentoo.org/proj/eselect-rust.git"
SRC_URI="https://gitweb.gentoo.org/proj/eselect-rust.git/snapshot/eselect-rust-20210703.tar.gz -> eselect-rust-20210703.tar.gz"
LICENSE="GPL-2"

KEYWORDS="*"
SLOT="0"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.3"

src_prepare() {
	default
	eautoreconf
}


pkg_postinst() {
	if has_version 'dev-lang/rust' || has_version 'dev-lang/rust-bin'; then
		eselect rust update --if-unset
	fi
}