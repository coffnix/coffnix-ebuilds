# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qtbase"
inherit qt5-build

DESCRIPTION="Network abstraction library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtbase-everywhere-opensource-src-5.15.17.tar.xz -> qtbase-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="connman gssapi libproxy networkmanager sctp +ssl"
# Commons depends
CDEPEND="dev-qt/qtcore:5 sys-libs/zlib connman? ( dev-qt/qtdbus:5 ) gssapi? ( virtual/krb5 ) libproxy? ( net-libs/libproxy ) networkmanager? ( dev-qt/qtdbus:5 ) sctp? ( kernel_linux? ( net-misc/lksctp-tools ) ) ssl? ( dev-libs/openssl )
"
RDEPEND="${CDEPEND}
	connman? ( net-misc/connman )
	networkmanager? ( net-misc/networkmanager )
	
"
DEPEND="${CDEPEND}
"
S="${WORKDIR}/qtbase-everywhere-src-5.15.17"
QT5_TARGET_SUBDIRS=(
	src/network
	src/plugins/bearer/generic
)
QT5_GENTOO_CONFIG=(
	libproxy:libproxy:
	ssl::SSL
	ssl::OPENSSL
	ssl:openssl-linked:LINKED_OPENSSL
)
QT5_GENTOO_PRIVATE_CONFIG=(
	:network
)
pkg_setup() {
	use connman && QT5_TARGET_SUBDIRS+=(src/plugins/bearer/connman)
	use networkmanager && QT5_TARGET_SUBDIRS+=(src/plugins/bearer/networkmanager)
}
src_configure() {
	local myconf=(
	  $(usex connman -dbus-linked '')
	  $(qt_use gssapi feature-gssapi)
	  $(qt_use libproxy)
	  $(usex networkmanager -dbus-linked '')
	  $(qt_use sctp)
	  $(usex ssl -openssl-linked '')
	)
	qt5-build_src_configure
}
src_install() {
	qt5-build_src_install
	# workaround for bug 652650
	if use ssl; then
	  sed -e "/^#define QT_LINKED_OPENSSL/s/$/ true/" \
	    -i "${D}${QT5_HEADERDIR}"/Gentoo/${PN}-qconfig.h || die
	fi
}


# vim: filetype=ebuild
