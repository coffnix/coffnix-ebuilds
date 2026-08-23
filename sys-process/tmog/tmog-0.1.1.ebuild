# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="TMOG Task Manager by Dave Plummer"
HOMEPAGE="https://www.tmog.org/"
SRC_URI="https://www.tmog.org/downloads/TMOG-Task-Manager-Linux-x86_64.tar.gz?v=${PV}-free -> ${P}.tar.gz"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* amd64"

RESTRICT="strip"

QA_PREBUILT="usr/bin/tmog-task-manager"

REQUIRES_EXCLUDE="libsystemd.so.0"

RDEPEND="
	app-arch/libarchive[zstd]
	dev-qt/qtbase:6[zstd]
	media-libs/mesa[wayland]
	sys-libs/elogind-libsystemd
"

S="${WORKDIR}/TaskManagerOG-${PV}-linux-x86_64"

src_install() {
	dobin bin/tmog-task-manager

	insinto /usr/share/applications
	doins share/applications/com.tmog.taskmanager.desktop

	insinto /usr/share/metainfo
	doins share/metainfo/com.tmog.taskmanager.metainfo.xml

	insinto /usr/share/icons
	doins -r share/icons/hicolor

	insinto /usr/share/pixmaps
	doins share/pixmaps/tmog-task-manager.png

	dodoc share/doc/tmog/*
	dodoc share/doc/taskmanagerog/*
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}
