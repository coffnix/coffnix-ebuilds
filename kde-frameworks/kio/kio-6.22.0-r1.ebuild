# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake xdg

DESCRIPTION="Framework providing transparent file and data management"
HOMEPAGE="https://invent.kde.org/frameworks/"
SRC_URI="https://download.kde.org/stable/frameworks/6.22/kio-6.22.0.tar.xz -> kio-6.22.0.tar.xz"
LICENSE="GPL-2"
SLOT="6"
KEYWORDS="*"
IUSE="acl handbook +kwallet wayland X"
RDEPEND="virtual/kde-seed[declarative,gui,libproxy,wayland?,X?]
	sys-power/switcheroo-control
	kde-frameworks/kauth:6
	kde-frameworks/kbookmarks:6
	kde-frameworks/kcodecs:6
	kde-frameworks/kcolorscheme:6
	kde-frameworks/kcompletion:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kcrash:6
	kde-frameworks/kdbusaddons:6
	kde-frameworks/kguiaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kiconthemes:6
	kde-frameworks/kitemviews:6
	kde-frameworks/kjobwidgets:6
	kde-frameworks/knotifications:6
	kde-frameworks/kservice:6
	kde-frameworks/ktextwidgets:6
	kde-frameworks/kwidgetsaddons:6
	kde-frameworks/kwindowsystem:6[wayland?,X?]
	kde-frameworks/solid:6
	acl? (
	    sys-apps/attr
	    virtual/acl
	)
	handbook? (
	    dev-libs/libxml2:=
	    dev-libs/libxslt
	    kde-frameworks/karchive:6
	    kde-frameworks/kdoctools:6
	)
	kwallet? ( kde-frameworks/kwallet:6 )
	
"
DEPEND="${RDEPEND}
"
PDEPEND="kde-frameworks/kded:6"

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
	  $(cmake_use_find_package acl ACL)
	  $(cmake_use_find_package kwallet KF6Wallet)
	  -DWITH_WAYLAND=$(usex wayland)
	  -DWITH_X11=$(usex X)
	)
	cmake_src_configure
}


# vim: filetype=ebuild
