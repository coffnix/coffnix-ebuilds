# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="Standard GNU utilities (chmod, cp, dd, ls, sort, tr, head, wc, who,...)"
HOMEPAGE="https://www.gnu.org/software/coreutils/"
SRC_URI="https://ftp.gnu.org/gnu/coreutils/coreutils-9.7.tar.xz -> coreutils-9.7.tar.xz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="acl caps gmp hostname kill multicall nls selinux +split-usr static test vanilla xattr lto"
RESTRICT="!test? ( test )"

LIB_DEPEND="acl? ( sys-apps/acl[static-libs] )
	caps? ( sys-libs/libcap )
	gmp? ( dev-libs/gmp:=[static-libs] )
	xattr? ( sys-apps/attr[static-libs] )"
RDEPEND="!static? ( ${LIB_DEPEND//\[static-libs]} )
	selinux? ( sys-libs/libselinux )
	nls? ( virtual/libintl )"
DEPEND="
	${RDEPEND}
	static? ( ${LIB_DEPEND} )
"
BDEPEND="
	app-arch/xz-utils
	dev-lang/perl
	test? (
		dev-lang/perl
		dev-perl/Expect
		dev-util/strace
		${PYTHON_DEPS}
	)
"
RDEPEND+="
	hostname? ( !sys-apps/net-tools[hostname] )
	kill? (
		!sys-apps/util-linux[kill]
		!sys-process/procps[kill]
	)
	!app-misc/realpath
	!<sys-apps/util-linux-2.13
	!<sys-apps/sandbox-2.10-r4
	!sys-apps/stat
	!net-mail/base64
	!sys-apps/mktemp
	!<app-forensics/tct-1.18-r1
	!<net-fs/netatalk-2.0.3-r4"

pkg_setup() {
	if use test ; then
		python-any-r1_pkg_setup
	fi
}

src_prepare() {
	default

	# Since we've patched many .c files, the make process will try to
	# re-build the manpages by running `./bin --help`.  When doing a
	# cross-compile, we can't do that since 'bin' isn't a native bin.
	#
	# Also, it's not like we changed the usage on any of these things,
	# so let's just update the timestamps and skip the help2man step.
	set -- man/*.x
	touch ${@/%x/1} || die

	# Avoid perl dep for compiled in dircolors default (bug #348642)
	if ! has_version dev-lang/perl ; then
		touch src/dircolors.h || die
		touch ${@/%x/1} || die
	fi
}

src_configure() {
	if ! use lto; then
		einfo "Disabling LTO due to build issues"
		export CFLAGS="${CFLAGS} -fno-lto"
		export CXXFLAGS="${CXXFLAGS} -fno-lto"
		export LDFLAGS="${LDFLAGS} -fno-lto"
	fi
	local myconf=(
		--with-packager="Funtoo"
		--with-packager-version="${PVR}"
		--with-packager-bug-reports="https://bugs.funtoo.org/"
		# kill/uptime - procps
		# groups/su   - shadow
		# hostname    - net-tools
		--enable-install-program="arch,$(usev hostname),$(usev kill)"
		--enable-no-install-program="groups,$(usev !hostname),$(usev !kill),su,uptime"
		--enable-largefile
		$(usex caps '' --disable-libcap)
		$(use_enable nls)
		$(use_enable acl)
		$(use_enable multicall single-binary)
		$(use_enable xattr)
		$(use_with gmp libgmp)
	)

	if use gmp ; then
		myconf+=( --with-libgmp-prefix="${ESYSROOT}"/usr )
	fi

	if tc-is-cross-compiler && [[ ${CHOST} == *linux* ]] ; then
		# bug #311569
		export fu_cv_sys_stat_statfs2_bsize=yes
		# bug #416629
		export gl_cv_func_realpath_works=yes
	fi

	# bug #409919
	export gl_cv_func_mknod_works=yes

	if use static ; then
		append-ldflags -static
		# bug #321821
		sed -i '/elf_sys=yes/s:yes:no:' configure || die
	fi

	if ! use selinux ; then
		# bug #301782
		export ac_cv_{header_selinux_{context,flash,selinux}_h,search_setfilecon}=no
	fi

	econf "${myconf[@]}"
}

src_test() {
	# Known to fail with FEATURES=usersandbox (bug #439574):
	#   -  tests/du/long-from-unreadable.sh} (bug #413621)
	#   -  tests/rm/deep-2.sh (bug #413621)
	#   -  tests/dd/no-allocate.sh (bug #629660)
	if has usersandbox ${FEATURES} ; then
		ewarn "You are emerging ${P} with 'usersandbox' enabled." \
			"Expect some test failures or emerge with 'FEATURES=-usersandbox'!"
	fi

	# Non-root tests will fail if the full path isn't
	# accessible to non-root users
	chmod -R go-w "${WORKDIR}" || die
	chmod a+rx "${WORKDIR}" || die

	# coreutils tests like to do `mount` and such with temp dirs,
	# so make sure:
	# - /etc/mtab is writable (bug #265725)
	# - /dev/loop* can be mounted (bug #269758)
	mkdir -p "${T}"/mount-wrappers || die
	mkwrap() {
		local w ww
		for w in "${@}" ; do
			ww="${T}/mount-wrappers/${w}"
			cat <<-EOF > "${ww}"
				#!${EPREFIX}/bin/sh
				exec env SANDBOX_WRITE="\${SANDBOX_WRITE}:/etc/mtab:/dev/loop" $(type -P ${w}) "\$@"
			EOF
			chmod a+rx "${ww}" || die
		done
	}
	mkwrap mount umount

	addwrite /dev/full
	#export RUN_EXPENSIVE_TESTS="yes"
	#export FETISH_GROUPS="portage wheel"
	env PATH="${T}/mount-wrappers:${PATH}" \
	emake -j1 -k check
}

src_install() {
	default

	insinto /etc
	newins src/dircolors.hin DIR_COLORS

	if use split-usr ; then
		cd "${ED}"/usr/bin || die
		dodir /bin

		# Move critical binaries into /bin (required by FHS)
		local fhs="cat chgrp chmod chown cp date dd df echo false ln ls
		           mkdir mknod mv pwd rm rmdir stty sync true uname"
		mv ${fhs} ../../bin/ || die "Could not move FHS bins!"

		if use hostname ; then
			mv hostname ../../bin/ || die
		fi

		if use kill ; then
			mv kill ../../bin/ || die
		fi

		# Move critical binaries into /bin (common scripts)
		# (Why are these required for booting?)
		local com="basename chroot cut dir dirname du env expr head mkfifo
		           mktemp readlink seq sleep sort tail touch tr tty vdir wc yes"
		mv ${com} ../../bin/ || die "Could not move common bins!"

		# Create a symlink for uname in /usr/bin/ since autotools require it.
		# (Other than uname, we need to figure out why we are
		# creating symlinks for these in /usr/bin instead of leaving
		# the files there in the first place...)
		local x
		for x in ${com} uname ; do
			dosym ../../bin/${x} /usr/bin/${x}
		done
	fi
}

pkg_postinst() {
	ewarn "Make sure you run 'hash -r' in your active shells."
	ewarn "You should also re-source your shell settings for LS_COLORS"
	ewarn "  changes, such as: source /etc/profile"
}
