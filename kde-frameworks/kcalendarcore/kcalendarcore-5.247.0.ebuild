# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

ECM_TEST="true"
QTMIN=6.6.0
inherit ecm frameworks.kde.org

DESCRIPTION="Library for interfacing with calendars"

LICENSE="GPL-2+ test? ( LGPL-3+ )"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="test" # multiple tests fail or hang indefinitely

DEPEND="
	>=dev-libs/libical-3.0.5:=
	>=dev-qt/qtbase-${QTMIN}:6[gui]
"
RDEPEND="${DEPEND}"
BDEPEND="sys-devel/bison"
