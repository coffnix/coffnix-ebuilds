# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qtbase"
inherit qt5-build

DESCRIPTION="SQL abstraction library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtbase-everywhere-opensource-src-5.15.16.tar.xz -> qtbase-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="freetds mysql oci8 odbc postgres +sqlite"
REQUIRED_USE="|| ( freetds mysql oci8 odbc postgres sqlite )
"
RDEPEND="dev-qt/qtcore:5
	freetds? ( dev-db/freetds )
	mysql? ( dev-db/mysql-connector-c:= )
	oci8? ( dev-db/oracle-instantclient:=[sdk] )
	odbc? ( dev-db/unixODBC )
	postgres? ( dev-db/postgresql:* )
	sqlite? ( dev-db/sqlite:3 )
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qtbase-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/sql
	src/plugins/sqldrivers
)
QT5_GENTOO_PRIVATE_CONFIG=(
	:sql
)
src_configure() {
	local myconf=(
	  $(qt_use freetds  sql-tds    plugin)
	  $(qt_use mysql    sql-mysql  plugin)
	  $(qt_use oci8     sql-oci    plugin)
	  $(qt_use odbc     sql-odbc   plugin)
	  $(qt_use postgres sql-psql   plugin)
	  $(qt_use sqlite   sql-sqlite plugin)
	  $(usex sqlite -system-sqlite '')
	)
	use oci8 && myconf+=("-I${ORACLE_HOME}/include" "-L${ORACLE_HOME}/$(get_libdir)")
	qt5-build_src_configure
}


# vim: filetype=ebuild
