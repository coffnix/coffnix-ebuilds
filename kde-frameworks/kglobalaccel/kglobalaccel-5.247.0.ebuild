# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

QTMIN=6.6.0
inherit ecm frameworks.kde.org

DESCRIPTION="Framework to handle global shortcuts"

LICENSE="LGPL-2+"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=dev-qt/qtbase-${QTMIN}:6[dbus,gui,widgets]"
DEPEND="${RDEPEND}"
BDEPEND=">=dev-qt/qttools-${QTMIN}:6[linguist]"
