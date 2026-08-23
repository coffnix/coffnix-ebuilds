# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Provide standalone libsystemd.so without systemd by linking libelogind.so"
HOMEPAGE="http://systemd.io https://github.com/elogind/elogind"

LICENSE="CC0-1.0 GPL-2 LGPL-2.1 MIT public-domain"
SLOT="0/2"
KEYWORDS="*"

RDEPEND="!sys-apps/systemd
	>=sys-auth/elogind-255.5-r1
	!sys-libs/libsystemd
"

S="${WORKDIR}"

src_install() {
	dosym libelogind.so.0 /usr/$(get_libdir)/libsystemd.so.0
	dosym libsystemd.so.0 /usr/$(get_libdir)/libsystemd.so
}
