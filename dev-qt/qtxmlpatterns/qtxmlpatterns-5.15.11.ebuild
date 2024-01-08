# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qt5-build

DESCRIPTION="XPath, XQuery, XSLT, and XML Schema validation library for the Qt5 framework"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="amd64 arm arm64 ~hppa ~loong ppc ppc64 ~riscv ~sparc x86"
fi

IUSE="qml"

DEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtnetwork-5.15.11*
	qml? ( =dev-qt/qtdeclarative-5.15.11* )
"
RDEPEND="${DEPEND}
	!<dev-qt/qtchooser-66-r2
"

src_prepare() {
	qt_use_disable_mod qml qml \
		src/src.pro \
		src/imports/imports.pro

	qt_use_disable_mod qml quick tests/auto/auto.pro

	qt5-build_src_prepare
}

src_install() {
	qt5-build_src_install
	qt5_symlink_binary_to_path xmlpatterns
	qt5_symlink_binary_to_path xmlpatternsvalidator
}
