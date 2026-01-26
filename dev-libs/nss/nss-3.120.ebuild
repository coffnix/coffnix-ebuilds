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
DEPEND="${RDEPEND}
"
S="${WORKDIR}/${P}/${PN}"
src_prepare() {
	default
	 sed -e "/print('-Werror')/d" -i -e "s|'-Werror',||g" \
	  coreconf/werror.py
	sed -i -e 's|gtests$||g' manifest.mn
	 pushd coreconf >/dev/null || die
	# hack nspr paths
	echo 'INCLUDES += -I$(DIST)/include/dbm' \
	  >> headers.mk || die "failed to append include"
	 # modify install path
	sed -e '/CORE_DEPTH/s:SOURCE_PREFIX.*$:SOURCE_PREFIX = $(CORE_DEPTH)/dist:' \
	  -i source.mk || die
	 # Respect LDFLAGS
	sed -i -e 's/\$(MKSHLIB) -o/\$(MKSHLIB) \$(LDFLAGS) -o/g' rules.mk
	popd >/dev/null || die
	 # dirty hack
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../freebl/\$(OBJDIR):" \
	  lib/ssl/config.mk || die
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../../lib/freebl/\$(OBJDIR):" \
	  cmd/platlibs.mk || die
	 strip-flags
}
src_compile() {
	# Take care of nspr settings #436216
	local myCPPFLAGS="${CPPFLAGS} $($(tc-getPKG_CONFIG) nspr --cflags)"
	unset NSPR_INCLUDE_DIR
	 export NSS_ALLOW_SSLKEYLOGFILE=1
	export NSS_ENABLE_WERROR=0 #567158
	export BUILD_OPT=1
	export NSS_USE_SYSTEM_SQLITE=1
	export NSDISTMODE=copy
	export FREEBL_NO_DEPEND=1
	export FREEBL_LOWHASH=1
	export NSS_SEED_ONLY_DEV_URANDOM=1
	export USE_SYSTEM_ZLIB=1
	export ZLIB_LIBS=-lz
	export ASFLAGS=""
	# Fix build failure on arm64
	export NS_USE_GCC=1
	# Detect compiler type and set proper environment value
	if tc-is-gcc; then
	    export CC_IS_GCC=1
	elif tc-is-clang; then
	    export CC_IS_CLANG=1
	fi
	 local d
	local ostest="x86_64"
	if use arm ; then
	  ostest=$(tc-arch ${CHOST})
	  export USE_N32=1
	else
	  export USE_64=1
	fi
	 # Build the host tools first.
	NSPR_LIB_DIR="${T}/fakedir" \
	emake -j1 -C coreconf
	makeargs+=( NSINSTALL="${PWD}/$(find -type f -name nsinstall)" )
	 # Then build the target tools.
	for d in . lib/dbm ; do
	  CPPFLAGS="${myCPPFLAGS}" \
	  XCFLAGS="${CFLAGS} ${CPPFLAGS}" \
	  NSPR_LIB_DIR="${T}/fakedir" \
	  emake -j1 "${makeargs[@]}" -C ${d} OS_TEST="${ostest}"
	done
}
src_install() {
	local nss_vmajor=$(awk '/#define.*NSS_VMAJOR/ {print $3}' lib/nss/nss.h)
	local nss_vminor=$(awk '/#define.*NSS_VMINOR/ {print $3}' lib/nss/nss.h)
	local nss_vpatch=$(awk '/#define.*NSS_VPATCH/ {print $3}' lib/nss/nss.h)
	local nspr_version="$(pkg-config --modversion nspr)"
	 pushd dist >/dev/null || die
	 dodir /usr/$(get_libdir)
	cp -L */lib/*$(get_libname) "${ED}"/usr/$(get_libdir) || die "copying shared libs failed"
	local i
	for i in crmf freebl nssb nssckfw ; do
	  cp -L */lib/lib${i}.a "${ED}"/usr/$(get_libdir) || die "copying libs failed"
	done
	 # Install nss-config and pkgconfig file
	#
	# pkgconfig files
	dodir /usr/$(get_libdir)/pkgconfig
	local _pc; for _pc in nss.pc nss-util.pc nss-softokn.pc; do
	  sed "${FILESDIR}"/$_pc.in \
	    -e "s,%libdir%,/usr/$(get_libdir),g" \
	    -e "s,%prefix%,/usr,g" \
	    -e "s,%exec_prefix%,/usr/bin,g" \
	    -e "s,%includedir%,/usr/include/nss,g" \
	    -e "s,%SOFTOKEN_VERSION%,${PV},g" \
	    -e "s,%NSPR_VERSION%,$nspr_version,g" \
	    -e "s,%NSS_VERSION%,${PV}r,g" \
	    -e "s,%NSSUTIL_VERSION%,${PV},g" \
	    > "${ED}"/usr/$(get_libdir)/pkgconfig/$_pc
	done
	dosym /usr/$(get_libdir)/pkgconfig/nss.pc /usr/$(get_libdir)/pkgconfig/mozilla-nss.pc
	 # nss-config
	dodir /usr/bin
	sed "${FILESDIR}"/nss-config.in \
	  -e "s,@libdir@,/usr/$(get_libdir),g" \
	  -e "s,@prefix@,/usr/bin,g" \
	  -e "s,@exec_prefix@,/usr/bin,g" \
	  -e "s,@includedir@,/usr/include/nss,g" \
	  -e "s,@MOD_MAJOR_VERSION@,${nss_vmajor},g" \
	  -e "s,@MOD_MINOR_VERSION@,${nss_vminor},g" \
	  -e "s,@MOD_PATCH_VERSION@,${nss_vpatch},g" \
	  > "${ED}"/usr/bin/nss-config
	chmod 755 "${ED}"/usr/bin/nss-config
	 # all the include files
	insinto /usr/include/nss
	doins public/nss/*.{h,api}
	insinto /usr/include/nss/private
	doins private/nss/{blapi,alghmac,cmac}.h
	 popd >/dev/null || die
	 local f nssutils
	# Always enabled because we need it for chk generation.
	nssutils=( shlibsign )
	 if use utils; then
	  nssutils+=(
	    addbuiltin
	    atob
	    baddbdir
	    btoa
	    certutil
	    cmsutil
	    conflict
	    crlutil
	    derdump
	    digest
	    makepqg
	    mangle
	    modutil
	    multinit
	    nonspr10
	    ocspclnt
	    oidcalc
	    p7content
	    p7env
	    p7sign
	    p7verify
	    pk11mode
	    pk12util
	    pp
	    rsaperf
	    selfserv
	    signtool
	    signver
	    ssltap
	    strsclnt
	    symkeyutil
	    tstclnt
	    vfychain
	    vfyserv
	  )
	  # install man-pages for utils (bug #516810)
	  doman doc/nroff/*.1
	fi
	pushd dist/*/bin >/dev/null || die
	for f in ${nssutils[@]}; do
	  dobin ${f}
	done
	popd >/dev/null || die
	 # Prelink breaks the CHK files. We don't have any reliable way to run
	# shlibsign after prelink.
	dodir /etc/prelink.conf.d
	printf -- "-b ${EPREFIX}/usr/$(get_libdir)/lib%s.so\n" ${NSS_CHK_SIGN_LIBS} \
	  > "${ED}"/etc/prelink.conf.d/nss.conf
}
pkg_postinst() {
	whip h nss.postinst
}
pkg_postrm() {
	whip h nss.postrm
}


# vim: filetype=ebuild
