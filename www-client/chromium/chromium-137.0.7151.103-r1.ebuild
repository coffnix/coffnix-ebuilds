# Copyright 2009-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# PACKAGING NOTES

# Upstream roll their bundled Clang every two weeks, and the bundled Rust
# is rolled regularly and depends on that. While we do our best to build
# with system Clang, we may eventually hit the point where we need to use
# the bundled Clang due to the use of prerelease features.

# Since m133 we are using CI-generated tarballs from
# https://github.com/chromium-linux-tarballs/chromium-tarballs/ (uploaded to S3
# and made available via https://chromium-tarballs.distfiles.gentoo.org/).

# We do this because upstream tarballs weigh in at about 3.5x the size of our
# new "Distro tarballs" and include binaries (etc) that are not useful for
# downstream consumers (like distributions).

GN_MIN_VER=0.2217
RUST_SLOT="1.78"
LLVM_SLOT=16
LLVM_COMPAT=( 16 )
# chromium-tools/get-chromium-toolchain-strings.py
TEST_FONT=f26f29c9d3bfae588207bbc9762de8d142e58935c62a86f67332819b15203b35
NODE_VER=22.11.0

VIRTUALX_REQUIRED="pgo"

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="xml(+)"
inherit check-reqs chromium-2 desktop flag-o-matic llvm multiprocessing ninja-utils pax-utils python-any-r1 readme.gentoo-r1 systemd toolchain-funcs virtualx xdg-utils

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="https://www.chromium.org/"
PPC64_HASH="a85b64f07b489b8c6fdb13ecf79c16c56c560fc6"
PATCH_V="${PV%%\.*}"
SRC_URI="https://github.com/chromium-linux-tarballs/chromium-tarballs/releases/download/${PV}/chromium-${PV}-linux.tar.xz
	https://gitlab.com/Matt.Jolly/chromium-patches/-/archive/${PATCH_V}/chromium-patches-${PATCH_V}.tar.bz2
	test? (
		https://github.com/chromium-linux-tarballs/chromium-tarballs/releases/download/${PV}/chromium-${PV}-linux-testdata.tar.xz
		https://chromium-fonts.storage.googleapis.com/${TEST_FONT} -> chromium-testfonts-${TEST_FONT:0:10}.tar.gz
	)
	ppc64? (
		https://gitlab.raptorengineering.com/raptor-engineering-public/chromium/openpower-patches/-/archive/${PPC64_HASH}/openpower-patches-${PPC64_HASH}.tar.bz2 -> chromium-openpower-${PPC64_HASH:0:10}.tar.bz2
	)
	pgo? ( https://github.com/elkablo/chromium-profiler/releases/download/v0.2/chromium-profiler-0.2.tar )"

# https://gitweb.gentoo.org/proj/chromium-tools.git/tree/get-chromium-licences.py
LICENSE="BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD"
LICENSE+=" FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 libpng libpng2 MIT MPL-1.1 MPL-2.0 Ms-PL openssl PSF-2"
LICENSE+=" SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA X11-Lucent"
LICENSE+=" rar? ( unRAR )"

SLOT="0/stable"
if [[ ${SLOT} != "0/dev" ]]; then
	KEYWORDS="amd64 ~arm64 ~ppc64"
fi

IUSE_SYSTEM_LIBS="+system-harfbuzz +system-icu +system-png +system-zstd"
IUSE="+X ${IUSE_SYSTEM_LIBS} bindist cups debug ffmpeg-chromium gtk4 +hangouts headless kerberos +official pax-kernel +pgo +custom-cflags"
IUSE+=" +proprietary-codecs pulseaudio qt6 +rar screencast selinux test vaapi wayland +widevine cpu_flags_ppc_vsx3"
RESTRICT="
	!bindist? ( bindist )
	!test? ( test )
"

REQUIRED_USE="
	!headless? ( || ( X wayland ) )
	pgo? ( X !wayland )
	screencast? ( wayland )
	ffmpeg-chromium? ( bindist proprietary-codecs )
"

COMMON_X_DEPEND="
	x11-libs/libXcomposite:=
	x11-libs/libXcursor:=
	x11-libs/libXdamage:=
	x11-libs/libXfixes:=
	>=x11-libs/libXi-1.6.0:=
	x11-libs/libXrandr:=
	x11-libs/libXrender:=
	x11-libs/libXtst:=
	x11-libs/libxshmfence:=
"

COMMON_SNAPSHOT_DEPEND="
	system-icu? ( >=dev-libs/icu-73.0:= )
	>=dev-libs/libxml2-2.12.4:=[icu]
	dev-libs/nspr:=
	>=dev-libs/nss-3.26:=
	dev-libs/libxslt:=
	media-libs/fontconfig:=
	>=media-libs/freetype-2.11.0-r1:=
	system-harfbuzz? ( >=media-libs/harfbuzz-3:0=[icu(-)] )
	media-libs/libjpeg-turbo:=
	system-png? ( media-libs/libpng:=[-apng(-)] )
	system-zstd? ( >=app-arch/zstd-1.5.5:= )
	>=media-libs/libwebp-0.4.0:=
	media-libs/mesa:=[gbm(+)]
	>=media-libs/openh264-1.6.0:=
	sys-libs/zlib:=
	!headless? (
		dev-libs/glib:2
		>=media-libs/alsa-lib-1.0.19:=
		pulseaudio? ( media-libs/libpulse:= )
		sys-apps/pciutils:=
		kerberos? ( virtual/krb5 )
		vaapi? ( >=media-libs/libva-2.7:=[X?,wayland?] )
		X? (
			x11-base/xorg-proto:=
			x11-libs/libX11:=
			x11-libs/libxcb:=
			x11-libs/libXext:=
		)
		x11-libs/libxkbcommon:=
		wayland? (
			dev-libs/libffi:=
			dev-libs/wayland:=
			screencast? ( media-video/pipewire:= )
		)
	)
"

COMMON_DEPEND="
	${COMMON_SNAPSHOT_DEPEND}
	app-arch/bzip2:=
	dev-libs/expat:=
	net-misc/curl[ssl]
	sys-apps/dbus:=
	media-libs/flac:=
	sys-libs/zlib:=[minizip]
	!headless? (
		>=app-accessibility/at-spi2-core-2.46.0:2
		media-libs/mesa:=[X?,wayland?]
		virtual/udev
		x11-libs/cairo:=
		x11-libs/gdk-pixbuf:2
		x11-libs/pango:=
		cups? ( >=net-print/cups-1.3.11:= )
		qt6? ( dev-qt/qtbase:6[gui,widgets] )
		X? ( ${COMMON_X_DEPEND} )
	)
"
RDEPEND="${COMMON_DEPEND}
	!headless? (
		|| (
			x11-libs/gtk+:3[X?,wayland?]
			gui-libs/gtk:4[X?,wayland?]
		)
		qt6? ( dev-qt/qtbase:6[X?,wayland?] )
	)
	virtual/ttf-fonts
	selinux? ( sec-policy/selinux-chromium )
	bindist? (
		!ffmpeg-chromium? ( >=media-video/ffmpeg-6.1-r1:0/58.60.60[chromium] )
		ffmpeg-chromium? ( media-video/ffmpeg-chromium:${PV%%\.*} )
	)
"
DEPEND="${COMMON_DEPEND}
	!headless? (
		gtk4? ( gui-libs/gtk:4[X?,wayland?] )
		!gtk4? ( x11-libs/gtk+:3[X?,wayland?] )
	)
"

BDEPEND="
	${COMMON_SNAPSHOT_DEPEND}
	${PYTHON_DEPS}
	$(python_gen_any_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/jinja[${PYTHON_USEDEP}]
	')
	>=app-arch/gzip-1.7
	!headless? (
		qt6? ( dev-qt/qtbase:6 )
	)
	>=sys-devel/clang-16
	>=sys-devel/llvm-16
	>=sys-devel/lld-16
	official? (
		!ppc64? ( >=sys-libs/compiler-rt-sanitizers-16[cfi] )
	)
	pgo? (
		dev-python/selenium
		>=dev-util/web_page_replay_go-20220314
	)
	>=dev-util/bindgen-0.68.0
	>=dev-util/gn-${GN_MIN_VER}
	dev-util/ninja
	dev-lang/perl
	>=dev-util/gperf-3.2
	dev-vcs/git
	net-libs/nodejs
	>=sys-devel/bison-2.4.3
	sys-devel/flex
	virtual/pkgconfig
"

if ! has chromium_pkg_die ${EBUILD_DEATH_HOOKS}; then
	EBUILD_DEATH_HOOKS+=" chromium_pkg_die";
fi

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
Some web pages may require additional fonts to display properly.
Try installing some of the following packages if some characters
are not displayed properly:
- media-fonts/arphicfonts
- media-fonts/droid
- media-fonts/ipamonafont
- media-fonts/noto
- media-fonts/ja-ipafonts
- media-fonts/takao-fonts
- media-fonts/wqy-microhei
- media-fonts/wqy-zenhei

To fix broken icons on the Downloads page, you should install an icon
theme that covers the appropriate MIME types, and configure this as your
GTK+ icon theme.

For native file dialogs in KDE, install kde-apps/kdialog.

To make password storage work with your desktop environment you may
have install one of the supported credentials management applications:
- app-crypt/libsecret (GNOME)
- kde-frameworks/kwallet (KDE)
If you have one of above packages installed, but don't want to use
them in Chromium, then add --password-store=basic to CHROMIUM_FLAGS
in /etc/chromium/default.
"

python_check_deps() {
	python_has_version "dev-python/setuptools[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/jinja[${PYTHON_USEDEP}]"
}

pre_build_checks() {
	local base_disk=9
	use test && base_disk=$((base_disk + 5))
	local extra_disk=1
	local memory=4
	tc-is-cross-compiler && extra_disk=$((extra_disk * 2))
	if use pgo; then
		memory=$((memory * 2 + 1))
		tc-is-cross-compiler && extra_disk=$((extra_disk * 2))
		use pgo && extra_disk=$((extra_disk + 4))
	fi
	if is-flagq '-g?(gdb)?([1-9])'; then
		if use custom-cflags; then
			extra_disk=$((extra_disk + 5))
		fi
		memory=$((memory * 2))
	fi
	local CHECKREQS_MEMORY="${memory}G"
	local CHECKREQS_DISK_BUILD="$((base_disk + extra_disk))G"
	check-reqs_${EBUILD_PHASE_FUNC}
}

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		pre_build_checks
	fi

	if use headless; then
		local headless_unused_flags=("cups" "kerberos" "pulseaudio" "qt6" "vaapi" "wayland")
		for myiuse in ${headless_unused_flags[@]}; do
			use ${myiuse} && ewarn "Ignoring USE=${myiuse}, USE=headless is set."
		done
	fi

	if ! use bindist && use ffmpeg-chromium; then
		ewarn "Ignoring USE=ffmpeg-chromium, USE=bindist is not set."
	fi
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		pre_build_checks

		use_lto="true"
		append-flags -flto
		append-ldflags -flto
		if use test && ! use arm64; then
			die "Tests require CFI which requires LTO"
		fi

		export use_lto

		AR=llvm-ar
		CPP="${CHOST}-clang++ -E"
		NM=llvm-nm
		CC="${CHOST}-clang"
		CXX="${CHOST}-clang++"

		if tc-is-cross-compiler; then
			use pgo && die "The pgo USE flag cannot be used when cross-compiling"
			CPP="${CBUILD}-clang++ -E"
		fi

		export RUSTC_BOOTSTRAP=1

		gn_ver=$(gn --version | awk '{print $1}' || die)
		gn_min_ver_num=$(echo "${GN_MIN_VER}" | tr -d '.')
		if [[ "${gn_ver}" -lt "${gn_min_ver_num}" ]]; then
			die "dev-build/gn >= ${GN_MIN_VER} (build number ${gn_min_ver_num}) is required to build this Chromium"
		fi
	fi

	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unpack ${P}-linux.tar.xz
	unpack chromium-patches-${PATCH_V}.tar.bz2

	use pgo && unpack chromium-profiler-0.2.tar

	if use test; then
		unpack ${P}-linux-testdata.tar.xz
		local testfonts_dir="${WORKDIR}/${P}/third_party/test_fonts"
		local testfonts_tar="${DISTDIR}/chromium-testfonts-${TEST_FONT:0:10}.tar.gz"
		tar xf "${testfonts_tar}" -C "${testfonts_dir}" || die "Failed to unpack testfonts"
	fi

	if use ppc64; then
		unpack chromium-openpower-${PPC64_HASH:0:10}.tar.bz2
	fi
}

src_prepare() {
	python_setup

	local PATCHES=(
		"${FILESDIR}/chromium-cross-compile.patch"
		"${FILESDIR}/chromium-109-system-zlib.patch"
		"${FILESDIR}/chromium-111-InkDropHost-crash.patch"
		"${FILESDIR}/chromium-131-unbundle-icu-target.patch"
		"${FILESDIR}/chromium-134-bindgen-custom-toolchain.patch"
		"${FILESDIR}/chromium-135-oauth2-client-switches.patch"
		"${FILESDIR}/chromium-135-map_droppable-glibc.patch"
		"${FILESDIR}/chromium-136-drop-nodejs-ver-check.patch"
		"${FILESDIR}/chromium-137-openh264-include-path.patch"
		"${FILESDIR}/chromium-137-pdfium-system-libpng.patch"
	)

	shopt -s globstar nullglob
	local patch
	for patch in "${WORKDIR}/chromium-patches-${PATCH_V}"/**/*.patch; do
		if [[ ${patch} == *"ppc64le"* ]]; then
			use ppc64 && PATCHES+=( "${patch}" )
		else
			PATCHES+=( "${patch}" )
		fi
	done
	shopt -u globstar nullglob

	local builtins_match="if (is_clang && !is_nacl && !is_cronet_build) {"
	grep -q "${builtins_match}" build/config/compiler/BUILD.gn || die "Failed to disable bundled compiler builtins"
	sed -i -e "/${builtins_match}/,+2d" build/config/compiler/BUILD.gn

	if use ppc64; then
		local patchset_dir="${WORKDIR}/openpower-patches-${PPC64_HASH}/patches"
		local page_size_patch="ppc64le/third_party/use-sysconf-page-size-on-ppc64.patch"
		local isa_3_patch="ppc64le/core/baseline-isa-3-0.patch"
		openpower_patches=( $(grep -E "^ppc64le|^upstream" "${patchset_dir}/series" | grep -v "${page_size_patch}" |
			grep -v "${isa_3_patch}" || die) )
		for patch in "${openpower_patches[@]}"; do
			PATCHES+=( "${patchset_dir}/${patch}" )
		done
		if [[ $(getconf PAGESIZE) == 65536 ]]; then
			PATCHES+=( "${patchset_dir}/${page_size_patch}" )
		fi
		if use cpu_flags_ppc_vsx3 ; then
			PATCHES+=( "${patchset_dir}/${isa_3_patch}" )
		fi
	fi

	if [[ "${RUST_SLOT}" < "1.83.0" ]]; then
		sed '/rustflags = \[ "-Zdefault-visibility=hidden" \]/d' -i build/config/gcc/BUILD.gn ||
			die "Failed to remove default visibility nightly option"
	fi

	if [[ "${RUST_SLOT}" < "1.86.0" ]]; then
		sed -i 's/adler2/adler/' build/rust/std/BUILD.gn ||
			die "Failed to tell GN that we have adler and not adler2"
	fi

	default

	if [[ -f third_party/node/linux/node-linux-x64/bin/node ]]; then
		rm third_party/node/linux/node-linux-x64/bin/node || die
	else
		mkdir -p third_party/node/linux/node-linux-x64/bin || die
	fi
	ln -s "${EPREFIX}"/usr/bin/node third_party/node/linux/node-linux-x64/bin/node || die

	sed -i -e "s|\(^script_executable = \).*|\1\"${EPYTHON}\"|g" .gn || die

	local keeplibs=(
		base/third_party/cityhash
		base/third_party/double_conversion
		base/third_party/icu
		base/third_party/nspr
		base/third_party/superfasthash
		base/third_party/symbolize
		base/third_party/xdg_user_dirs
		buildtools/third_party/libc++
		buildtools/third_party/libc++abi
		chrome/third_party/mozilla_security_manager
		net/third_party/mozilla_security_manager
		net/third_party/nss
		net/third_party/quic
		net/third_party/uri_template
		third_party/abseil-cpp
		third_party/angle
		third_party/angle/src/common/third_party/xxhash
		third_party/angle/src/third_party/ceval
		third_party/angle/src/third_party/libXNVCtrl
		third_party/angle/src/third_party/volk
		third_party/anonymous_tokens
		third_party/apple_apsl
		third_party/axe-core
		third_party/bidimapper
		third_party/blink
		third_party/boringssl
		third_party/boringssl/src/third_party/fiat
		third_party/breakpad
		third_party/breakpad/breakpad/src/third_party/curl
		third_party/brotli
		third_party/catapult
		third_party/catapult/common/py_vulcanize/third_party/rcssmin
		third_party/catapult/common/py_vulcanize/third_party/rjsmin
		third_party/catapult/third_party/beautifulsoup4-4.9.3
		third_party/catapult/third_party/html5lib-1.1
		third_party/catapult/third_party/polymer
		third_party/catapult/third_party/six
		third_party/catapult/tracing/third_party/d3
		third_party/catapult/tracing/third_party/gl-matrix
		third_party/catapult/tracing/third_party/jpeg-js
		third_party/catapult/tracing/third_party/jszip
		third_party/catapult/tracing/third_party/mannwhitneyu
		third_party/catapult/tracing/third_party/oboe
		third_party/catapult/tracing/third_party/pako
		third_party/ced
		third_party/cld_3
		third_party/closure_compiler
		third_party/compiler-rt
		third_party/content_analysis_sdk
		third_party/cpuinfo
		third_party/crabbyavif
		third_party/crashpad
		third_party/crashpad/crashpad/third_party/lss
		third_party/crashpad/crashpad/third_party/zlib
		third_party/crc32c
		third_party/cros_system_api
		third_party/d3
		third_party/dav1d
		third_party/dawn
		third_party/dawn/third_party/gn/webgpu-cts
		third_party/dawn/third_party/khronos
		third_party/depot_tools
		third_party/devscripts
		third_party/devtools-frontend
		third_party/devtools-frontend/src/front_end/third_party/acorn
		third_party/devtools-frontend/src/front_end/third_party/additional_readme_paths.json
		third_party/devtools-frontend/src/front_end/third_party/axe-core
		third_party/devtools-frontend/src/front_end/third_party/chromium
		third_party/devtools-frontend/src/front_end/third_party/codemirror
		third_party/devtools-frontend/src/front_end/third_party/csp_evaluator
		third_party/devtools-frontend/src/front_end/third_party/diff
		third_party/devtools-frontend/src/front_end/third_party/i18n
		third_party/devtools-frontend/src/front_end/third_party/intl-messageformat
		third_party/devtools-frontend/src/front_end/third_party/json5
		third_party/devtools-frontend/src/front_end/third_party/legacy-javascript
		third_party/devtools-frontend/src/front_end/third_party/lighthouse
		third_party/devtools-frontend/src/front_end/third_party/lit
		third_party/devtools-frontend/src/front_end/third_party/marked
		third_party/devtools-frontend/src/front_end/third_party/puppeteer
		third_party/devtools-frontend/src/front_end/third_party/puppeteer/package/lib/esm/third_party/mitt
		third_party/devtools-frontend/src/front_end/third_party/puppeteer/package/lib/esm/third_party/parsel-js
		third_party/devtools-frontend/src/front_end/third_party/puppeteer/package/lib/esm/third_party/rxjs
		third_party/devtools-frontend/src/front_end/third_party/third-party-web
		third_party/devtools-frontend/src/front_end/third_party/vscode.web-custom-data
		third_party/devtools-frontend/src/front_end/third_party/wasmparser
		third_party/devtools-frontend/src/front_end/third_party/web-vitals
		third_party/devtools-frontend/src/third_party
		third_party/distributed_point_functions
		third_party/dom_distiller_js
		third_party/eigen3
		third_party/emoji-segmenter
		third_party/farmhash
		third_party/fast_float
		third_party/fdlibm
		third_party/fft2d
		third_party/flatbuffers
		third_party/fp16
		third_party/freetype
		third_party/fusejs
		third_party/fxdiv
		third_party/gemmlowp
		third_party/google_input_tools
		third_party/google_input_tools/third_party/closure_library
		third_party/google_input_tools/third_party/closure_library/third_party/closure
		third_party/googletest
		third_party/highway
		third_party/hunspell
		third_party/ink_stroke_modeler/src/ink_stroke_modeler
		third_party/ink_stroke_modeler/src/ink_stroke_modeler/internal
		third_party/ink/src/ink/brush
		third_party/ink/src/ink/color
		third_party/ink/src/ink/geometry
		third_party/ink/src/ink/rendering
		third_party/ink/src/ink/rendering/skia/common_internal
		third_party/ink/src/ink/rendering/skia/native
		third_party/ink/src/ink/rendering/skia/native/internal
		third_party/ink/src/ink/strokes
		third_party/ink/src/ink/types
		third_party/inspector_protocol
		third_party/ipcz
		third_party/jinja2
		third_party/jsoncpp
		third_party/khronos
		third_party/lens_server_proto
		third_party/leveldatabase
		third_party/libaddressinput
		third_party/libaom
		third_party/libaom/source/libaom/third_party/fastfeat
		third_party/libaom/source/libaom/third_party/SVT-AV1
		third_party/libaom/source/libaom/third_party/vector
		third_party/libaom/source/libaom/third_party/x86inc
		third_party/libc++
		third_party/libdrm
		third_party/libgav1
		third_party/libjingle
		third_party/libphonenumber
		third_party/libsecret
		third_party/libsrtp
		third_party/libsync
		third_party/libtess2/libtess2
		third_party/libtess2/src/Include
		third_party/libtess2/src/Source
		third_party/liburlpattern
		third_party/libva_protected_content
		third_party/libvpx
		third_party/libvpx/source/libvpx/third_party/x86inc
		third_party/libwebm
		third_party/libx11
		third_party/libxcb-keysyms
		third_party/libxml/chromium
		third_party/libyuv
		third_party/libzip
		third_party/lit
		third_party/llvm-libc
		third_party/llvm-libc/src/shared/
		third_party/lottie
		third_party/lss
		third_party/lzma_sdk
		third_party/mako
		third_party/markupsafe
		third_party/material_color_utilities
		third_party/mesa
		third_party/metrics_proto
		third_party/minigbm
		third_party/modp_b64
		third_party/nasm
		third_party/nearby
		third_party/neon_2_sse
		third_party/node
		third_party/omnibox_proto
		third_party/one_euro_filter
		third_party/openscreen
		third_party/openscreen/src/third_party/
		third_party/openscreen/src/third_party/tinycbor/src/src
		third_party/opus
		third_party/ots
		third_party/pdfium
		third_party/pdfium/third_party/agg23
		third_party/pdfium/third_party/bigint
		third_party/pdfium/third_party/freetype
		third_party/pdfium/third_party/lcms
		third_party/pdfium/third_party/libopenjpeg
		third_party/pdfium/third_party/libtiff
		third_party/perfetto
		third_party/perfetto/protos/third_party/chromium
		third_party/perfetto/protos/third_party/simpleperf
		third_party/pffft
		third_party/ply
		third_party/polymer
		third_party/private_membership
		third_party/private-join-and-compute
		third_party/protobuf
		third_party/protobuf/third_party/utf8_range
		third_party/pthreadpool
		third_party/puffin
		third_party/pyjson5
		third_party/pyyaml
		third_party/rapidhash
		third_party/re2
		third_party/rnnoise
		third_party/rust
		third_party/rust/cxx
		third_party/s2cellid
		third_party/securemessage
		third_party/selenium-atoms
		third_party/sentencepiece
		third_party/sentencepiece/src/third_party/darts_clone
		third_party/shell-encryption
		third_party/simdutf
		third_party/simplejson
		third_party/six
		third_party/skia
		third_party/skia/include/third_party/vulkan
		third_party/skia/third_party/vulkan
		third_party/smhasher
		third_party/snappy
		third_party/spirv-headers
		third_party/spirv-tools
		third_party/sqlite
		third_party/swiftshader
		third_party/swiftshader/third_party/astc-encoder
		third_party/swiftshader/third_party/llvm-subzero
		third_party/swiftshader/third_party/marl
		third_party/swiftshader/third_party/SPIRV-Headers/include/spirv
		third_party/swiftshader/third_party/SPIRV-Tools
		third_party/tensorflow_models
		third_party/tensorflow-text
		third_party/tflite
		third_party/tflite/src/third_party/eigen3
		third_party/tflite/src/third_party/fft2d
		third_party/tflite/src/third_party/xla/third_party/tsl
		third_party/tflite/src/third_party/xla/xla/tsl/framework
		third_party/tflite/src/third_party/xla/xla/tsl/lib/random
		third_party/tflite/src/third_party/xla/xla/tsl/protobuf
		third_party/tflite/src/third_party/xla/xla/tsl/util
		third_party/ukey2
		third_party/utf
		third_party/vulkan
		third_party/wasm_tts_engine
		third_party/wayland
		third_party/webdriver
		third_party/webgpu-cts
		third_party/webrtc
		third_party/webrtc/common_audio/third_party/ooura
		third_party/webrtc/common_audio/third_party/spl_sqrt_floor
		third_party/webrtc/modules/third_party/fft
		third_party/webrtc/modules/third_party/g711
		third_party/webrtc/modules/third_party/g722
		third_party/webrtc/rtc_base/third_party/base64
		third_party/webrtc/rtc_base/third_party/sigslot
		third_party/widevine
		third_party/woff2
		third_party/wuffs
		third_party/x11proto
		third_party/xcbproto
		third_party/xnnpack
		third_party/zlib/google
		third_party/zxcvbn-cpp
		url/third_party/mozilla
		v8/third_party/siphash
		v8/third_party/utf8-decoder
		v8/third_party/glibc
		v8/third_party/inspector_protocol
		v8/third_party/rapidhash-v8
		v8/third_party/v8
		v8/third_party/valgrind
		third_party/speech-dispatcher
		third_party/usb_ids
		third_party/xdg-utils
	)

	if use rar; then
		keeplibs+=( third_party/unrar )
	fi

	if use test; then
		keeplibs+=(
			third_party/breakpad/breakpad/src/processor
			third_party/fuzztest
			third_party/google_benchmark/src/include/benchmark
			third_party/google_benchmark/src/src
			third_party/perfetto/protos/third_party/pprof
			third_party/test_fonts
			third_party/test_fonts/fontconfig
		)
	fi

	if ! use system-harfbuzz; then
		keeplibs+=( third_party/harfbuzz-ng )
	fi

	if ! use system-icu; then
		keeplibs+=( third_party/icu )
	fi

	if ! use system-png; then
		keeplibs+=( third_party/libpng )
	fi

	if ! use system-zstd; then
		keeplibs+=( third_party/zstd )
	fi

	if use arm64 || use ppc64 ; then
		keeplibs+=( third_party/swiftshader/third_party/llvm-10.0 )
	fi

	if use ppc64; then
		pushd third_party/libvpx >/dev/null || die
		mkdir -p source/config/linux/ppc64 || die
		sed -i -e "s|^update_readme||g; s|clang-format|${EPREFIX}/bin/true|g; /^git -C/d; /git cl/d; /cd \$BASE_DIR\/\$LIBVPX_SRC_DIR/ign format --in-place \$BASE_DIR\/BUILD.gn\ngn format --in-place \$BASE_DIR\/libvpx_srcs.gni" \
			generate_gni.sh || die
		./generate_gni.sh || die
		popd >/dev/null || die

		pushd third_party/ffmpeg >/dev/null || die
		cp libavcodec/ppc/h264dsp.c libavcodec/ppc/h264dsp_ppc.c || die
		cp libavcodec/ppc/h264qpel.c libavcodec/ppc/h264qpel_ppc.c || die
		popd >/dev/null || die
	fi

	whitelist_libs=(
		net/third_party/quic
		third_party/devtools-frontend/src/front_end/third_party/additional_readme_paths.json
		third_party/libjingle
		third_party/mesa
		third_party/skia/third_party/vulkan
		third_party/vulkan
	)
	local not_found_libs=()
	for lib in "${keeplibs[@]}"; do
		if [[ ! -d "${lib}" ]] && ! has "${lib}" "${whitelist_libs[@]}"; then
			not_found_libs+=( "${lib}" )
		fi
	done

	if [[ ${#not_found_libs[@]} -gt 0 ]]; then
		eerror "The following \`keeplibs\` directories were not found in the source tree:"
		for lib in "${not_found_libs[@]}"; do
			eerror "  ${lib}"
		done
		die "Please update the ebuild."
	fi

	einfo "Unbundling third-party libraries ..."
	build/linux/unbundle/remove_bundled_libraries.py "${keeplibs[@]}" --do-remove || die

	mkdir -p buildtools/third_party/eu-strip/bin || die
	ln -s "${EPREFIX}"/bin/true buildtools/third_party/eu-strip/bin/eu-strip || die
}

chromium_configure() {
	python_setup

	export TMPDIR="${WORKDIR}/temp"
	mkdir -p -m 755 "${TMPDIR}" || die

	addpredict /dev/dri/

	local gn_system_libraries=(
		flac
		fontconfig
		freetype
		libjpeg
		libwebp
		libxml
		libxslt
		openh264
		zlib
	)
	if use system-icu; then
		gn_system_libraries+=( icu )
	fi
	if use system-png; then
		gn_system_libraries+=( libpng )
	fi
	if use system-zstd; then
		gn_system_libraries+=( zstd )
	fi

	build/linux/unbundle/replace_gn_files.py --system-libraries "${gn_system_libraries[@]}" ||
		die "Failed to replace GN files for system libraries"

	local freetype_gni="build/config/freetype/freetype.gni"
	sed -i -e '$d' ${freetype_gni} || die
	echo "  enable_freetype = true" >> ${freetype_gni} || die
	echo "}" >> ${freetype_gni} || die

	if use !custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags
		filter-flags "-g*"
	fi

	append-flags -Wno-unknown-warning-option
	if tc-is-cross-compiler; then
		export BUILD_CXXFLAGS+=" -Wno-unknown-warning-option"
		export BUILD_CFLAGS+=" -Wno-unknown-warning-option"
	fi

	local myconf_gn=()

	if tc-is-cross-compiler; then
		CC="${CC} -target ${CHOST} --sysroot ${ESYSROOT}"
		CXX="${CXX} -target ${CHOST} --sysroot ${ESYSROOT}"
		BUILD_AR=${AR}
		BUILD_CC=${CC}
		BUILD_CXX=${CXX}
		BUILD_NM=${NM}
	fi

	tc-export AR CC CXX NM

	strip-unsupported-flags
	append-ldflags -Wl,--undefined-version

	myconf_gn+=(
		"is_clang=true"
		"clang_use_chrome_plugins=false"
		"use_lld=true"
		'custom_toolchain="//build/toolchain/linux/unbundle:default"'
		"bindgen_libclang_path=\"/usr/lib/llvm/16/lib64\""
		"clang_base_path=\"/usr/lib/llvm/16/\""
		"rust_bindgen_root=\"/usr/\""
		"rust_sysroot_absolute=\"/usr/\""
		"rustc_version=\"${RUST_SLOT}\""
	)

	if ! tc-is-cross-compiler; then
		myconf_gn+=( 'host_toolchain="//build/toolchain/linux/unbundle:default"' )
	else
		tc-export BUILD_{AR,CC,CXX,NM}
		myconf_gn+=(
			'host_toolchain="//build/toolchain/linux/unbundle:host"'
			'v8_snapshot_toolchain="//build/toolchain/linux/unbundle:host"'
			"host_pkg_config=$(tc-getBUILD_PKG_CONFIG)"
			"pkg_config=$(tc-getPKG_CONFIG)"
		)

		if use cups; then
			mkdir "${T}/cups-config" || die
			cp "${ESYSROOT}/usr/bin/${CHOST}-cups-config" "${T}/cups-config/cups-config" || die
			export PATH="${PATH}:${T}/cups-config"
		fi

		local -x PKG_CONFIG_PATH=
	fi


local myarch
myarch="$(tc-arch)"
case ${myarch} in
    amd64)
        use !custom-cflags && filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 \
                                    -mno-avx -mno-avx2 -mno-fma -mno-fma4 -mno-xop -mno-sse4a
        myconf_gn+=( 'target_cpu="x64"' )
        ;;
    arm64)
        myconf_gn+=( 'target_cpu="arm64"' )
        use !custom-cflags && filter-flags -mno-neon
        ;;
    ppc64)
        myconf_gn+=( 'target_cpu="ppc64"' )
        ;;
    *)
        die "Failed to determine target arch, got '${myarch}'."
        ;;
esac

	myconf_gn+=(
		"blink_enable_generated_code_formatting=false"
		"dcheck_always_on=$(usex debug true false)"
		"dcheck_is_configurable=$(usex debug true false)"
		"disable_fieldtrial_testing_config=true"
		"enable_freetype=true"
		"enable_hangout_services_extension=$(usex hangouts true false)"
		"enable_nacl=false"
		"enable_nocompile_tests=false"
		"enable_pseudolocales=false"
		"enable_widevine=$(usex widevine true false)"
		"fatal_linker_warnings=false"
		'google_api_key="AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc"'
		"is_component_build=false"
		"is_debug=false"
		"is_official_build=$(usex official true false)"
		"ozone_auto_platforms=false"
		"ozone_platform_headless=true"
		"safe_browsing_use_unrar=$(usex rar true false)"
		"thin_lto_enable_optimizations=${use_lto}"
		"treat_warnings_as_errors=false"
		"use_custom_libcxx=true"
		"use_ozone=true"
		"use_sysroot=false"
		"use_system_harfbuzz=$(usex system-harfbuzz true false)"
		"use_system_libdrm=false"
		"use_thin_lto=${use_lto}"
		"v8_use_libm_trig_functions=true"
	)

	if use bindist ; then
		myconf_gn+=(
			"proprietary_codecs=true"
			'ffmpeg_branding="Chrome"'
			"is_component_ffmpeg=true"
		)
	else
		myconf_gn+=(
			"proprietary_codecs=$(usex proprietary-codecs true false)"
			"ffmpeg_branding=\"$(usex proprietary-codecs Chrome Chromium)\""
		)
	fi

	if use headless; then
		myconf_gn+=(
			"enable_print_preview=false"
			"enable_remoting=false"
			'ozone_platform="headless"'
			"rtc_use_pipewire=false"
			"use_alsa=false"
			"use_cups=false"
			"use_gio=false"
			"use_glib=false"
			"use_gtk=false"
			"use_kerberos=false"
			"use_libpci=false"
			"use_pangocairo=false"
			"use_pulseaudio=false"
			"use_qt5=false"
			"use_qt6=false"
			"use_udev=false"
			"use_vaapi=false"
			"use_xkbcommon=false"
		)
	else
		myconf_gn+=(
			"gtk_version=$(usex gtk4 4 3)"
			"link_pulseaudio=$(usex pulseaudio true false)"
			"ozone_platform_wayland=$(usex wayland true false)"
			"ozone_platform_x11=$(usex X true false)"
			"ozone_platform=\"$(usex wayland wayland x11)\""
			"rtc_use_pipewire=$(usex screencast true false)"
			"use_cups=$(usex cups true false)"
			"use_kerberos=$(usex kerberos true false)"
			"use_pulseaudio=$(usex pulseaudio true false)"
			"use_qt5=false"
			"use_system_minigbm=true"
			"use_vaapi=$(usex vaapi true false)"
			"use_xkbcommon=true"
		)
		if use qt6; then
			local cbuild_libdir
			cbuild_libdir="$(get_libdir)"
			if tc-is-cross-compiler; then
				cbuild_libdir="$($(tc-getBUILD_PKG_CONFIG) --keep-system-libs --libs-only-L libxslt)"
				cbuild_libdir="${cbuild_libdir:2}"
				cbuild_libdir="${cbuild_libdir/% }"
			fi
			myconf_gn+=(
				"use_qt6=true"
				"moc_qt6_path=\"${EPREFIX}/usr/${cbuild_libdir}/qt6/libexec\""
			)
		else
			myconf_gn+=( "use_qt6=false" )
		fi
	fi

	if use system-icu || use headless; then
		myconf_gn+=( "icu_use_data_file=false" )
	fi

	if use official; then
		sed -i 's/OFFICIAL_BUILD/GOOGLE_CHROME_BUILD/' \
			tools/generate_shim_headers/generate_shim_headers.py || die
		if use !ppc64; then
			myconf_gn+=( "is_cfi=${use_lto}" )
		else
			myconf_gn+=( "is_cfi=false" )
		fi
		myconf_gn+=( "symbol_level=0" )
	fi

	if use pgo; then
		myconf_gn+=( "chrome_pgo_phase=${1}" )
		if [[ "$1" == "2" ]]; then
			myconf_gn+=( "pgo_data_path=${2}" )
		fi
	else
		myconf_gn+=( "chrome_pgo_phase=0" )
	fi

	if ! use amd64; then
		myconf_gn+=( "devtools_skip_typecheck=false" )
	fi

	if tc-is-cross-compiler && use ppc64; then
		myconf_gn+=( "v8_enable_external_code_space=false" )
	fi

	einfo "Configuring Chromium ..."
	set -- gn gen --args="${myconf_gn[*]}${EXTRA_GN:+ ${EXTRA_GN}}" out/Release
	echo "$@"
	"$@" || die
}

src_configure() {
	chromium_configure $(usex pgo 1 0)
}

chromium_compile() {
	ulimit -n 2048

	python_setup

	local -x PYTHONPATH=

	if use pax-kernel; then
		local x
		for x in mksnapshot v8_context_snapshot_generator; do
			if tc-is-cross-compiler; then
				eninja -C out/Release "host/${x}"
				pax-mark m "out/Release/host/${x}"
			else
				eninja -C out/Release "${x}"
				pax-mark m "out/Release/${x}"
			fi
		done
	fi

	eninja -C out/Release chrome chromedriver chrome_sandbox $(use test && echo "base_unittests")

	pax-mark m out/Release/chrome

	QA_FLAGS_IGNORED="
		usr/lib64/chromium-browser/chrome
		usr/lib64/chromium-browser/chrome-sandbox
		usr/lib64/chromium-browser/chromedriver
		usr/lib64/chromium-browser/chrome_crashpad_handler
		usr/lib64/chromium-browser/libEGL.so
		usr/lib64/chromium-browser/libGLESv2.so
		usr/lib64/chromium-browser/libVkICD_mock_icd.so
		usr/lib64/chromium-browser/libVkLayer_khronos_validation.so
		usr/lib64/chromium-browser/libqt6_shim.so
		usr/lib64/chromium-browser/libvk_swiftshader.so
		usr/lib64/chromium-browser/libvulkan.so.1
	"
}

chromium_profile() {
	einfo "Profiling for PGO"

	pushd "${WORKDIR}/chromium-profiler-"* >/dev/null || return 1

	rm -rf "${1}" || return 1

	if ! "${EPYTHON}" ./chromium_profiler.py \
		--chrome-executable "${S}/out/Release/chrome" \
		--chromedriver-executable "${S}/out/Release/chromedriver.unstripped" \
		--add-arg no-sandbox --add-arg disable-dev-shm-usage \
		--profile-output "${1}"; then
		eerror "Profiling failed"
		return 1
	fi

	popd >/dev/null || return 1
}

src_compile() {
	if use pgo; then
		local profdata

		profdata="${WORKDIR}/chromium.profdata"

		if [[ ! -e "${WORKDIR}/.pgo-profiled" ]]; then
			chromium_compile
			virtx chromium_profile "$profdata"

			touch "${WORKDIR}/.pgo-profiled" || die
		fi

		if [[ ! -e "${WORKDIR}/.pgo-phase-2-configured" ]]; then
			rm -r out/Release || die

			chromium_configure 2 "$profdata"

			touch "${WORKDIR}/.pgo-phase-2-configured" || die
		fi

		if [[ ! -e "${WORKDIR}/.pgo-phase-2-compiled" ]]; then
			chromium_compile
			touch "${WORKDIR}/.pgo-phase-2-compiled" || die
		fi
	else
		chromium_compile
	fi

	mv out/Release/chromedriver{.unstripped,} || die

	rm -f out/Release/locales/*.pak.info || die

	sed -e 's|@@PACKAGE@@|chromium-browser|g;
		s|@@MENUNAME@@|Chromium|g;' \
		chrome/app/resources/manpage.1.in > \
		out/Release/chromium-browser.1 || die

	sed -e 's|@@MENUNAME@@|Chromium|g;
		s|@@USR_BIN_SYMLINK_NAME@@|chromium-browser|g;
		s|@@PACKAGE@@|chromium-browser|g;
		s|\(^Exec=\)/usr/bin/|\1|g;' \
		chrome/installer/linux/common/desktop.template > \
		out/Release/chromium-browser-chromium.desktop || die

	sed -e 's|${ICD_LIBRARY_PATH}|./libvk_swiftshader.so|g' \
		third_party/swiftshader/src/Vulkan/vk_swiftshader_icd.json.tmpl > \
		out/Release/vk_swiftshader_icd.json || die
}

src_test() {
	local skip_tests=(
		'MessagePumpLibeventTest.NestedNotification*'
		ClampTest.Death
		OptionalTest.DereferencingNoValueCrashes
		PlatformThreadTest.SetCurrentThreadTypeTest
		RawPtrTest.TrivialRelocability
		SafeNumerics.IntMaxOperations
		StackTraceTest.TraceStackFramePointersFromBuffer
		StringPieceTest.InvalidLengthDeath
		StringPieceTest.OutOfBoundsDeath
		ThreadPoolEnvironmentConfig.CanUseBackgroundPriorityForWorker
		ValuesUtilTest.FilePath
		AlternateTestParams/PartitionAllocDeathTest.RepeatedAllocReturnNullDirect/0
		AlternateTestParams/PartitionAllocDeathTest.RepeatedAllocReturnNullDirect/1
		AlternateTestParams/PartitionAllocDeathTest.RepeatedAllocReturnNullDirect/2
		AlternateTestParams/PartitionAllocDeathTest.RepeatedAllocReturnNullDirect/3
		AlternateTestParams/PartitionAllocDeathTest.RepeatedReallocReturnNullDirect/0
		AlternateTestParams/PartitionAllocDeathTest.RepeatedReallocReturnNullDirect/1
		AlternateTestParams/PartitionAllocDeathTest.RepeatedReallocReturnNullDirect/2
		AlternateTestParams/PartitionAllocDeathTest.RepeatedReallocReturnNullDirect/3
		CharacterEncodingTest.GetCanonicalEncodingNameByAliasName
		CheckExitCodeAfterSignalHandlerDeathTest.CheckSIGFPE
		CheckExitCodeAfterSignalHandlerDeathTest.CheckSIGILL
		CheckExitCodeAfterSignalHandlerDeathTest.CheckSIGSEGV
		CheckExitCodeAfterSignalHandlerDeathTest.CheckSIGSEGVNonCanonicalAddress
		FilePathTest.FromUTF8Unsafe_And_AsUTF8Unsafe
		FileTest.GetInfoForCreationTime
		ICUStringConversionsTest.ConvertToUtf8AndNormalize
		NumberFormattingTest.FormatPercent
		PathServiceTest.CheckedGetFailure
		PlatformThreadTest.CanChangeThreadType
		RustLogIntegrationTest.CheckAllSeverity
		StackCanary.ChangingStackCanaryCrashesOnReturn
		StackTraceDeathTest.StackDumpSignalHandlerIsMallocFree
		SysStrings.SysNativeMBAndWide
		SysStrings.SysNativeMBToWide
		SysStrings.SysWideToNativeMB
		TestLauncherTools.TruncateSnippetFocusedMatchesFatalMessagesTest
		ToolsSanityTest.BadVirtualCallNull
		ToolsSanityTest.BadVirtualCallWrongType
		CancelableEventTest.BothCancelFailureAndSucceedOccurUnderContention
		DriveInfoTest.GetFileDriveInfo
	)
	local test_filter="-$(IFS=:; printf '%s' "${skip_tests[*]}")"
	./out/Release/base_unittests --test-launcher-bot-mode \
		--test-launcher-jobs="$(makeopts_jobs)" \
		--gtest_filter="${test_filter}" || die "Tests failed!"
}

src_install() {
	local CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser"
	exeinto "${CHROMIUM_HOME}"
	doexe out/Release/chrome

	newexe out/Release/chrome_sandbox chrome-sandbox
	fperms 4755 "${CHROMIUM_HOME}/chrome-sandbox"

	doexe out/Release/chromedriver
	doexe out/Release/chrome_crashpad_handler

	ozone_auto_session () {
		use X && use wayland && ! use headless && echo true || echo false
	}
	local sedargs=( -e
			"s:/usr/lib/:/usr/$(get_libdir)/:g;
			s:@@OZONE_AUTO_SESSION@@:$(ozone_auto_session):g"
	)
	sed "${sedargs[@]}" "${FILESDIR}/chromium-launcher-r7.sh" > chromium-launcher.sh || die
	doexe chromium-launcher.sh

	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium
	dosym "${CHROMIUM_HOME}/chromedriver" /usr/bin/chromedriver

	insinto /etc/chromium
	newins "${FILESDIR}/chromium.default" "default"

	pushd out/Release/locales > /dev/null || die
	chromium_remove_language_paks
	popd

	insinto "${CHROMIUM_HOME}"
	doins out/Release/*.bin
	doins out/Release/*.pak

	if use bindist; then
		rm -f out/Release/libffmpeg.so \
			|| die "Failed to remove bundled libffmpeg.so (with proprietary codecs)"
		einfo "Creating symlink to libffmpeg.so from $(usex ffmpeg-chromium ffmpeg-chromium ffmpeg[chromium])..."
		dosym ../chromium/libffmpeg.so$(usex ffmpeg-chromium .${PV%%\.*} "") \
			/usr/$(get_libdir)/chromium-browser/libffmpeg.so
	fi

	(
		shopt -s nullglob
		local files=(out/Release/*.so out/Release/*.so.[0-9])
		[[ ${#files[@]} -gt 0 ]] && doins "${files[@]}"
	)

	doins out/Release/xdg-{settings,mime}

	if ! use system-icu && ! use headless; then
		doins out/Release/icudtl.dat
	fi

	doins -r out/Release/locales
	doins -r out/Release/MEIPreload

	doins out/Release/vk_swiftshader_icd.json

	if [[ -d out/Release/swiftshader ]]; then
		insinto "${CHROMIUM_HOME}/swiftshader"
		doins out/Release/swiftshader/*.so
	fi

	local branding size
	for size in 16 24 32 48 64 128 256 ; do
		case ${size} in
			16|32) branding="chrome/app/theme/default_100_percent/chromium" ;;
				*) branding="chrome/app/theme/chromium" ;;
		esac
		newicon -s ${size} "${branding}/product_logo_${size}.png" \
			chromium-browser.png
	done

	domenu out/Release/chromium-browser-chromium.desktop

	insinto /usr/share/gnome-control-center/default-apps
	newins "${FILESDIR}"/chromium-browser.xml chromium-browser.xml

	doman out/Release/chromium-browser.1
	dosym chromium-browser.1 /usr/share/man/man1/chromium.1

	readme.gentoo_create_doc
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	readme.gentoo_print_elog

	if ! use headless; then
		if use vaapi; then
			elog "Hardware-accelerated video decoding configuration:"
			elog
			elog "Chromium supports multiple backends for hardware acceleration. To enable one,"
			elog "   Add to CHROMIUM_FLAGS in /etc/chromium/default:"
			elog
			elog "1. VA-API with OpenGL (recommended for most users):"
			elog "   --enable-features=AcceleratedVideoDecodeLinuxGL"
			elog "   VaapiVideoDecoder may need to be added as well, but try without first."
			elog
			if use wayland; then
				elog "2. Enhanced Wayland/EGL performance:"
				elog "   --enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL"
				elog
			fi
			if use X; then
				elog "$(usex wayland "3" "2"). VA-API with Vulkan:"
				elog "   --enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
				elog
				if use wayland; then
					elog "   NOTE: Vulkan acceleration requires X11 and will not work under Wayland sessions."
					elog "   Use OpenGL-based acceleration instead when running under Wayland."
					elog
				fi
			fi
			elog "Additional options:"
			elog "  To enable hardware-accelerated encoding (if supported)"
			elog "  add 'AcceleratedVideoEncoder' to your feature list"
			elog "  VaapiIgnoreDriverChecks bypasses driver compatibility checks"
			elog "  (may be needed for newer/unsupported hardware)"
			elog
		else
			elog "This Chromium build was compiled without VA-API support, which provides"
			elog "hardware-accelerated rendering, including video decoding."
		fi
		if use screencast; then
			elog "Screencast is disabled by default at runtime. Either enable it"
			elog "by navigating to chrome://flags/#enable-webrtc-pipewire-capturer"
			elog "inside Chromium or add --enable-features=WebRTCPipeWireCapturer"
			elog "to CHROMIUM_FLAGS in /etc/chromium/default."
		fi
		if use gtk4; then
			elog "Chromium prefers GTK3 over GTK4 at runtime. To override this"
			elog "behavior you need to pass --gtk-version=4, e.g. by adding it"
			elog "to CHROMIUM_FLAGS in /etc/chromium/default."
		fi
	fi

	if systemd_is_booted && ! [[ -f "/etc/machine-id" ]]; then
		ewarn "The lack of an '/etc/machine-id' file on this system booted with systemd"
		ewarn "indicates that the Gentoo handbook was not followed to completion."
		ewarn ""
		ewarn "Chromium is known to behave unpredictably with this system configuration;"
		ewarn "please complete the configuration of this system before logging any bugs."
	fi
}
