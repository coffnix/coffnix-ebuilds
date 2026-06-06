# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="Virtual for Rust language compiler"
HOMEPAGE="https://www.rust-lang.org"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
RDEPEND="|| (
	  ~dev-lang/rust-bin-1.94.1
	  ~dev-lang/rust-1.94.1
	)
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild
