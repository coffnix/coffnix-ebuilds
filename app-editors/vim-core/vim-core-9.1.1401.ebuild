# Distributed under the terms of the GNU General Public License v2

EAPI=7
VIM_VERSION="$(ver_cut 1-2)"
inherit bash-completion-r1 desktop flag-o-matic prefix vim-doc xdg-utils

DESCRIPTION="Vim and GVim shared files"
HOMEPAGE="http://www.vim.org/ https://github.com/vim/vim"
SRC_URI="https://github.com/vim/vim/archive/v9.1.1401/v9.1.1401.tar.gz -> vim-9.1.1401.tar.gz"
S=${WORKDIR}/vim-${PV}

SLOT="0"
LICENSE="vim"
KEYWORDS="*"
IUSE="nls acl minimal"

# ncurses is only needed by ./configure, so no subslot operator required
DEPEND=">=sys-libs/ncurses-5.2-r2:0"
BDEPEND="sys-devel/autoconf"

pkg_setup() {
	# people with broken alphabets run into trouble. bug 82186.
	unset LANG LC_ALL
	export LC_COLLATE="C"
}

src_prepare() {
	default

	# Fixup a script to use awk instead of nawk
	sed -i \
		-e '1s|.*|#!'"${EPREFIX}"'/usr/bin/awk -f|' \
		"${S}"/runtime/tools/mve.awk || die "sed failed"

	# See bug #77841. We remove this file after the tarball extraction.
	rm -v "${S}"/runtime/tools/vimspell.sh || die "rm failed"

	# Read vimrc and gvimrc from /etc/vim
	echo '#define SYS_VIMRC_FILE "'${EPREFIX}'/etc/vim/vimrc"' >> "${S}"/src/feature.h
	echo '#define SYS_GVIMRC_FILE "'${EPREFIX}'/etc/vim/gvimrc"' >> "${S}"/src/feature.h

	# Use exuberant ctags which installs as /usr/bin/exuberant-ctags.
	# Hopefully this pattern won't break for a while at least.
	# This fixes bug 29398 (27 Sep 2003 agriffis)
	sed -i 's/\<ctags\("\| [-*.]\)/exuberant-&/g' \
		"${S}"/runtime/doc/syntax.txt \
		"${S}"/runtime/doc/tagsrch.txt \
		"${S}"/runtime/doc/usr_29.txt \
		"${S}"/runtime/menu.vim \
		"${S}"/src/configure.ac || die 'sed failed'

	# Don't be fooled by /usr/include/libc.h.  When found, vim thinks
	# this is NeXT, but it's actually just a file in dev-libs/9libs
	# This fixes bug 43885 (20 Mar 2004 agriffis)
	sed -i 's/ libc\.h / /' "${S}"/src/configure.ac || die 'sed failed'

	# gcc on sparc32 has this, uhm, interesting problem with detecting EOF
	# correctly. To avoid some really entertaining error messages about stuff
	# which isn't even in the source file being invalid, we'll do some trickery
	# to make the error never occur. bug 66162 (02 October 2004 ciaranm)
	find "${S}" -name '*.c' | while read c; do
		echo >> "$c" || die "echo failed"
	done

	# Try to avoid sandbox problems. Bug #114475.
	if [[ -d "${S}"/src/po ]] ; then
		sed -i -e \
			'/-S check.vim/s,..VIM.,ln -s $(VIM) testvim \; ./testvim -X,' \
			"${S}"/src/po/Makefile
	fi

	cp "${S}"/src/config.mk.dist "${S}"/src/auto/config.mk || die "Failed to copy config.mk"

	# Bug #378.17 - Build properly with >=perl-core/ExtUtils-ParseXS-3.20.0
	sed -i "s:\\\$(PERLLIB)/ExtUtils/xsubpp:${EPREFIX}/usr/bin/xsubpp:"	\
		"${S}"/src/Makefile || die 'sed for ExtUtils-ParseXS failed'

	# Fix bug #76331: -O3 causes problems, use -O2 instead. We'll do this for
	# everyone since previous flag filtering bugs have turned out to affect
	# multiple archs...
	replace-flags -O3 -O2

	# Fix bug #18245: Prevent "make" from the following chain:
	# (1) Notice configure.ac is newer than auto/configure
	# (2) Rebuild auto/configure
	# (3) Notice auto/configure is newer than auto/config.mk
	# (4) Run ./configure (with wrong args) to remake auto/config.mk
	sed -i 's# auto/config\.mk:#:#' src/Makefile || die "Makefile sed failed"

	# Remove src/auto/configure file.
	rm -v src/auto/configure || die "rm configure failed"
}

src_configure() {
	# Fix bug 37354: Disallow -funroll-all-loops on amd64
	# Bug 57859 suggests that we want to do this for all archs
	filter-flags -funroll-all-loops

	emake -j1 -C src autoconf

	# This should fix a sandbox violation (see bug 24447). The hvc
	# things are for ppc64, see bug 86433.
	for file in /dev/pty/s* /dev/console /dev/hvc/* /dev/hvc*; do
		if [[ -e "${file}" ]]; then
			addwrite ${file}
		fi
	done

	# Let Portage do the stripping. Some people like that.
	export ac_cv_prog_STRIP="$(type -P true ) faking strip"

	local myconf=(
		--with-modified-by=Funtoo-${PVR}
		--enable-gui=no
		--without-x
		--disable-darwin
		--disable-perlinterp
		--disable-pythoninterp
		--disable-rubyinterp
		--disable-gpm
		--disable-selinux
		$(use_enable nls)
		$(use_enable acl)
	)

	# Keep Gentoo Prefix env contained within the EPREFIX
	use prefix && myconf+=( --without-local-dir )

	econf "${myconf[@]}"
}

src_compile() {
	# The following allows emake to be used
	emake -j1 -C src auto/osdef.h objects

	emake tools
}

src_test() { :; }

src_install() {
	local vimfiles=/usr/share/vim/vim${VIM_VERSION/.}

	dodir /usr/{bin,share/{man/man1,vim}}
	emake -C src \
		installruntime \
		installmanlinks \
		installmacros \
		installtutor \
		installtutorbin \
		installtools \
		install-languages \
		DESTDIR="${D}" \
		BINDIR="${EPREFIX}"/usr/bin \
		MANDIR="${EPREFIX}"/usr/share/man \
		DATADIR="${EPREFIX}"/usr/share

	keepdir ${vimfiles}/keymap

	# default vimrc is installed by vim-core since it applies to
	# both vim and gvim
	insinto /etc/vim/
	newins "${FILESDIR}"/vimrc-funtoo-1 vimrc
	eprefixify "${ED}"/etc/vim/vimrc

	if use minimal ; then
		# To save space, install only a subset of the files.
		# Helps minimalize the livecd, bug 65144.
		rm -rv "${ED}${vimfiles}"/{compiler,doc,ftplugin,indent} || die
		rm -rv "${ED}${vimfiles}"/{macros,print,tools,tutor} || die
		rm -v "${ED}"/usr/bin/vimtutor || die

		for f in "${ED}${vimfiles}"/colors/*.vim; do
			if [[ ${f} != */@(default).vim ]] ; then
				printf '%s\0' "${f}"
			fi
		done | xargs -0 rm -f || die

		for f in "${ED}${vimfiles}"/syntax/*.vim; do
			if [[ ${f} != */@(conf|crontab|fstab|inittab|resolv|sshdconfig|syntax|nosyntax|synload).vim ]] ; then
				printf '%s\0' "${f}"
			fi
		done | xargs -0 rm -f || die
	fi
	rm -f "${ED}${vimfiles}"/doc/tags || die

	newbashcomp "${FILESDIR}"/xxd-completion xxd

	# install gvim icon since both vim/gvim desktop files reference it
	doicon -s scalable "${FILESDIR}"/gvim.svg
}

pkg_postinst() {
	# Update documentation tags (from vim-doc.eclass)
	update_vim_helptags

	# update icon cache
	xdg_icon_cache_update
}

pkg_postrm() {
	# Update documentation tags (from vim-doc.eclass)
	update_vim_helptags

	# update icon cache
	xdg_icon_cache_update
}