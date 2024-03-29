# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qmake-utils

MY_P=qt-solutions-${PV#*_p}

# package valid as of 2020Apr04
# cannonical source taken from Qt-Solutions github mirror
# "borrowing" from Fedora spec file for pkg - grab archive @ commit hash value
COMMIT_HASH="a8dda66d7738cde9042b87db27993f710ae3eeeb"
DESCRIPTION="Qt library to start applications only once per user"
HOMEPAGE="https://code.qt.io/cgit/qt-solutions/qt-solutions.git/"
SRC_URI="https://github.com/qtproject/qt-solutions/archive/${COMMIT_HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 GPL-3 )"
SLOT="0"
KEYWORDS="*"
IUSE="doc X"

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtlockedfile[qt5(+)]
	dev-qt/qtnetwork:5
	X? (
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-unbundle-qtlockedfile.patch"
	"${FILESDIR}/${P}-qupzilla.patch"
	"${FILESDIR}/${P}-no-gui.patch"

)

src_unpack() {
	unpack "${A}"
	mv "qt-solutions-${COMMIT_HASH}/${PN}" "${P}" || die
	rm -fR "qt-solutions-${COMMIT_HASH}"
}

src_prepare() {
	default
	echo 'SOLUTIONS_LIBRARY = yes' > config.pri
	use X || echo 'QTSA_NO_GUI = yes' >> config.pri

	sed -i -e "s/-head/-${PV%.*}/" common.pri || die
	sed -i -e '/SUBDIRS+=examples/d' ${PN}.pro || die
	# to ensure unbundling
	rm src/qtlockedfile* || die
}

src_configure() {
	eqmake5
}

src_install() {
	use doc && local HTML_DOCS=( doc/html/. )
	einstalldocs

	# libraries
	dolib.so lib/*

	# headers
	insinto "$(qt5_get_headerdir)"/QtSolutions
	doins src/qtsinglecoreapplication.h
	use X && doins src/{QtSingleApplication,${PN}.h}

	# .prf files
	insinto "$(qt5_get_mkspecsdir)"/features
	doins "${FILESDIR}"/qtsinglecoreapplication.prf
	use X && doins "${FILESDIR}"/${PN}.prf
}
