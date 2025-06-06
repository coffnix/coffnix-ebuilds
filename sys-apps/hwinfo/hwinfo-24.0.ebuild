# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Hardware information tool"
HOMEPAGE="https://github.com/openSUSE/hwinfo"
SRC_URI="https://github.com/openSUSE/hwinfo/tarball/23e902b07a4b09e5348d7387bda8b7f206ea2695 -> hwinfo-24.0-23e902b.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	amd64? ( dev-libs/libx86emu )
	x86? ( dev-libs/libx86emu )"
DEPEND="${RDEPEND}
	sys-devel/flex
	>=sys-kernel/linux-headers-2.6.17"

post_src_unpack() {
	if [ ! -d "${S}" ] ; then
		mv "${WORKDIR}"/openSUSE-hwinfo-* "${S}" || die
	fi
}

src_prepare() {
	echo "${PV}" > VERSION
	sed -i "s/changelog//g" Makefile

	# Respect AR variable.
	sed -i \
		-e 's:ar r:$(AR) r:' \
		src/{,isdn,ids,smp,hd}/Makefile || die

	# Respect LDFLAGS.
	sed -i -e 's:$(CC) $(CFLAGS):$(CC) $(LDFLAGS) $(CFLAGS):' src/ids/Makefile || die

	# Respect MAKE variable. Skip forced -pipe and -g. Respect LDFLAGS.
	sed -i \
		-e 's:make:$(MAKE):' \
		-e 's:-pipe -g::' \
		-e 's:LDFLAGS.*=:LDFLAGS +=:' \
		Makefile{,.common} || die

	default
}

# Let's just list the issues with the application that require this
# 1. The makefile produces errors in normal behaviour, hence why in src_compile we use raw make
# 1. The MAKEOPTS are not used because it results in inconsisent fails with parallel
# 1. When the first make fails we might not be getting an error so we have a final check here that just calls
#    make and tests if the executable exists. Why call again? On a random basis the executable might not be
#    output on the first try but calling make again fixes all the problems and ofc if this fails there definitely
#    is an error
# 1. Double compilation here is not a problem. Why? Because there is a really slow algorithm that fixes errors
#    that runs in an O(n^2) loop. This loop resolves the errors mentioned above but also takes about
#    7 minutes on a system that uses a 12 core AMD Ryzen 9 3900x with 32gb of ram. A PR is opened on the repo and
#    as of the time of writing(version 22.1) we hope that the next release would have this resolved. Additonally
#    the application is small in translation units so it doesn't make a difference
fallback_compilation_strategy() {
	make CC="$1" RPM_OPT_FLAGS="$2" || (make; test -f "${WORKDIR}/hwinfo") || die
}

src_compile() {
	tc-export AR
	cc=$(tc-getCC)
	make CC="${cc}" RPM_OPT_FLAGS="${CFLAGS}" ${MAKEOPTS} || fallback_compilation_strategy "${cc}" "${CFLAGS}"
}

src_install() {
	emake DESTDIR="${ED}" LIBDIR="/usr/$(get_libdir)" install
	keepdir /var/lib/hardware/udi

	dodoc README*
	docinto examples
	dodoc doc/example*.c
	doman doc/*.{1,8}
}