# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

QTMIN=6.6.0
inherit ecm frameworks.kde.org

DESCRIPTION="Framework providing access to Open Collaboration Services"

LICENSE="LGPL-2.1+"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=dev-qt/qtbase-${QTMIN}:6[network]"
DEPEND="${RDEPEND}"

CMAKE_SKIP_TESTS=(
	# requires network access, bug #661230
	providertest
)
