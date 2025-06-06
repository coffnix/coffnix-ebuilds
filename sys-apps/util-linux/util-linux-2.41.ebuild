# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit autotools toolchain-funcs libtool flag-o-matic bash-completion-r1 usr-ldscript \
	pam python-r1 multiprocessing

DESCRIPTION="Various useful Linux utilities"
HOMEPAGE="https://www.kernel.org/pub/linux/utils/util-linux/"
SRC_URI="https://github.com/util-linux/util-linux/tarball/caa26876bc75041833c9644491cc2670d623f750 -> util-linux-2.41-caa2687.tar.gz"
LICENSE="GPL-2 GPL-3 LGPL-2.1 BSD-4 MIT public-domain"

S="${WORKDIR}/util-linux-util-linux-caa2687"

SLOT="0"
KEYWORDS="*"
IUSE="audit build +caps +cramfs cryptsetup fdformat hardlink kill +logger magic ncurses nls pam python +readline rtas selinux slang static-libs su +suid tty-helpers udev unicode"

RDEPEND="
	virtual/libc:=
	audit? ( >=sys-process/audit-2.6:= )
	caps? ( sys-libs/libcap-ng )
	cramfs? ( sys-libs/zlib:= )
	cryptsetup? ( sys-fs/cryptsetup )
	hardlink? ( dev-libs/libpcre2:= )
	ncurses? (
		sys-libs/ncurses:=
		magic? ( sys-apps/file:0= )
	)
	nls? ( virtual/libintl )
	pam? ( sys-libs/pam )
	python? ( ${PYTHON_DEPS} )
	readline? ( sys-libs/readline:0= )
	rtas? ( sys-libs/librtas )
	selinux? ( >=sys-libs/libselinux-2.2.2-r4 )
	slang? ( sys-libs/slang )
	udev? ( virtual/libudev:= )"
BDEPEND="
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"
DEPEND="
	${RDEPEND}
	virtual/os-headers
"
RDEPEND+="
	hardlink? ( !app-arch/hardlink )
	logger? ( !>=app-admin/sysklogd-2.0[logger] )
	kill? (
		!sys-apps/coreutils[kill]
		!sys-process/procps[kill]
	)
	su? (
		!<sys-apps/shadow-4.7-r2
		!>=sys-apps/shadow-4.7-r2[su]
	)
	!net-wireless/rfkill
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} ) su? ( pam )"
RESTRICT="test"

pkg_pretend() {
	if use su && ! use suid ; then
		elog "su will be installed as suid despite USE=-suid (bug #832092)"
		elog "To use su without suid, see e.g. Portage's suidctl feature."
	fi
}

src_prepare() {
	default
	./autogen.sh || die
	eautoreconf
}

python_configure() {
	local myeconfargs=(
		"${commonargs[@]}"
		--disable-all-programs
		--disable-bash-completion
		--without-systemdsystemunitdir
		--with-python
		--enable-libblkid
		--enable-libmount
		--enable-pylibmount
	)
	mkdir "${BUILD_DIR}" || die
	pushd "${BUILD_DIR}" >/dev/null || die
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
	popd >/dev/null || die
}

src_configure() {
	export ac_cv_header_security_pam_misc_h=$(usex pam) #485486
	export ac_cv_header_security_pam_appl_h=$(usex pam) #545042

	# Undo bad ncurses handling by upstream. Fall back to pkg-config. #601530
	export NCURSES6_CONFIG=false NCURSES5_CONFIG=false
	export NCURSESW6_CONFIG=false NCURSESW5_CONFIG=false

	# Avoid automagic dependency on ppc*
	export ac_cv_lib_rtas_rtas_get_sysparm=$(usex rtas)

	# configure args shared by python and non-python builds
	local commonargs=(
		--enable-fs-paths-extra="${EPREFIX}/usr/sbin:${EPREFIX}/bin:${EPREFIX}/usr/bin"
	)

	use python && python_foreach_impl python_configure

	local myeconfargs=(
		"${commonargs[@]}"
		--disable-liblastlog2
		--with-bashcompletiondir="$(get_bashcompdir)"
		--without-python
		$(use_enable suid makeinstall-chown)
		$(use_enable suid makeinstall-setuid)
		$(use_with readline)
		$(use_with slang)
		--without-systemd
		$(use_with udev)
		$(usex ncurses "$(use_with magic libmagic)" '--without-libmagic')
		$(usex ncurses "$(use_with unicode ncursesw)" '--without-ncursesw')
		$(usex ncurses "$(use_with !unicode ncurses)" '--without-ncurses')
		$(use_with audit)
		$(tc-has-tls || echo --disable-tls)
		--disable-asciidoc
		$(use_enable nls)
		$(use_enable unicode widechar)
		$(use_enable static-libs static)
		$(use_with ncurses tinfo)
		$(use_with selinux)
			--disable-chfn-chsh
			--disable-login
			--disable-newgrp
			--disable-nologin
			--disable-pylibmount
			--disable-raw
			--disable-vipw
			--enable-agetty
			--enable-bash-completion
			--enable-line
			--enable-partx
			--enable-rename
			--enable-rfkill
			--enable-schedutils
			--without-systemdsystemunitdir
			$(use_enable caps setpriv)
			$(use_enable cramfs)
			$(use_enable fdformat)
			$(use_enable hardlink)
			$(use_enable kill)
			$(use_enable logger)
			$(use_enable ncurses pg)
			$(use_enable su)
			$(use_enable tty-helpers mesg)
			$(use_enable tty-helpers wall)
			$(use_enable tty-helpers write)
			$(use_with cryptsetup)
		)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"

}

python_compile() {
	pushd "${BUILD_DIR}" >/dev/null || die
	emake all
	popd >/dev/null || die
}

src_compile() {
	use python && python_foreach_impl python_compile
	emake all
}

python_install() {
	pushd "${BUILD_DIR}" >/dev/null || die
	emake DESTDIR="${D}" install
	python_optimize
	popd >/dev/null || die
}

src_install() {
	use python && python_foreach_impl python_install

	# This needs to be called AFTER python_install call (#689190)
	emake DESTDIR="${D}" install

	# need the libs in /
	gen_usr_ldscript -a blkid fdisk mount smartcols uuid

	dodoc AUTHORS NEWS README* Documentation/{TODO,*.txt,releases/*}

	# e2fsprogs-libs didnt install .la files, and .pc work fine
	find "${ED}" -name "*.la" -delete || die

	if use pam ; then
		# See https://github.com/util-linux/util-linux/blob/master/Documentation/PAM-configuration.txt
		newpamd "${FILESDIR}/runuser.pamd" runuser
		newpamd "${FILESDIR}/runuser-l.pamd" runuser-l
		newpamd "${FILESDIR}/su-l.pamd" su-l
	fi

	if use su && ! use suid ; then
		# Always force suid su, even when USE=-suid, as su is useless
		# for the overwhelming-majority case without suid.
		# Users who wish to truly have a no-suid su can strip it out
		# via e.g. Portage's suidctl or some other hook.
		# See bug #832092
		fperms u+s /bin/su
	fi

	# Note:
	# Bash completion for "runuser" command is provided by same file which
	# would also provide bash completion for "su" command. However, we don't
	# use "su" command from this package.
	# This triggers a known QA warning which we ignore for now to magically
	# keep bash completion for "su" command which shadow package does not
	# provide.
}

pkg_postinst() {
	if ! use tty-helpers ; then
		elog "The mesg/wall/write tools have been disabled due to USE=-tty-helpers."
	fi

	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		elog "The agetty util now clears the terminal by default. You"
		elog "might want to add --noclear to your /etc/inittab lines."
	fi
}