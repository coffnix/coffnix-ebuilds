# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit desktop eutils pax-utils user xdg

DESCRIPTION="1Password is a password manager developed by AgileBits Inc."
HOMEPAGE="https://releases.1password.com/linux/8.10/"
SRC_URI="https://downloads.1password.com/linux/tar/stable/x86_64/1password-8.10.76.x64.tar.gz -> onepassword-bin-8.10.76.tar.gz"

KEYWORDS="-* amd64"
LICENSE="all-rights-reserved"
SLOT="0"
IUSE=""

RDEPEND="
	app-accessibility/at-spi2-atk:2
	app-arch/brotli
	app-arch/bzip2
	app-crypt/p11-kit
	dev-libs/atk
	dev-libs/expat
	dev-libs/fribidi
	dev-libs/gmp
	dev-libs/libbsd
	dev-libs/libffi
	dev-libs/libtasn1
	dev-libs/libunistring
	dev-libs/glib:2
	dev-libs/nettle
	dev-libs/nspr
	dev-libs/nss
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/libglvnd
	media-libs/harfbuzz
	media-libs/libepoxy
	media-libs/libpng:0
	media-libs/mesa
	net-libs/gnutls
	net-print/cups
	sys-apps/dbus
	sys-libs/zlib
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libXau
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/pango
	x11-libs/pixman
"
QA_PREBUILT="
	/opt/1Password/1password
	/opt/1Password/1Password-BrowserSupport
	/opt/1Password/1Password-KeyringHelper
	/opt/1Password/1Password/chrome-sandbox
	/opt/1Password/1Password/chrome_crashpad_handler
	/opt/1Password/libEGL.so
	/opt/1Password/libGLESv2.so
	/opt/1Password/libffmpeg.so
	/opt/1Password/libvk_swiftshader.so
	/opt/1Password/libvulkan.so.1
	/opt/1Password/swiftshader/libEGL.so
	/opt/1Password/swiftshader/libGLESv2.so
	/opt/1Password/resources/app.asar.unpacked/index.node
"

GROUP_NAME="onepassword"

pkg_setup() {
	enewgroup ${GROUP_NAME}
}

post_src_unpack() {
	if [ ! -d "${S}" ] ; then
		mv "${WORKDIR}"/1password-* "${S}" || die
	fi
}

src_prepare() {
	default
	export POLICY_OWNERS
	POLICY_OWNERS="$(cut -d: -f1,3 /etc/passwd | grep -E ':[0-9]{4}$' | cut -d: -f1 | head -n 10 | sed 's/^/unix-user:/' | tr '\n' ' ')"
  eval "cat <<EOF
$(cat com.1password.1Password.policy.tpl)
EOF" > com.1password.1Password.policy
}

src_install() {
	doicon resources/icons/hicolor/64x64/apps/1password.png
	domenu resources/1password.desktop
	insinto /usr/share/polkit-1/actions
	newins com.1password.1Password.policy com.1password.1Password.policy

	insinto /opt/1Password
	doins -r .

	fperms +x /opt/1Password/1password
	fperms +x /opt/1Password/chrome_crashpad_handler
	fperms 4755 /opt/1Password/chrome-sandbox || die
	fowners root:${GROUP_NAME} /opt/1Password/1Password-BrowserSupport
	fperms 2755 /opt/1Password/1Password-BrowserSupport || die
	dosym ../../opt/1Password/1password /usr/bin/1password
	pax-mark -m "${ED%/}"/opt/1Password/1password
}

pkg_postinst() {
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	xdg_desktop_database_update
}