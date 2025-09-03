# Copyright 2025 MacaroniOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake unpacker

DESCRIPTION="Waveshare fbcp adapted for userland Raspberry Pi with fixes for timer and headers"
HOMEPAGE="https://www.waveshare.com"
SRC_URI="https://files.waveshare.com/upload/f/f9/Waveshare_fbcp.7z -> waveshare_fbcp-1.0.7z"

LICENSE="GPL-2 GPL-2+"
SLOT="0"
KEYWORDS="*"
RESTRICT="mirror bindist"

BDEPEND="
	virtual/pkgconfig
	app-arch/p7zip
"
RDEPEND="
	media-libs/raspberrypi-userland
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack "${A}"
}

src_prepare() {
	cmake_src_prepare

	# drop hard ARM32 flags if present
	find . -type f \( -name "CMakeLists.txt" -o -name "*.cmake" -o -name "toolchain*.cmake" \) -print0 \
	| xargs -0 sed -ri 's/(^|[[:space:]])-marm([[:space:]]|$)/ /g;
	                    s/(^|[[:space:]])-mhard-float([[:space:]]|$)/ /g;
	                    s/(^|[[:space:]])-mfloat-abi=[^[:space:]]+([[:space:]]|$)/ /g;
	                    s/(^|[[:space:]])-mabi=aapcs-linux([[:space:]]|$)/ /g;
	                    s/(^|[[:space:]])-mtls-dialect=[^[:space:]]+([[:space:]]|$)/ /g' || die

	# stable 32 plus 32 timer
	cat > src/display/tick.h <<'EOF' || die
#pragma once
#include <stdint.h>

extern volatile uint32_t *systemTimerRegister;
extern volatile uint32_t *systemTimerRegisterHi;

static inline uint64_t tick(void)
{
    uint32_t hi1, lo, hi2;
    do {
        hi1 = *systemTimerRegisterHi;
        lo  = *systemTimerRegister;
        hi2 = *systemTimerRegisterHi;
    } while (hi1 != hi2);
    return ((uint64_t)hi1 << 32) | lo;
}
EOF

	cat > src/display/tick_vars.cpp <<'EOF' || die
#include <stdint.h>
volatile uint32_t *systemTimerRegister = 0;
volatile uint32_t *systemTimerRegisterHi = 0;
EOF

	# userland headers in spi.h
	awk 'NR==1{
	  if ($0 !~ /KERNEL_MODULE/){
	    print "#pragma once";
	    print "#ifndef KERNEL_MODULE";
	    print "#include <unistd.h>";
	    print "#include <sys/syscall.h>";
	    print "#include <linux/futex.h>";
	    print "#endif";
	    next
	  }
	}
	{ print }' src/display/spi.h > src/display/.spi.h.new || die
	mv src/display/.spi.h.new src/display/spi.h || die

	# cleanup old timer pointer defs
	sed -ri '/\bvolatile[[:space:]]+uint(32|64)_t[[:space:]]*\*[[:space:]]*systemTimerRegister(Hi)?[[:space:]]*=[[:space:]]*0[[:space:]]*;/d' \
		src/display/spi.cpp || die

	# enforce 32 bit pointers for CLO and CHI
	perl -0777 -i -pe 's/systemTimerRegister\s*=\s*\(volatile\s+uint64_t\*\)/systemTimerRegister = (volatile uint32_t*)/g' \
		src/display/spi.cpp || die
	awk '
	  /systemTimerRegister[[:space:]]*=.*\+ BCM2835_TIMER_BASE \+ 0x04/ && !seen {
	    print;
	    print "  systemTimerRegisterHi  = (volatile uint32_t*)((uintptr_t)bcm2835 + BCM2835_TIMER_BASE + 0x08);";
	    seen=1; next
	  }
	  { print }
	' src/display/spi.cpp > src/display/.spi.cpp.new || die
	mv src/display/.spi.cpp.new src/display/spi.cpp || die

	# posix headers in keyboard.cpp
	grep -q '^#include <unistd.h>' src/display/keyboard.cpp || sed -i '1i #include <unistd.h>' src/display/keyboard.cpp || die
	grep -q '^#include <fcntl.h>'  src/display/keyboard.cpp || sed -i '1i #include <fcntl.h>'  src/display/keyboard.cpp || die

	# sanity
	! grep -RInE 'systemTimerRegister(Hi)?[^;\n]*uint64_t' src || die "64-bit reference to timer still present"
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DSPI_BUS_CLOCK_DIVISOR=20
		-DWAVESHARE_1INCH3_LCD_HAT=ON
		-DBACKLIGHT_CONTROL=ON
		-DSTATISTICS=0
		-DUSE_DMA_TRANSFERS=OFF
	)

	# match the working script
	local CFLAGS_BCM="$(pkg-config --cflags bcm_host || echo)"
	local LIBS_BCM="$(pkg-config --libs bcm_host || echo)"
	local EXE_LDFLAGS="${LIBS_BCM} -lvchostif"

	mycmakeargs+=(
		-DCMAKE_C_FLAGS="${CFLAGS_BCM}"
		-DCMAKE_CXX_FLAGS="${CFLAGS_BCM}"
		-DCMAKE_EXE_LINKER_FLAGS="${EXE_LDFLAGS}"
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	exeinto /usr/sbin
	doexe "${BUILD_DIR}"/fbcp || die

	newinitd "${FILESDIR}"/fbcp.initd fbcp || ewarn "remember to put your init script in files/fbcp.initd"
	dodoc README* || die
}

pkg_postinst() {
	elog "fbcp has been installed to /usr/sbin/fbcp"
	elog
	if [[ -x /etc/init.d/fbcp ]]; then
		elog "To start fbcp at boot, add it to the boot runlevel:"
		elog "  # rc-update add fbcp boot"
		elog
		elog "You can also start it manually with:"
		elog "  # /etc/init.d/fbcp start"
	else
		ewarn "Init script for fbcp not found in /etc/init.d"
		ewarn "Please make sure files/fbcp.initd was installed correctly."
	fi
}
