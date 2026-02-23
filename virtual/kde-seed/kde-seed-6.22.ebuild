# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="Meta package for KDE installation"
SLOT="0"
KEYWORDS="*"
IUSE="wayland X declarative gui svg sql libproxy multimedia
gles2-only vulkan libinput cups
"
BDEPEND="kde-frameworks/extra-cmake-modules:*
	
"
RDEPEND="!kde-frameworks/baloo:5
	!kde-frameworks/breeze-icons:5
	!kde-frameworks/extra-cmake-modules:5
	!kde-frameworks/kguiaddons:5
	!kde-frameworks/kirigami:5
	!kde-frameworks/kquickcharts:5
	!kde-frameworks/kuserfeedback:5
	!kde-frameworks/kio-trash-desktop-file:5
	!kde-frameworks/kio:5
	
	!kde-plasma/libplasma:5
	!kde-plasma/libkworkspace:5
	!kde-plasma/kdeplasma-addons:5
	!kde-plasma/kwin:5
	!kde-plasma/plasma-workspace:5
	!kde-plasma/plasma-desktop:5
	!kde-plasma/xdg-desktop-portal-kde:5
	!kde-plasma/print-manager:5
	
	!kde-apps/ffmpegthumbs:5
	!kde-apps/ffmpegthumbs-common
	!kde-apps/kdesdk-thumbnailers:5
	!kde-apps/kio-extras-kf5:5
	!kde-apps/kio-extras:5
	!kde-apps/libkgapi:5
	
	>=dev-qt/qtbase-6.10:6[wayland?,X?,gui?,libproxy?,libinput?,sql?,gles2-only?,vulkan?,cups?]
	declarative? ( dev-qt/qtdeclarative:6 )
	svg? ( dev-qt/qtsvg:6 )
	multimedia? ( dev-qt/qtmultimedia:6 )
	wayland? (
	  dev-libs/wayland
	)
	
"
DEPEND="${RDEPEND}
	dev-util/desktop-file-utils
	
"

# vim: filetype=ebuild
