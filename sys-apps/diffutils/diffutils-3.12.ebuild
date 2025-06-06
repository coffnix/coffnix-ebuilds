# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

DESCRIPTION="Tools to make diffs and compare files"
HOMEPAGE="https://www.gnu.org/software/diffutils/"
SRC_URI="https://ftp.gnu.org/gnu/diffutils/diffutils-3.12.tar.xz -> diffutils-3.12.tar.xz
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="nls static"

BDEPEND="
	app-arch/xz-utils
	nls? ( sys-devel/gettext )
"

DOCS=( AUTHORS ChangeLog NEWS README THANKS TODO )

src_configure() {
	use static && append-ldflags -static

	# Disable automagic dependency over libsigsegv; see bug #312351.
	export ac_cv_libsigsegv=no

	# required for >=glibc-2.26, bug #653914
	use elibc_glibc && export gl_cv_func_getopt_gnu=yes

	local myeconfargs=(
		--with-packager="Funtoo"
		--with-packager-version="${PVR}"
		--with-packager-bug-reports="https://bugs.funtoo.org/"
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}

src_test() {
	# explicitly allow parallel testing
	emake check
}