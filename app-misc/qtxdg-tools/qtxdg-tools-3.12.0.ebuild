# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="User Tools from libqtxdg"
HOMEPAGE="https://lxqt-project.org/"

LICENSE="LGPL-2.1"
SLOT="0"

BDEPEND=">=dev-util/lxqt-build-tools-0.13.0"
RDEPEND="
	>=dev-libs/libqtxdg-3.12.0
	>=dev-qt/qtcore-5.15:5
"
DEPEND="${RDEPEND}"
