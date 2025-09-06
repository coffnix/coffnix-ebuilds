# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs multilib-minimal

FFMPEG_SOC_PATCH=ffmpeg-rpi-7.1.1.patch
FFMPEG_SUBSLOT=59.61.61

inherit verify-sig
SRC_URI="
	https://ffmpeg.org/releases/ffmpeg-${PV}.tar.xz
	verify-sig? ( https://ffmpeg.org/releases/ffmpeg-${PV}.tar.xz.asc )
	${FFMPEG_SOC_PATCH:+"
		soc? ( https://dev.gentoo.org/~chewi/distfiles/${FFMPEG_SOC_PATCH} )
	"}
	https://dev.gentoo.org/~ionen/distfiles/ffmpeg-$(ver_cut 1-2)-patchset-1.tar.xz
"
S=${WORKDIR}/ffmpeg-${PV}
KEYWORDS="*"

DESCRIPTION="Complete solution to record/convert/stream audio and video"
HOMEPAGE="
	https://ffmpeg.org/
	https://code.ffmpeg.org/FFmpeg/FFmpeg/
"

[[ ${PN} == *-compat ]] && FFMPEG_UNSLOTTED= || FFMPEG_UNSLOTTED=1

FFMPEG_IUSE_MAP=(
	X:libxcb,libxcb-shape,libxcb-shm,libxcb-xfixes,xlib
	alsa
	amf
	amrenc:libvo-amrwbenc@v3
	amr:libopencore-amrnb,libopencore-amrwb@v3
	appkit
	bluray:libbluray
	bs2b:libbs2b
	bzip2:bzlib
	cdio:libcdio
	chromaprint
	codec2:libcodec2
	cuda:cuda-llvm
	+dav1d:libdav1d
	${FFMPEG_UNSLOTTED:+doc:^htmlpages}
	+drm:libdrm
	dvd:libdvdnav,libdvdread
	fdk:libfdk-aac@nonfree
	flite:libflite
	+fontconfig:libfontconfig
	frei0r
	fribidi:libfribidi
	gcrypt
	gme:libgme
	gmp:@v3
	+gnutls
	+gpl
	gsm:libgsm
	iec61883:libiec61883
	ieee1394:libdc1394
	jack:libjack
	jpeg2k:libopenjpeg
	jpegxl:libjxl
	kvazaar:libkvazaar
	ladspa
	lame:libmp3lame
	lcms:lcms2
	libaom
	libaribb24:@v3
	+libass
	libcaca
	libilbc
	liblc3
	libplacebo
	librtmp:librtmp
	libsoxr
	libtesseract
	lv2
	lzma
	modplug:libmodplug
	npp:^libnpp@nonfree
	nvenc:cuvid,ffnvcodec,nvdec,nvenc
	openal
	opencl
	opengl
	openh264:libopenh264
	openmpt:libopenmpt
	openssl:openssl,!gnutls@v3ifgpl
	opus:libopus
	+postproc
	pulseaudio:libpulse
	qrcode:libqrencode
	qsv:libvpl
	quirc:libquirc
	rabbitmq:^librabbitmq
	rav1e:^librav1e
	rubberband:librubberband
	samba:libsmbclient@v3
	sdl:sdl2
	shaderc:libshaderc
	snappy:libsnappy
	sndio
	speex:libspeex
	srt:libsrt
	ssh:libssh
	svg:librsvg
	svt-av1:libsvtav1
	theora:libtheora
	+truetype:libfreetype,libharfbuzz
	twolame:libtwolame
	v4l:libv4l2
	vaapi
	vdpau
	vidstab:libvidstab
	vmaf:libvmaf
	vorbis:libvorbis
	vpx:libvpx
	vulkan
	webp:libwebp
	x264:libx264
	x265:libx265
	+xml:libxml2
	xvid:libxvid
	zeromq:^libzmq
	zimg:libzimg
	+zlib
	zvbi:libzvbi
)

LICENSE="
	gpl? (
		GPL-2+
		amr? ( GPL-3+ ) amrenc? ( GPL-3+ ) libaribb24? ( GPL-3+ )
		gmp? ( GPL-3+ ) openssl? ( GPL-3+ )
		fdk? ( all-rights-reserved ) npp? ( all-rights-reserved )
	)
	!gpl? (
		LGPL-2.1+
		amr? ( LGPL-3+ ) amrenc? ( LGPL-3+ ) libaribb24? ( LGPL-3+ )
		gmp? ( LGPL-3+ )
	)
	samba? ( GPL-3+ )
"
[[ ${FFMPEG_UNSLOTTED} ]] && : 0 || : "$(ver_cut 1)"
SLOT="${_}/${FFMPEG_SUBSLOT}"
IUSE="
	${FFMPEG_IUSE_MAP[*]%:*}
	${FFMPEG_UNSLOTTED:+chromium}
	${FFMPEG_SOC_PATCH:+soc}
	manpages
"
REQUIRED_USE="
	cuda? ( nvenc )
	fribidi? ( truetype )
	gmp? ( !librtmp )
	libplacebo? ( vulkan )
	npp? ( nvenc )
	shaderc? ( vulkan )
	libaribb24? ( gpl ) cdio? ( gpl ) dvd? ( gpl ) frei0r? ( gpl )
	postproc? ( gpl ) rubberband? ( gpl ) samba? ( gpl )
	vidstab? ( gpl ) x264? ( gpl ) x265? ( gpl ) xvid? ( gpl )
	${FFMPEG_UNSLOTTED:+chromium? ( opus )}
	${FFMPEG_SOC_PATCH:+soc? ( drm )}
"
RESTRICT="gpl? ( fdk? ( bindist ) npp? ( bindist ) )"

COMMON_DEPEND="
	virtual/libiconv
	X? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXv
		x11-libs/libxcb:=
	)
	alsa? ( media-libs/alsa-lib )
	amr? ( media-libs/opencore-amr )
	amrenc? ( media-libs/vo-amrwbenc )
	bluray? ( media-libs/libbluray:= )
	bs2b? ( media-libs/libbs2b )
	bzip2? ( app-arch/bzip2 )
	cdio? ( dev-libs/libcdio-paranoia:= )
	chromaprint? ( media-libs/chromaprint:= )
	codec2? ( media-libs/codec2:= )
	dav1d? ( media-libs/dav1d:= )
	dvd? (
		>=media-libs/libdvdnav-6.1.1
		>=media-libs/libdvdread-6.1.3
	)
	drm? ( x11-libs/libdrm )
	fdk? ( media-libs/fdk-aac:= )
	flite? ( app-accessibility/flite )
	fontconfig? ( media-libs/fontconfig )
	frei0r? ( media-plugins/frei0r-plugins )
	fribidi? ( dev-libs/fribidi )
	gcrypt? ( dev-libs/libgcrypt:= )
	gme? ( media-libs/game-music-emu )
	gmp? ( dev-libs/gmp:= )
	gnutls? ( !openssl? ( net-libs/gnutls:= ) )
	gsm? ( media-sound/gsm )
	iec61883? (
		media-libs/libiec61883
		sys-libs/libavc1394
		sys-libs/libraw1394
	)
	ieee1394? (
		media-libs/libdc1394:2=
		sys-libs/libraw1394
	)
	jack? ( virtual/jack )
	jpeg2k? ( media-libs/openjpeg:2= )
	jpegxl? ( media-libs/libjxl:= )
	kvazaar? ( media-libs/kvazaar:= )
	lame? ( media-sound/lame )
	lcms? ( media-libs/lcms:2 )
	libaom? ( media-libs/libaom:= )
	libaribb24? ( media-libs/aribb24 )
	libass? ( media-libs/libass:= )
	libcaca? ( media-libs/libcaca )
	libilbc? ( media-libs/libilbc:= )
	liblc3? ( >=media-sound/liblc3-1.1 )
	libplacebo? ( media-libs/libplacebo:=[vulkan] )
	librtmp? ( media-video/rtmpdump )
	libsoxr? ( media-libs/soxr )
	libtesseract? ( app-text/tesseract:= )
	lv2? (
		media-libs/lilv
		media-libs/lv2
	)
	lzma? ( app-arch/xz-utils )
	modplug? ( media-libs/libmodplug )
	npp? ( dev-util/nvidia-cuda-toolkit:= )
	openal? ( media-libs/openal )
	opencl? ( virtual/opencl )
	opengl? ( media-libs/libglvnd[X] )
	openh264? ( media-libs/openh264:= )
	openmpt? ( media-libs/libopenmpt )
	openssl? ( >=dev-libs/openssl-3:= )
	opus? ( media-libs/opus )
	pulseaudio? ( media-libs/libpulse )
	qrcode? ( media-gfx/qrencode:= )
	qsv? ( media-libs/libvpl:= )
	quirc? ( media-libs/quirc:= )
	rabbitmq? ( net-libs/rabbitmq-c:= )
	rav1e? ( >=media-video/rav1e-0.5:=[capi] )
	rubberband? ( media-libs/rubberband:= )
	samba? ( net-fs/samba:=[client] )
	sdl? (
		media-libs/libsdl2[sound,video]
		libplacebo? ( media-libs/libsdl2[vulkan] )
	)
	shaderc? ( media-libs/shaderc )
	snappy? ( app-arch/snappy:= )
	sndio? ( media-sound/sndio:= )
	speex? ( media-libs/speex )
	srt? ( net-libs/srt:= )
	ssh? ( net-libs/libssh:=[sftp] )
	svg? (
		dev-libs/glib:2
		>=gnome-base/librsvg-2.52:2
		x11-libs/cairo
	)
	svt-av1? ( >=media-libs/svt-av1-0.9:= )
	theora? ( media-libs/libtheora[encode] )
	truetype? (
		media-libs/freetype:2
		media-libs/harfbuzz:=
	)
	twolame? ( media-sound/twolame )
	v4l? ( media-libs/libv4l )
	vaapi? ( media-libs/libva:= )
	vdpau? (
		x11-libs/libX11
		x11-libs/libvdpau
	)
	vidstab? ( media-libs/vidstab )
	vmaf? ( media-libs/libvmaf:= )
	vorbis? ( media-libs/libvorbis )
	vpx? ( media-libs/libvpx:= )
	vulkan? ( media-libs/vulkan-loader )
	webp? ( media-libs/libwebp:= )
	x264? ( media-libs/x264:= )
	x265? ( media-libs/x265:= )
	xml? ( dev-libs/libxml2:= )
	xvid? ( media-libs/xvid )
	zeromq? ( net-libs/zeromq:= )
	zimg? ( media-libs/zimg )
	zlib? ( sys-libs/zlib )
	zvbi? ( media-libs/zvbi )
	${FFMPEG_SOC_PATCH:+"
		soc? ( virtual/libudev:= )
	"}
"
RDEPEND="
	${COMMON_DEPEND}
	amf? ( media-video/amdgpu-pro-amf )
"
DEPEND="
	${COMMON_DEPEND}
	X? ( x11-base/xorg-proto )
	amf? ( media-libs/amf-headers )
	kernel_linux? ( >=sys-kernel/linux-headers-6 )
	ladspa? ( media-libs/ladspa-sdk )
	nvenc? ( >=media-libs/nv-codec-headers-12.1.14.0 )
	opencl? ( dev-util/opencl-headers )
	vulkan? ( dev-util/vulkan-headers )
"
BDEPEND="
	virtual/awk
	virtual/pkgconfig
	amd64? (
		|| (
			dev-lang/nasm
			dev-lang/yasm
		)
	)
	cuda? ( llvm-core/clang:*[llvm_targets_NVPTX] )
	${FFMPEG_UNSLOTTED:+"
		dev-lang/perl
		doc? ( sys-apps/texinfo )
	"}
"
[[ ${PV} != 9999 ]] &&
	BDEPEND+=" verify-sig? ( sec-keys/openpgp-keys-ffmpeg )"

DOCS=( CREDITS Changelog README.md doc/APIchanges )
[[ ${PV} != 9999 ]] && DOCS+=( RELEASE_NOTES )

PATCHES=(
	"${WORKDIR}"/patches
)

pkg_pretend() {
	:
}

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	else
		use verify-sig &&
			verify-sig_verify_detached "${DISTDIR}"/ffmpeg-${PV}.tar.xz{,.asc} \
				"${BROOT}"/usr/share/openpgp-keys/ffmpeg.asc
		default
	fi
}

src_prepare() {
	in_iuse chromium && PATCHES+=( "${FILESDIR}"/chromium-r3.patch )
	in_iuse soc && use soc && PATCHES+=( "${DISTDIR}"/${FFMPEG_SOC_PATCH} )

	default

	sed -i '/cflags -fdiagnostics-color/d' configure || die

	FFMPEG_ENABLE_LTO=
	if is-flagq "-flto*"; then
		: "$(get-flag -flto)"
		FFMPEG_ENABLE_LTO=--enable-lto${_#-flto}
	fi
	filter-lto
}

src_configure() {
	if use npp; then
		local -x CPPFLAGS=${CPPFLAGS} LDFLAGS=${LDFLAGS}
		append-cppflags $($(tc-getPKG_CONFIG) --cflags nppc 2>/dev/null || echo "")
		append-ldflags $($(tc-getPKG_CONFIG) --libs-only-L nppc 2>/dev/null || echo "")
	fi

	local conf=( "${S}"/configure )

	local prefix=${EPREFIX}/usr
	if [[ ! ${FFMPEG_UNSLOTTED} ]]; then
		prefix+=/lib/ffmpeg${SLOT%/*}
		conf+=(
			--enable-rpath
			--disable-doc
		)
	fi

	conf+=(
		--prefix="${prefix}"
		--libdir="${prefix}"/lib64
		--shlibdir="${prefix}"/lib64
		--mandir="${prefix}"/share/man
		--docdir="${EPREFIX}"/usr/share/doc/${PF}/html

		--ar="$(tc-getAR)"
		--cc="$(tc-getCC)"
		--cxx="$(tc-getCXX)"
		--nm="$(tc-getNM)"
		--pkg-config="$(tc-getPKG_CONFIG)"
		--ranlib="$(tc-getRANLIB)"
		--disable-stripping

		--disable-debug
		--disable-optimizations
		--optflags=' '

		${FFMPEG_ENABLE_LTO}

		--enable-iconv
		--enable-pic
		--enable-shared
		--disable-static
		$(use_enable manpages manpages)
		--disable-podpages
		--disable-txtpages

		--disable-decklink
		--disable-libaribcaption
		--disable-libdavs2
		--disable-libklvanc
		--disable-liblcevc-dec
		--disable-libmysofa
		--disable-libopenvino
		--disable-libshine
		--disable-libtls
		--disable-libuavs3d
		--disable-libvvenc
		--disable-libxavs
		--disable-libxavs2
		--disable-libxevd
		--disable-libxeve
		--disable-pocketsphinx
		--disable-rkmpp
		--disable-vapoursynth

		--disable-cuda-nvcc
		--disable-libcelt
		--disable-libglslang
		--disable-liblensfun
		--disable-libmfx
		--disable-libopencv
		--disable-librist
		--disable-libtensorflow
		--disable-libtorch
		--disable-mbedtls
		--disable-mmal
		--disable-omx
		--disable-omx-rpi
	)

	use openssl && conf+=( --disable-gnutls ) || conf+=( --disable-openssl )

	if use soc; then
		conf+=( --disable-epoxy --enable-libudev --enable-sand --enable-v4l2-request )
	fi

	local flag license mod v
	local -A optmap=() licensemap=()
	for v in "${FFMPEG_IUSE_MAP[@]}"; do
		[[ ${v} =~ \+?([^:]+):?([^@]*)@?(.*) ]] || die "${v}"
		flag=${BASH_REMATCH[1]}
		license=${BASH_REMATCH[3]}
		v=${BASH_REMATCH[2]:-${flag}}
		for v in ${v//,/ }; do
			mod=${v::1}
			v=${v#[\!\^]}
			if [[ ${mod} == '!' ]]; then
				if use ${flag}; then
					optmap[${v}]=--disable-${v}
					unset licensemap[${v}]
				fi
			elif [[ ! -v optmap[${v}] ]]; then
				optmap[${v}]=$(use_enable ${flag} ${v})
				use ${flag} && licensemap[${v}]=${license}
			fi
		done
	done
	for license in "${licensemap[@]}"; do
		case ${license} in
			v3ifgpl) use gpl || continue ;&
			v3) optmap[v3]=--enable-version3 ;;
			nonfree) use gpl && optmap[nonfree]=--enable-nonfree ;;
		esac
	done
	conf+=( "${optmap[@]}" ${EXTRA_ECONF} )

	einfo "${conf[*]}"
	"${conf[@]}" || die "configure failed, see ${BUILD_DIR}/ffbuild/config.log"
}

src_compile() {
	emake V=1
	in_iuse chromium && use chromium && emake V=1 libffmpeg
}

src_test() {
	local -x LD_LIBRARY_PATH=$(printf %s: "${BUILD_DIR}"/lib*)${LD_LIBRARY_PATH}
	emake V=1 -k fate
}

src_install() {
	emake V=1 DESTDIR="${D}" install
	in_iuse chromium && use chromium && emake V=1 DESTDIR="${D}" install-libffmpeg
	dodoc CREDITS Changelog README.md doc/APIchanges
	[[ -f RELEASE_NOTES ]] && dodoc RELEASE_NOTES
}
