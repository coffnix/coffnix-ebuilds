# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit eutils flag-o-matic autotools toolchain-funcs

DESCRIPTION="Complete solution to record/convert/stream audio and video. Includes libavcodec."
HOMEPAGE="https://ffmpeg.org/"
SRC_URI="https://ffmpeg.org/releases/ffmpeg-8.0.1.tar.xz -> ffmpeg-8.0.1.tar.xz"
SLOT="0"
KEYWORDS="*"

IUSE="alsa chromium doc +encode oss pic static-libs v4l
+bzip2 cpudetection debug gcrypt +gnutls gmp +gpl
hardcoded-tables +iconv libxml2 lzma +network opencl
openssl samba sdl vaapi vdpau vulkan X
+zlib cdio iec61883 ieee1394 libcaca openal libv4l
pulseaudio libdrm jack amr codec2 +dav1d fdk jpeg2k
bluray gme gsm libaribb24 mmal modplug opus libilbc
librtmp ssh speex srt svg video_cards_nvidia vorbis
vpx zvbi appkit bs2b chromaprint cuda flite frei0r
fribidi fontconfig ladspa libass libtesseract lv2
truetype vidstab rubberband zeromq zimg libsoxr
+threads amrenc mp3 kvazaar libaom openh264 rav1e
snappy theora twolame wavpack webp x264 x265 xvid
opengl
fftools_aviocat
fftools_cws2fws
fftools_ffescape
fftools_ffeval
fftools_ffhash
fftools_fourcecc2pixfmt
fftools_graph2dot
fftools_ismindex
fftools_pktdumper
fftools_qt-faststart
fftools_sidxindex
fftools_trasher
cpu_flags_arm_thumb
cpu_flags_arm_v6
cpu_flags_arm_thumb2
cpu_flags_arm_neon
cpu_flags_arm_vfp
cpu_flags_arm_vfpv3
cpu_flags_arm_v8
cpu_flags_x86_3dnow
cpu_flags_x86_3dnowext
cpu_flags_x86_aes
cpu_flags_x86_avx
cpu_flags_x86_avx2
cpu_flags_x86_fma3
cpu_flags_x86_fma4
cpu_flags_x86_mmx
cpu_flags_x86_mmxext
cpu_flags_x86_sse
cpu_flags_x86_sse2
cpu_flags_x86_sse3
cpu_flags_x86_ssse3
cpu_flags_x86_sse4_1
cpu_flags_x86_sse4_2
cpu_flags_x86_xop
"

REQUIRED_USE="cuda? ( video_cards_nvidia )
libv4l? ( v4l )
fftools_cws2fws? ( zlib )
frei0r? ( gpl )
cdio? ( gpl )
rubberband? ( gpl )
vidstab? ( gpl )
samba? ( gpl )
encode? (
  x264? ( gpl )
  x265? ( gpl )
  xvid? ( gpl )
)

cpu_flags_arm_neon? ( cpu_flags_arm_thumb2 cpu_flags_arm_vfp )
cpu_flags_arm_vfpv3? ( cpu_flags_arm_vfp )
cpu_flags_arm_thumb2? ( cpu_flags_arm_v6 )
cpu_flags_arm_v6? ( cpu_flags_arm_thumb )
cpu_flags_x86_avx2? ( cpu_flags_x86_avx )
cpu_flags_x86_fma4? ( cpu_flags_x86_avx )
cpu_flags_x86_fma3? ( cpu_flags_x86_avx )
cpu_flags_x86_xop?  ( cpu_flags_x86_avx )
cpu_flags_x86_avx?  ( cpu_flags_x86_sse4_2 )
cpu_flags_x86_aes? ( cpu_flags_x86_sse4_2 )
cpu_flags_x86_sse4_2?  ( cpu_flags_x86_sse4_1 )
cpu_flags_x86_sse4_1?  ( cpu_flags_x86_ssse3 )
cpu_flags_x86_ssse3?  ( cpu_flags_x86_sse3 )
cpu_flags_x86_sse3?  ( cpu_flags_x86_sse2 )
cpu_flags_x86_sse2?  ( cpu_flags_x86_sse )
cpu_flags_x86_sse?  ( cpu_flags_x86_mmxext )
cpu_flags_x86_mmxext?  ( cpu_flags_x86_mmx )
cpu_flags_x86_3dnowext?  ( cpu_flags_x86_3dnow )
cpu_flags_x86_3dnow?  ( cpu_flags_x86_mmx )
"

BDEPEND="sys-devel/make
	virtual/pkgconfig
	cpu_flags_x86_mmx? (
	  || (
	    dev-lang/nasm
	    dev-lang/yasm
	  )
	)
	cuda? ( sys-devel/clang[llvm_targets_NVPTX] )
	doc? ( sys-apps/texinfo )
"

RDEPEND="alsa? ( media-libs/alsa-lib )
	amr? ( media-libs/opencore-amr )
	bluray? ( media-libs/libbluray )
	bs2b? ( media-libs/libbs2b )
	bzip2? ( app-arch/bzip2 )
	cdio? ( dev-libs/libcdio-paranoia )
	chromaprint? ( media-libs/chromaprint )
	codec2? ( media-libs/codec2 )
	dav1d? ( media-libs/dav1d:= )
	encode? (
	  amrenc? ( media-libs/vo-amrwbenc )
	  kvazaar? ( media-libs/kvazaar )
	  mp3? ( media-sound/lame )
	  openh264? ( media-libs/openh264:= )
	  rav1e? ( media-video/rav1e:=[capi] )
	  snappy? ( app-arch/snappy:= )
	  theora? (
	    media-libs/libtheora[encode]
	    media-libs/libogg
	  )
	  twolame? ( media-sound/twolame )
	  wavpack? ( media-sound/wavpack )
	  webp? ( media-libs/libwebp:= )
	  x264? ( media-libs/x264:= )
	  x265? ( media-libs/x265:= )
	  xvid? ( media-libs/xvid )
	)
	fdk? ( media-libs/fdk-aac:= )
	flite? ( app-accessibility/flite )
	fontconfig? ( media-libs/fontconfig )
	frei0r? ( media-plugins/frei0r-plugins )
	fribidi? ( dev-libs/fribidi )
	gcrypt? ( dev-libs/libgcrypt:= )
	gme? ( media-libs/game-music-emu )
	gmp? ( dev-libs/gmp:= )
	iec61883? (
	  media-libs/libiec61883
	  sys-libs/libraw1394
	  sys-libs/libavc1394
	)
	ieee1394? (
	  media-libs/libdc1394:=
	  sys-libs/libraw1394
	)
	jack? ( virtual/jack )
	jpeg2k? ( media-libs/openjpeg )
	libaribb24? ( media-libs/aribb24 )
	libass? ( media-libs/libass:= )
	libcaca? ( media-libs/libcaca )
	libdrm? ( x11-libs/libdrm )
	librtmp? ( media-video/rtmpdump )
	libsoxr? ( media-libs/soxr )
	libtesseract? ( app-text/tesseract )
	libv4l? ( media-libs/libv4l )
	libxml2? ( dev-libs/libxml2:= )
	lv2? (
	  media-libs/liv2
	  media-libs/lilv
	)
	lzma? ( app-arch/xz-utils )
	mmal? ( media-libs/raspberrypi-userland )
	modplug? ( media-libs/libmodplug )
	openal? ( media-libs/openal )
	opencl? ( virtual/opencl )
	opengl? ( virtual/opengl )
	opus? ( media-libs/opus )
	pulseaudio? ( media-sound/pulseaudio )
	rubberband? ( media-libs/rubberband )
	samba? ( net-fs/samba[client] )
	sdl? ( media-libs/libsdl2[sound,video] )
	speex? ( media-libs/speex )
	srt? ( net-libs/srt )
	ssh? ( net-libs/libssh )
	svg? ( gnome-base/librsvg:= )
	truetype? ( media-libs/freetype )
	vaapi? ( x11-libs/libva:= )
	vdpau? ( x11-libs/libvdpau )
	vidstab? ( media-libs/vidstab )
	vorbis? (
	  media-libs/libvorbis
	  media-libs/libogg
	)
	vpx? ( media-libs/libvpx:= )
	vulkan? ( media-libs/vulkan-loader:= )
	X? (
	  x11-libs/libX11
	  x11-libs/libXext
	  x11-libs/libXv
	  x11-libs/libxcb
	)
	zeromq? ( net-libs/zeromq )
	zimg? ( media-libs/zimg:= )
	zlib? ( sys-libs/zlib )
	zvbi? ( media-libs/zvbi )
	openssl? ( dev-libs/openssl )
	!openssl? (
	  gnutls? ( net-libs/gnutls:= )
	)
"

DEPEND="${RDEPEND}
	video_cards_nvidia? ( media-libs/nv-codec-headers )
	ladspa? ( media-libs/ladspa-sdk )
	v4l? ( sys-kernel/linux-headers )
"

FFTOOLS=(
	aviocat
	cws2fws
	ffescape
	ffeval
	ffhash
	fourcecc2pixfmt
	graph2dot
	ismindex
	pktdumper
	qt-faststart
	sidxindex
	trasher
)

PATCHES=(
	"${FILESDIR}"/ffmpeg-6.1-opencl-parallel-gmake-fix.patch
	"${FILESDIR}"/ffmpeg-8.0.1-svt-av1-4.patch
)

src_prepare() {
	export revision=git-N-8.0.1
	default
}

src_configure() {
	local myconf=(
		--enable-avfilter
		--disable-stripping
		--disable-libcelt
		--prefix="/usr"
		--libdir="/usr/$(get_libdir)"
		--shlibdir="/usr/$(get_libdir)"
		--docdir="/usr/share/doc/ffmpeg-8.0.1/html"
		--mandir="/usr/share/man"
		--enable-shared
		--cc="$(tc-getCC)"
		--cxx="$(tc-getCXX)"
		--ar="$(tc-getAR)"
		--nm="$(tc-getNM)"
		--ranlib="$(tc-getRANLIB)"
		--pkg-config="$(tc-getPKG_CONFIG)"
		--target-os=linux
		$(use_enable static-libs static)
	)

	if use openssl && use gpl ; then
		myconf+=( --enable-nonfree )
	fi

	use samba && myconf+=( --enable-version3 )

	if use encode ; then
		if use amrenc ; then
			myconf+=( --enable-version3 )
		fi
	else
		myconf+=( --disable-encoders )
	fi

	use v4l || myconf+=( --disable-indev=v4l2 --disable-outdev=v4l2 )
	for i in alsa oss jack ; do
		use ${i} || myconf+=( --disable-indev=${i} )
	done
	for i in alsa oss ; do
		use ${i} || myconf+=( --disable-outdev=${i} )
	done

	use amr && myconf+=( --enable-version3 )
	use gmp && myconf+=( --enable-version3 )
	use libaribb24 && myconf+=( --enable-version3 )
	use fdk && use gpl && myconf+=( --enable-nonfree )

	if use bzip2 ; then
		myconf+=( --enable-bzlib )
	else
		myconf+=( --disable-bzlib )
	fi

	if use cpudetection ; then
		myconf+=( --enable-runtime-cpudetect )
	else
		myconf+=( --disable-runtime-cpudetect )
	fi

	if use debug ; then
		myconf+=( --enable-debug )
	else
		myconf+=( --disable-debug )
	fi

	if use gcrypt ; then
		myconf+=( --enable-gcrypt )
	else
		myconf+=( --disable-gcrypt )
	fi

	if use gnutls ; then
		myconf+=( --enable-gnutls )
	else
		myconf+=( --disable-gnutls )
	fi

	if use gmp ; then
		myconf+=( --enable-gmp )
	else
		myconf+=( --disable-gmp )
	fi

	if use gpl ; then
		myconf+=( --enable-gpl )
	else
		myconf+=( --disable-gpl )
	fi

	if use hardcoded-tables ; then
		myconf+=( --enable-hardcoded-tables )
	else
		myconf+=( --disable-hardcoded-tables )
	fi

	if use iconv ; then
		myconf+=( --enable-iconv )
	else
		myconf+=( --disable-iconv )
	fi

	if use libxml2 ; then
		myconf+=( --enable-libxml2 )
	else
		myconf+=( --disable-libxml2 )
	fi

	if use lzma ; then
		myconf+=( --enable-lzma )
	else
		myconf+=( --disable-lzma )
	fi

	if use network ; then
		myconf+=( --enable-network )
	else
		myconf+=( --disable-network )
	fi

	if use opencl ; then
		myconf+=( --enable-opencl )
	else
		myconf+=( --disable-opencl )
	fi

	if use openssl ; then
		myconf+=( --enable-openssl )
	else
		myconf+=( --disable-openssl )
	fi

	if use samba ; then
		myconf+=( --enable-libsmbclient )
	else
		myconf+=( --disable-libsmbclient )
	fi

	if use sdl ; then
		myconf+=( --enable-ffplay --enable-sdl2 )
	else
		myconf+=( --disable-ffplay --disable-sdl2 )
	fi

	if use vaapi ; then
		myconf+=( --enable-vaapi )
	else
		myconf+=( --disable-vaapi )
	fi

	if use vdpau ; then
		myconf+=( --enable-vdpau )
	else
		myconf+=( --disable-vdpau )
	fi

	if use vulkan ; then
		myconf+=( --enable-vulkan )
	else
		myconf+=( --disable-vulkan )
	fi

	if use X ; then
		myconf+=(
			--enable-xlib
			--enable-libxcb
			--enable-libxcb-shm
			--enable-libxcb-xfixes
		)
	else
		myconf+=(
			--disable-xlib
			--disable-libxcb
			--disable-libxcb-shm
			--disable-libxcb-xfixes
		)
	fi

	if use zlib ; then
		myconf+=( --enable-zlib )
	else
		myconf+=( --disable-zlib )
	fi

	if use cdio ; then
		myconf+=( --enable-libcdio )
	else
		myconf+=( --disable-libcdio )
	fi

	if use iec61883 ; then
		myconf+=( --enable-libiec61883 )
	else
		myconf+=( --disable-libiec61883 )
	fi

	if use ieee1394 ; then
		myconf+=( --enable-libdc1394 )
	else
		myconf+=( --disable-libdc1394 )
	fi

	if use libcaca ; then
		myconf+=( --enable-libcaca )
	else
		myconf+=( --disable-libcaca )
	fi

	if use openal ; then
		myconf+=( --enable-openal )
	else
		myconf+=( --disable-openal )
	fi

	if use opengl ; then
		myconf+=( --enable-opengl )
	else
		myconf+=( --disable-opengl )
	fi

	if use libv4l ; then
		myconf+=( --enable-libv4l2 )
	else
		myconf+=( --disable-libv4l2 )
	fi

	if use pulseaudio ; then
		myconf+=( --enable-libpulse )
	else
		myconf+=( --disable-libpulse )
	fi

	if use libdrm ; then
		myconf+=( --enable-libdrm )
	else
		myconf+=( --disable-libdrm )
	fi

	if use jack ; then
		myconf+=( --enable-libjack )
	else
		myconf+=( --disable-libjack )
	fi

	if use amr ; then
		myconf+=( --enable-libopencore-amrwb --enable-libopencore-amrnb )
	else
		myconf+=( --disable-libopencore-amrwb --disable-libopencore-amrnb )
	fi

	if use codec2 ; then
		myconf+=( --enable-libcodec2 )
	else
		myconf+=( --disable-libcodec2 )
	fi

	if use dav1d ; then
		myconf+=( --enable-libdav1d )
	else
		myconf+=( --disable-libdav1d )
	fi

	if use fdk ; then
		myconf+=( --enable-libfdk-aac )
	else
		myconf+=( --disable-libfdk-aac )
	fi

	if use jpeg2k ; then
		myconf+=( --enable-libopenjpeg )
	else
		myconf+=( --disable-libopenjpeg )
	fi

	if use bluray ; then
		myconf+=( --enable-libbluray )
	else
		myconf+=( --disable-libbluray )
	fi

	if use gme ; then
		myconf+=( --enable-libgme )
	else
		myconf+=( --disable-libgme )
	fi

	if use gsm ; then
		myconf+=( --enable-libgsm )
	else
		myconf+=( --disable-libgsm )
	fi

	if use libaribb24 ; then
		myconf+=( --enable-libaribb24 )
	else
		myconf+=( --disable-libaribb24 )
	fi

	if use mmal ; then
		myconf+=( --enable-mmal )
	else
		myconf+=( --disable-mmal )
	fi

	if use modplug ; then
		myconf+=( --enable-libmodplug )
	else
		myconf+=( --disable-libmodplug )
	fi

	if use opus ; then
		myconf+=( --enable-libopus )
	else
		myconf+=( --disable-libopus )
	fi

	if use libilbc ; then
		myconf+=( --enable-libilbc )
	else
		myconf+=( --disable-libilbc )
	fi

	if use librtmp ; then
		myconf+=( --enable-librtmp )
	else
		myconf+=( --disable-librtmp )
	fi

	if use ssh ; then
		myconf+=( --enable-libssh )
	else
		myconf+=( --disable-libssh )
	fi

	if use speex ; then
		myconf+=( --enable-libspeex )
	else
		myconf+=( --disable-libspeex )
	fi

	if use srt ; then
		myconf+=( --enable-libsrt )
	else
		myconf+=( --disable-libsrt )
	fi

	if use svg ; then
		myconf+=( --enable-librsvg )
	else
		myconf+=( --disable-librsvg )
	fi

	if use video_cards_nvidia ; then
		myconf+=( --enable-ffnvcodec )
	else
		myconf+=( --disable-ffnvcodec )
	fi

	if use vorbis ; then
		myconf+=( --enable-libvorbis )
	else
		myconf+=( --disable-libvorbis )
	fi

	if use vpx ; then
		myconf+=( --enable-libvpx )
	else
		myconf+=( --disable-libvpx )
	fi

	if use zvbi ; then
		myconf+=( --enable-libzvbi )
	else
		myconf+=( --disable-libzvbi )
	fi

	if use appkit ; then
		myconf+=( --enable-appkit )
	else
		myconf+=( --disable-appkit )
	fi

	if use bs2b ; then
		myconf+=( --enable-libbs2b )
	else
		myconf+=( --disable-libbs2b )
	fi

	if use chromaprint ; then
		myconf+=( --enable-chromaprint )
	else
		myconf+=( --disable-chromaprint )
	fi

	if use cuda ; then
		myconf+=( --enable-cuda-llvm )
	else
		myconf+=( --disable-cuda-llvm )
	fi

	if use flite ; then
		myconf+=( --enable-libflite )
	else
		myconf+=( --disable-libflite )
	fi

	if use frei0r ; then
		myconf+=( --enable-frei0r )
	else
		myconf+=( --disable-frei0r )
	fi

	if use fribidi ; then
		myconf+=( --enable-libfribidi )
	else
		myconf+=( --disable-libfribidi )
	fi

	if use fontconfig ; then
		myconf+=( --enable-fontconfig )
	else
		myconf+=( --disable-fontconfig )
	fi

	if use ladspa ; then
		myconf+=( --enable-ladspa )
	else
		myconf+=( --disable-ladspa )
	fi

	if use libass ; then
		myconf+=( --enable-libass )
	else
		myconf+=( --disable-libass )
	fi

	if use libtesseract ; then
		myconf+=( --enable-libtesseract )
	else
		myconf+=( --disable-libtesseract )
	fi

	if use lv2 ; then
		myconf+=( --enable-lv2 )
	else
		myconf+=( --disable-lv2 )
	fi

	if use truetype ; then
		myconf+=( --enable-libfreetype )
	else
		myconf+=( --disable-libfreetype )
	fi

	if use vidstab ; then
		myconf+=( --enable-libvidstab )
	else
		myconf+=( --disable-libvidstab )
	fi

	if use rubberband ; then
		myconf+=( --enable-librubberband )
	else
		myconf+=( --disable-librubberband )
	fi

	if use zeromq ; then
		myconf+=( --enable-libzmq )
	else
		myconf+=( --disable-libzmq )
	fi

	if use zimg ; then
		myconf+=( --enable-libzimg )
	else
		myconf+=( --disable-libzimg )
	fi

	if use libsoxr ; then
		myconf+=( --enable-libsoxr )
	else
		myconf+=( --disable-libsoxr )
	fi

	if use threads ; then
		myconf+=( --enable-pthreads )
	else
		myconf+=( --disable-pthreads )
	fi

	if use pic ; then
		myconf+=( --enable-pic )
		if [[ ${ABI} == x86 ]] ; then
			myconf+=( --disable-asm )
		fi
	fi

	if use openssl ; then
		myconf+=( --disable-gnutls )
	fi

	if ! use cpu_flags_arm_thumb ; then
		myconf+=( --disable-armv5te )
	fi
	if ! use cpu_flags_arm_v6 ; then
		myconf+=( --disable-armv6 )
	fi
	if ! use cpu_flags_arm_thumb2 ; then
		myconf+=( --disable-armv6t2 )
	fi

	case "$(tc-arch-kernel)" in
		arm64)
			myconf+=( --enable-asm --enable-inline-asm )
		;;
		arm)
			if use cpu_flags_arm_neon ; then
				myconf+=( --enable-neon )
			else
				myconf+=( --disable-neon )
			fi
		;;
	esac

	if ! use cpu_flags_arm_vfp ; then
		myconf+=( --disable-vfp )
	fi
	if ! use cpu_flags_arm_vfpv3 ; then
		myconf+=( --disable-vfpv3 )
	fi
	if ! use cpu_flags_arm_v8 ; then
		myconf+=( --disable-armv8 )
	fi

	is-flagq "-flto*" && myconf+=( --enable-lto )

	einfo "Configure flags\n${myconf[*]}"
	"${S}"/configure "${myconf[@]}" || die "configure failed"
}

src_compile() {
	emake V=1
	if use fftools_aviocat ; then
		emake V=1 tools/aviocat$(get_exeext)
	fi
	if use fftools_cws2fws ; then
		emake V=1 tools/cws2fws$(get_exeext)
	fi
	if use fftools_ffescape ; then
		emake V=1 tools/ffescape$(get_exeext)
	fi
	if use fftools_ffeval ; then
		emake V=1 tools/ffeval$(get_exeext)
	fi
	if use fftools_ffhash ; then
		emake V=1 tools/ffhash$(get_exeext)
	fi
	if use fftools_fourcecc2pixfmt ; then
		emake V=1 tools/fourcecc2pixfmt$(get_exeext)
	fi
	if use fftools_graph2dot ; then
		emake V=1 tools/graph2dot$(get_exeext)
	fi
	if use fftools_ismindex ; then
		emake V=1 tools/ismindex$(get_exeext)
	fi
	if use fftools_pktdumper ; then
		emake V=1 tools/pktdumper$(get_exeext)
	fi
	if use fftools_qt-faststart ; then
		emake V=1 tools/qt-faststart$(get_exeext)
	fi
	if use fftools_sidxindex ; then
		emake V=1 tools/sidxindex$(get_exeext)
	fi
	if use fftools_trasher ; then
		emake V=1 tools/trasher$(get_exeext)
	fi
	if use chromium ; then
		emake V=1 libffmpeg
	fi
}

src_install() {
	emake V=1 DESTDIR="${D}" install install-doc
	if use fftools_aviocat ; then
		dobin tools/aviocat$(get_exeext)
	fi
	if use fftools_cws2fws ; then
		dobin tools/cws2fws$(get_exeext)
	fi
	if use fftools_ffescape ; then
		dobin tools/ffescape$(get_exeext)
	fi
	if use fftools_ffeval ; then
		dobin tools/ffeval$(get_exeext)
	fi
	if use fftools_ffhash ; then
		dobin tools/ffhash$(get_exeext)
	fi
	if use fftools_fourcecc2pixfmt ; then
		dobin tools/fourcecc2pixfmt$(get_exeext)
	fi
	if use fftools_graph2dot ; then
		dobin tools/graph2dot$(get_exeext)
	fi
	if use fftools_ismindex ; then
		dobin tools/ismindex$(get_exeext)
	fi
	if use fftools_pktdumper ; then
		dobin tools/pktdumper$(get_exeext)
	fi
	if use fftools_qt-faststart ; then
		dobin tools/qt-faststart$(get_exeext)
	fi
	if use fftools_sidxindex ; then
		dobin tools/sidxindex$(get_exeext)
	fi
	if use fftools_trasher ; then
		dobin tools/trasher$(get_exeext)
	fi
	if use chromium ; then
		emake V=1 DESTDIR="${D}" install-libffmpeg
		QA_FLAGS_IGNORED+=" usr/$(get_libdir)/chromium/.*"
	fi
}

# vim: filetype=ebuild
