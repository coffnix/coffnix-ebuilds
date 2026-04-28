# Distributed under the terms of the GNU General Public License v2

EAPI=7
QA_PREBUILT="usr/lib/${PN}/Telegram"
inherit desktop eutils xdg

DESCRIPTION="Official desktop client for Telegram (binary package)"
HOMEPAGE="https://desktop.telegram.org"
SRC_URI="
amd64? ( https://github.com/telegramdesktop/tdesktop/releases/download/v6.7.6/tdesktop-6.7.6-full.tar.gz -> telegram-desktop-tdesktop-6.7.6.tar.gz )
amd64? ( https://github.com/telegramdesktop/tdesktop/releases/download/v6.7.6/tsetup.6.7.6.tar.xz -> telegram-desktop-tsetup-6.7.6.tar.xz )"
LICENSE="GPL-3-with-openssl-exception"
SLOT="0"
KEYWORDS="*"
IUSE="amd64"
RDEPEND="dev-libs/glib
	dev-libs/gobject-introspection
	media-libs/fontconfig
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libxcb[xkb]

"
S="${WORKDIR}/Telegram"
src_install() {
	local SOURCE_DIR="${WORKDIR}/tdesktop-${PV}-full"
	exeinto /usr/lib/${PN}
	doexe "Telegram"
	newbin "${FILESDIR}"/${PN} "telegram-desktop"
	dosym telegram-desktop /usr/bin/Telegram
	local icon_size
	for icon_size in 16 32 128 256 512; do
		newicon -s "${icon_size}" \
			"${SOURCE_DIR}/Telegram/Telegram/Images.xcassets/Icon.iconset/icon_${icon_size}x${icon_size}.png" \
			telegram.png
		dosym telegram.png /usr/share/icons/hicolor/${icon_size}x${icon_size}/apps/org.telegram.desktop.png
	done
	sed -i \
		-e '/SingleMainWindow=true/d' \
		-e '/DBusActivatable=true/d' \
		"${SOURCE_DIR}"/lib/xdg/org.telegram.desktop.desktop
	domenu "${SOURCE_DIR}"/lib/xdg/org.telegram.desktop.desktop
}
pkg_postinst() {
	xdg_pkg_postinst
}
