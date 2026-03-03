# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

NSS_CHK_SIGN_LIBS="freebl3 nssdbm3 softokn3"

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Mozilla's Network Security Services library that implements PKI support"
HOMEPAGE="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS"
SRC_URI="https://ftp.mozilla.org/pub/security/nss/releases/NSS_3_120_RTM/src/nss-3.120.tar.gz -> nss-3.120.tar.gz"

LICENSE="|| ( MPL-2.0 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="*"
IUSE="+utils"

RDEPEND="app-admin/whip
	sys-apps/whip-catalog
	dev-libs/nspr
	dev-db/sqlite
	sys-libs/zlib
	virtual/pkgconfig
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}/${PN}"

nssarch() {
	local t=${1:-${CHOST}}
	case ${t} in
		aarch64*) echo "aarch64" ;;
		x86_64*)  echo "x86_64" ;;
		i?86*)    echo "i686" ;;
		*86*-pc-solaris2*) echo "i86pc" ;;
		hppa*)    echo "parisc" ;;
		*)        tc-arch ${t} ;;
	esac
}

src_prepare() {
	default

	sed -e "/print('-Werror')/d" -i -e "s|'-Werror',||g" coreconf/werror.py || die
	sed -i -e 's|gtests$||g' manifest.mn || die

	pushd coreconf >/dev/null || die
	echo 'INCLUDES += -I$(DIST)/include/dbm' >> headers.mk || die
	sed -e '/CORE_DEPTH/s:SOURCE_PREFIX.*$:SOURCE_PREFIX = $(CORE_DEPTH)/dist:' \
		-i source.mk || die
	sed -i -e 's/\$(MKSHLIB) -o/\$(MKSHLIB) \$(LDFLAGS) -o/g' rules.mk || die
	popd >/dev/null || die

	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../freebl/\$(OBJDIR):" \
		lib/ssl/config.mk || die
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../../lib/freebl/\$(OBJDIR):" \
		cmd/platlibs.mk || die

	strip-flags
}

src_compile() {
	local myCPPFLAGS="${CPPFLAGS} $($(tc-getPKG_CONFIG) nspr --cflags)"
	unset NSPR_INCLUDE_DIR

	export NSS_ALLOW_SSLKEYLOGFILE=1
	export NSS_ENABLE_WERROR=0
	export BUILD_OPT=1
	export NSS_USE_SYSTEM_SQLITE=1
	export NSDISTMODE=copy
	export FREEBL_NO_DEPEND=1
	export FREEBL_LOWHASH=1
	export NSS_SEED_ONLY_DEV_URANDOM=1
	export USE_SYSTEM_ZLIB=1
	export ZLIB_LIBS=-lz
	export ASFLAGS=""
	export NS_USE_GCC=1

	if tc-is-gcc; then
		export CC_IS_GCC=1
	elif tc-is-clang; then
		export CC_IS_CLANG=1
	fi

	local ostest="$(nssarch)"
	export USE_64=1

	NSPR_LIB_DIR="${T}/fakedir" \
	emake -j1 -C coreconf || die

	local makeargs=()
	makeargs+=( NSINSTALL="${PWD}/$(find -type f -name nsinstall)" )

	for d in . lib/dbm ; do
		CPPFLAGS="${myCPPFLAGS}" \
		XCFLAGS="${CFLAGS} ${CPPFLAGS}" \
		NSPR_LIB_DIR="${T}/fakedir" \
		emake -j1 "${makeargs[@]}" -C ${d} OS_TEST="${ostest}" || die
	done
}

src_install() {
	pushd dist >/dev/null || die

	dodir /usr/$(get_libdir)
	cp -L */lib/*$(get_libname) "${ED}"/usr/$(get_libdir) || die

	for i in crmf freebl nssb nssckfw ; do
		cp -L */lib/lib${i}.a "${ED}"/usr/$(get_libdir) || die
	done

	dodir /usr/$(get_libdir)/pkgconfig
	cp -L */lib/pkgconfig/nss.pc "${ED}"/usr/$(get_libdir)/pkgconfig || die
	cp -L */lib/pkgconfig/nss-util.pc "${ED}"/usr/$(get_libdir)/pkgconfig || die

	sed -e 's#Libs:#Libs: -lfreebl#' \
		-e 's#Cflags:#Cflags: -I${includedir}/private#' \
		*/lib/pkgconfig/nss.pc \
		> "${ED}"/usr/$(get_libdir)/pkgconfig/nss-softokn.pc || die

	dosym /usr/$(get_libdir)/pkgconfig/nss.pc \
		/usr/$(get_libdir)/pkgconfig/mozilla-nss.pc

	insinto /usr/include/nss
	doins public/nss/*.{h,api}
	insinto /usr/include/nss/private
	doins private/nss/{blapi,alghmac,cmac}.h

	local f nssutils
	nssutils=( shlibsign )

	if use utils; then
		nssutils+=(
			addbuiltin atob baddbdir btoa certutil cmsutil conflict crlutil
			derdump digest makepqg mangle modutil multinit nonspr10
			ocspclnt oidcalc p7content p7env p7sign p7verify pk11mode
			pk12util pp rsaperf selfserv signtool signver ssltap
			strsclnt symkeyutil tstclnt vfychain vfyserv
		)
		doman doc/nroff/*.1
	fi

	pushd dist/*/bin >/dev/null || die
	for f in "${nssutils[@]}"; do
		dobin "${f}"
	done
	popd >/dev/null || die

	popd >/dev/null || die

	dodir /etc/prelink.conf.d
	printf -- "-b ${EPREFIX}/usr/$(get_libdir)/lib%s.so\n" ${NSS_CHK_SIGN_LIBS} \
		> "${ED}"/etc/prelink.conf.d/nss.conf || die
}

pkg_postinst() {
	whip h nss.postinst
}

pkg_postrm() {
	whip h nss.postrm
}
