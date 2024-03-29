# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VIRTUALX_REQUIRED="test"
inherit qt5-build

DESCRIPTION="Set of QML types for adding visual effects to user interfaces"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="amd64 ~arm arm64 ~hppa ~loong ppc ppc64 ~riscv x86"
fi

IUSE=""

RDEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtdeclarative-5.15.11*
	=dev-qt/qtgui-5.15.11*
"
DEPEND="${RDEPEND}"
