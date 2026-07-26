EAPI=7
inherit meson xdg-utils git-r3

DESCRIPTION="The Shared MIME-info Database specification"
HOMEPAGE="https://gitlab.freedesktop.org/xdg/shared-mime-info"

SRC_URI="https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/${PV}/shared-mime-info-${PV}.tar.bz2"

EGIT_REPO_URI="https://gitlab.freedesktop.org/xdg/xdgmime.git"
EGIT_BRANCH="master"
EGIT_CHECKOUT_DIR="${WORKDIR}/xdgmime"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="dev-libs/glib
	dev-libs/libxml2
"

DEPEND="${RDEPEND}
	app-text/xmlto
	dev-util/intltool
	sys-devel/gettext
	app-text/docbook-xml-dtd:4.1.2
	virtual/pkgconfig
"

src_unpack() {
	default

	git-r3_src_unpack
}

src_prepare() {
	default

	rm -f "${S}/subprojects/xdgmime.wrap" || die
	mv "${WORKDIR}/xdgmime" "${S}/subprojects/xdgmime" || die
}

src_configure() {
	local emesonargs=(
		-Dbuild-tools=true
		-Dupdate-mimedb=false
	)

	meson_src_configure
}

pkg_postinst() {
	xdg_mimeinfo_database_update
}
