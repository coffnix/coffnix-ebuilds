# Copyright 2021-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
inherit python-any-r1 qt6-build

DESCRIPTION="Qt Declarative (Quick 2)"

if [[ ${QT6_BUILD_TYPE} == release ]]; then
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~loong ~x86"
fi

IUSE="+network opengl +sql +ssl vulkan +widgets"

# behaves very badly when qtdeclarative is not already installed, also
# other more minor issues (installs junk, sandbox/offscreen issues)
RESTRICT="test"

RDEPEND="~dev-qt/qtbase-${PV}:6[network=,opengl=,sql?,ssl?,vulkan=,widgets=]"
DEPEND="
	${RDEPEND}
	vulkan? ( dev-util/vulkan-headers )
"
BDEPEND="
	${PYTHON_DEPS}
	~dev-qt/qtshadertools-${PV}:6
"

src_configure() {
	local mycmakeargs=(
		$(cmake_use_find_package sql Qt6Sql)
		$(qt_feature network qml_network)
		$(qt_feature ssl qml_ssl)
	)

	qt6-build_src_configure
}
