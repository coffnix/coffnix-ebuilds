# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qt5-build

DESCRIPTION="State Chart XML (SCXML) support library for the Qt5 framework"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="amd64 ~arm arm64 ~riscv x86"
fi

IUSE=""

DEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtdeclarative-5.15.11*
"
RDEPEND="${DEPEND}"
