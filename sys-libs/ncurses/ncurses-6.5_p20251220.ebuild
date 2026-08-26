# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs multilib multilib-minimal preserve-libs usr-ldscript

MY_PV="${PV:0:3}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="console display library"
HOMEPAGE="https://www.gnu.org/software/ncurses/ https://invisible-island.net/ncurses/"

PATCH_DATES=(
	20240504
	20240511
	20240518
	20240519
	20240525
	20240601
	20240608
	20240615
	20240622
	20240629
	20240706
	20240713
	20240720
	20240727
	20240810
	20240817
	20240824
	20240831
	20240914
	20240922
	20240928
	20241006
	20241019
	20241026
	20241102
	20241109
	20241123
	20241130
	20241207
	20241214
	20241221
	20241228
	20250104
	20250111
	20250118
	20250125
	20250201
	20250208
	20250215
	20250216
	20250222
	20250301
	20250308
	20250315
	20250322
	20250329
	20250405
	20250412
	20250419
	20250426
	20250503
	20250510
	20250517
	20250524
	20250531
	20250614
	20250621
	20250628
	20250705
	20250712
	20250720
	20250726
	20250802
	20250809
	20250816
	20250823
	20250830
	20250913
	20250920
	20250927
	20251004
	20251010
	20251018
	20251025
	20251101
	20251115
	20251122
	20251123
	20251129
	20251206
	20251213
	20251220
)

SRC_URI="
	https://invisible-mirror.net/archives/${PN}/${MY_P}.tar.gz
"

for patch_date in "${PATCH_DATES[@]}" ; do
	SRC_URI+="
		https://invisible-mirror.net/archives/${PN}/${MY_PV}/${MY_P}-${patch_date}.patch.gz
	"
done

UPSTREAM_PATCHES=( "${PATCH_DATES[@]/%/.patch}" )

LICENSE="MIT"
SLOT="0/6"
KEYWORDS="*"
IUSE="ada +cxx debug doc gpm minimal profile static-libs test tinfo trace unicode"
RESTRICT="!test? ( test )"

DEPEND="
	gpm? (
		sys-libs/gpm[${MULTILIB_USEDEP}]
	)
"

RDEPEND="
	${DEPEND}
	!<=sys-libs/ncurses-5.9-r4:5
	!<sys-libs/slang-2.3.2_pre23
	!<x11-terms/rxvt-unicode-9.06-r3
	!<x11-terms/st-0.6-r1
"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${UPSTREAM_PATCHES[@]/#/${WORKDIR}/${MY_P}-}"

	"${FILESDIR}/${PN}-5.7-nongnu.patch"
	"${FILESDIR}/${PN}-6.0-rxvt-unicode-9.15.patch"
	"${FILESDIR}/${PN}-6.0-pkg-config.patch"
	"${FILESDIR}/${PN}-6.0-ticlib.patch"
	"${FILESDIR}/${PN}-6.2_p20210123-cppflags-cross.patch"
)

src_configure() {
	unset TERMINFO

	tc-export_build_env BUILD_{CC,CPP}

	BUILD_CPPFLAGS+=" -D_GNU_SOURCE"

	NCURSES_TARGETS=(
		ncurses
		ncursesw
		ncursest
		ncursestw
	)

	if ! has_version -b "~sys-libs/${P}:0" ; then
		local lbuildflags="-static"

		local dbuildflags="-Wl,-rpath,${WORKDIR}/lib"

		case ${CHOST} in
			*-darwin*)
				dbuildflags=
				;;
			*-solaris*)
				dbuildflags="-Wl,-R,${WORKDIR}/lib"
				;;
		esac

		echo "int main() {}" | \
			$(tc-getCC) -o x -x c - ${lbuildflags} -pipe >& /dev/null \
			|| lbuildflags="${dbuildflags}"

		BUILD_DIR="${WORKDIR}" \
		CC=${BUILD_CC} \
		CHOST=${CBUILD} \
		CFLAGS=${BUILD_CFLAGS} \
		CXXFLAGS=${BUILD_CXXFLAGS} \
		CPPFLAGS=${BUILD_CPPFLAGS} \
		LDFLAGS="${BUILD_LDFLAGS} ${lbuildflags}" \
		do_configure cross --without-shared --with-normal --with-progs
	fi

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local t

	for t in "${NCURSES_TARGETS[@]}" ; do
		do_configure "${t}"
	done
}

do_configure() {
	local target=$1
	shift

	mkdir "${BUILD_DIR}/${target}" || die
	cd "${BUILD_DIR}/${target}" || die

	local conf=(
		--with-terminfo-dirs="${EPREFIX}/etc/terminfo:${EPREFIX}/usr/share/terminfo"

		--enable-pc-files
		--with-pkg-config-libdir="${EPREFIX}/usr/$(get_libdir)/pkgconfig"

		--with-shared
		--without-hashed-db

		$(use_with ada)
		$(use_with cxx)
		$(use_with cxx cxx-binding)

		--with-cxx-shared

		$(use_with debug)
		$(use_with profile)

		$(use_with gpm gpm libgpm.so.1)

		$(use_enable kernel_Winnt term-driver)

		--disable-termcap
		--enable-symlinks
		--with-rcs-ids
		--with-manpage-format=normal
		--enable-const
		--enable-colorfgbg
		--enable-hard-tabs
		--enable-echo

		$(use_enable !ada warnings)
		$(use_with debug assertions)
		$(use_enable !debug leaks)
		$(use_with debug expanded)
		$(use_with !debug macros)

		$(multilib_native_with progs)
		$(use_with test tests)
		$(use_with trace)
		$(use_with tinfo termlib)

		--disable-stripping
		--disable-pkg-ldflags
	)

	if [[ ${target} == ncurses*w ]] ; then
		conf+=( --enable-widec )
	else
		conf+=( --disable-widec )
	fi

	if [[ ${target} == ncursest* ]] ; then
		conf+=( --with-pthread --with-reentrant )
	else
		conf+=( --without-pthread --without-reentrant )
	fi

	if [[ ${target} == "ncurses" ]] ; then
		conf+=( --enable-overwrite )
	else
		conf+=( --includedir="${EPREFIX}/usr/include/${target}" )
	fi

	if [[ ${target} != "cross" ]] ; then
		local cross_path="${WORKDIR}/cross"

		[[ -d ${cross_path} ]] && export TIC_PATH="${cross_path}/progs/tic"
	fi

	ECONF_SOURCE="${S}" \
		econf "${conf[@]}" "$@"
}

src_compile() {
	if ! has_version -b "~sys-libs/${P}:0" ; then
		if [[ ${CHOST} == *-cygwin* ]] && ! multilib_is_native_abi ; then
			BUILD_DIR="${WORKDIR}" \
				do_compile cross -C progs all PROGS='tic$(x)'
		else
			BUILD_DIR="${WORKDIR}" \
				do_compile cross -C progs tic
		fi
	fi

	multilib-minimal_src_compile
}

multilib_src_compile() {
	local t

	for t in "${NCURSES_TARGETS[@]}" ; do
		do_compile "${t}"
	done
}

do_compile() {
	local target=$1
	shift

	cd "${BUILD_DIR}/${target}" || die

	emake -j1 sources

	rm -f misc/pc-files || die

	emake "$@"
}

multilib_src_install() {
	local target

	for target in "${NCURSES_TARGETS[@]}" ; do
		emake -C "${BUILD_DIR}/${target}" DESTDIR="${D}" install
	done

	if multilib_is_native_abi ; then
		gen_usr_ldscript -a \
			"${NCURSES_TARGETS[@]}" \
			$(usex tinfo 'tinfow tinfo' '')
	fi

	if ! tc-is-static-only ; then
		ln -sf \
			libncurses$(get_libname) \
			"${ED}"/usr/$(get_libdir)/libcurses$(get_libname) \
			|| die
	fi

	if ! use static-libs ; then
		find "${ED}"/usr/ \
			-name '*.a' \
			! -name '*.dll.a' \
			-delete \
			|| die
	fi

	dosym \
		$(sed 's@[^/]\+@..@g' <<< $(get_libdir))/share/terminfo \
		/usr/$(get_libdir)/terminfo
}

multilib_src_install_all() {
	einfo "Installing basic terminfo files in /etc..."

	local terms=(
		ansi
		console
		dumb
		linux
		vt{52,100,102,200,220}
		rxvt{,-unicode}{,-256color}
		xterm
		xterm-{,256}color
		screen{,-256color}
		screen.xterm-256color
	)

	local x

	for x in "${terms[@]}" ; do
		local termfile
		local basedir

		termfile=$(find "${ED}"/usr/share/terminfo/ -name "${x}" 2>/dev/null)
		basedir=$(basename "$(dirname "${termfile}")")

		if [[ -n ${termfile} ]] ; then
			dodir "/etc/terminfo/${basedir}"

			mv \
				"${termfile}" \
				"${ED}/etc/terminfo/${basedir}/" \
				|| die

			dosym \
				"../../../../etc/terminfo/${basedir}/${x}" \
				"/usr/share/terminfo/${basedir}/${x}"
		fi
	done

	echo 'CONFIG_PROTECT_MASK="/etc/terminfo"' | newenvd - 50ncurses

	if use minimal ; then
		rm -r "${ED}"/usr/share/terminfo* || die
	fi

	keepdir /usr/share/terminfo

	cd "${S}" || die

	dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc

	if use doc ; then
		docinto html
		dodoc -r doc/html/
	fi
}

pkg_preinst() {
	preserve_old_lib /$(get_libdir)/libncurses.so.5
	preserve_old_lib /$(get_libdir)/libncursesw.so.5
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/libncurses.so.5
	preserve_old_lib_notify /$(get_libdir)/libncursesw.so.5
}
