# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

LIBTOOLIZE="true" #225559
WANT_LIBTOOL="none"
inherit autotools epatch epunt-cxx multilib unpacker prefix

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://git.savannah.gnu.org/${PN}.git
		http://git.savannah.gnu.org/r/${PN}.git"
	inherit git-r3
else
	SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
fi

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="https://www.gnu.org/software/libtool/"

LICENSE="GPL-2"
SLOT="2"
IUSE="vanilla"

# Pull in libltdl directly until we convert packages to the new dep.
RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.69
	>=sys-devel/automake-1.13
	dev-libs/libltdl:0
	!<sys-apps/sandbox-2.10-r4"
DEPEND="${RDEPEND}
	app-arch/xz-utils"
[[ ${PV} == "9999" ]] && DEPEND+=" sys-apps/help2man"

PATCHES=(
    # bug #109105
    "${FILESDIR}"/${PN}-2.4.3-use-linux-version-in-fbsd.patch
    # bug #581314
    "${FILESDIR}"/${PN}-2.4.6-ppc64le.patch

    "${FILESDIR}"/${PN}-2.2.6a-darwin-module-bundle.patch
    "${FILESDIR}"/${PN}-2.4.6-darwin-use-linux-version.patch
)

#PATCHES=(
#	"${FILESDIR}"/${PN}-2.4.3-use-linux-version-in-fbsd.patch #109105
#	"${FILESDIR}"/${P}-link-specs.patch
#	"${FILESDIR}"/${P}-link-fsanitize.patch #573744
#	"${FILESDIR}"/${P}-link-fuse-ld.patch
#	"${FILESDIR}"/${P}-libtoolize-slow.patch
#	"${FILESDIR}"/${P}-libtoolize-delay-help.patch
#	"${FILESDIR}"/${P}-sed-quote-speedup.patch #542252
#	"${FILESDIR}"/${P}-ppc64le.patch #581314
#
#	"${FILESDIR}"/${PN}-2.4.6-mint.patch
#	"${FILESDIR}"/${PN}-2.2.6a-darwin-module-bundle.patch
#	"${FILESDIR}"/${PN}-2.4.6-darwin-use-linux-version.patch
#)

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git-r3_src_unpack
	else
		unpacker_src_unpack
	fi
}

src_prepare() {
#	if [[ "${PV}" = 9999 ]] ; then
#		eapply "${FILESDIR}"/${P}-pthread.patch #650876
#		./bootstrap || die
#	else
#		#PATCHES+=(
#		#	"${FILESDIR}"/${P}-pthread_bootstrapped.patch #650876
#		#)
#	fi

	if use vanilla ; then
		eapply_user
		return 0
	else
		default
	fi

	if use prefix ; then
		# seems that libtool has to know about EPREFIX a little bit
		# better, since it fails to find prefix paths to search libs
		# from, resulting in some packages building static only, since
		# libtool is fooled into thinking that libraries are unavailable
		# (argh...). This could also be fixed by making the gcc wrapper
		# return the correct result for -print-search-dirs (doesn't
		# include prefix dirs ...).
		eapply "${FILESDIR}"/${PN}-2.2.10-eprefix.patch
		eprefixify m4/libtool.m4
	fi

	pushd libltdl >/dev/null
	AT_NOELIBTOOLIZE=yes eautoreconf
	popd >/dev/null
	AT_NOELIBTOOLIZE=yes eautoreconf
	epunt_cxx

	# Make sure timestamps don't trigger a rebuild of man pages. #556512
	if [[ ${PV} != "9999" ]] ; then
		touch doc/*.1
		export HELP2MAN=false
	fi
}

src_configure() {
	# the libtool script uses bash code in it and at configure time, tries
	# to find a bash shell.  if /bin/sh is bash, it uses that.  this can
	# cause problems for people who switch /bin/sh on the fly to other
	# shells, so just force libtool to use /bin/bash all the time.
	export CONFIG_SHELL="$(type -P bash)"

	# Do not bother hardcoding the full path to sed.  Just rely on $PATH. #574550
	export ac_cv_path_SED="$(basename "$(type -P sed)")"

	local myconf
	[[ ${CHOST} == *-darwin* ]] && myconf="--program-prefix=g"
	ECONF_SOURCE=${S} econf ${myconf} --disable-ltdl-install
}

src_test() {
	emake check
}

src_install() {
	default

	local x
	while read -d $'\0' -r x ; do
		ln -sf "${EPREFIX}"/usr/share/gnuconfig/${x##*/} "${x}" || die
	done < <(find "${ED}" '(' -name config.guess -o -name config.sub ')' -print0)
}
