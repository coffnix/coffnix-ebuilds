# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3+ )

inherit distutils-r1

DESCRIPTION="Brain-dead simple config-ini parsing"
HOMEPAGE="
	https://github.com/pytest-dev/iniconfig/
	https://pypi.org/project/iniconfig/
"
SRC_URI="
	https://github.com/pytest-dev/iniconfig/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

BDEPEND="
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
