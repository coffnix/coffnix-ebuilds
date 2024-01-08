# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

QTMIN=6.6.0
inherit ecm frameworks.kde.org

DESCRIPTION="Framework for reading and writing configuration"

LICENSE="LGPL-2+"
KEYWORDS="~amd64"
IUSE="dbus qml"

# bug 560086
RESTRICT="test"

RDEPEND="
	>=dev-qt/qtbase-${QTMIN}:6[dbus?,gui,xml]
	qml? ( >=dev-qt/qtdeclarative-${QTMIN}:6 )
"
DEPEND="${RDEPEND}
	test? ( >=dev-qt/qtbase-${QTMIN}:6[concurrent] )
"
BDEPEND=">=dev-qt/qttools-${QTMIN}:6[linguist]"

DOCS=( DESIGN docs/{DESIGN.kconfig,options.md} )

src_configure() {
	local mycmakeargs=(
		-DKCONFIG_USE_DBUS=$(usex dbus)
		-DKCONFIG_USE_QML=$(usex qml)
	)
	ecm_src_configure
}
