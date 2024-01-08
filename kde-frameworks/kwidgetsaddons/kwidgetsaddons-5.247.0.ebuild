# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

ECM_DESIGNERPLUGIN="true"
QTMIN=6.6.0
inherit ecm frameworks.kde.org

DESCRIPTION="An assortment of high-level widgets for common tasks"

LICENSE="LGPL-2.1+"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-qt/qtbase-${QTMIN}:6[gui,widgets]"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-qt/qttools-${QTMIN}:6[linguist]"

CMAKE_SKIP_TESTS=(
	# bug 650216
	kdatecomboboxtest
	# bug 697866
	ksqueezedtextlabelautotest
	# bug 808216
	ktwofingertaptest
	ktwofingerswipetest
)
