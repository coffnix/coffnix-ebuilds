# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs verify-sig

DESCRIPTION="Complete solution to record/convert/stream audio and video"
HOMEPAGE="https://ffmpeg.org/"

FFMPEG_SOC_PATCH=ffmpeg-rpi-6.1-r3.patch
FFMPEG_SUBSLOT=58.60.60

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
SLOT="0/${FFMPEG_SUBSLOT}"

[[ ${PN} == *-compat ]] && FFMPEG_UNSLOTTED= || FFMPEG_UNSLOTTED=1

LICENSE="
	gpl? (
		GPL-2+
		amr? ( GPL-3+ ) amrenc? ( GPL-3+ ) libaribb24? ( GPL-3+ )
		gmp? ( GPL-3+ )
		fdk? ( all-rights-reserved )
	)
	!gpl? (
		LGPL-2.1+
		amr? ( LGPL-3+ ) amrenc? ( LGPL-3+ ) libaribb24? ( LGPL-3+ )
		gmp? ( LGPL-3+ )
	)
	samba? ( GPL-3+ )
"

FFMPEG_IUSE_MAP=(
	X:libxcb,libxcb-shape,libxcb-shm,libxcb-xfixes,xlib
	alsa
	amf
	amrenc
	amr
	appkit
	bluray:libbluray
	bs2b:libbs2b
	bzip2:bzlib
	cdio:libcdio
	chromaprint
	codec2:libcodec2
	+dav1d:libdav1d
	+drm:libdrm
	fdk
	flite:libflite
	+fontconfig:libfontconfig
	frei0r
	fribidi:libfribidi
	gcrypt
	gme:libgme
	gmp
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
	libaribb24
	+libass
	libcaca
	libilbc
	libplacebo
	librtmp:librtmp
	libsoxr
	libtesseract
	lv2
	lzma
	modplug:libmodplug
	openal
	opencl
	opengl
	openh264:libopenh264
	openmpt:libopenmpt
	openssl
	opus:libopus
	+postproc
	pulseaudio:libpulse
	qsv:libvpl
	rabbitmq
	rav1e
	rubberband:librubberband
	samba:libsmbclient
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
	zeromq
	zimg:libzimg
	+zlib
	zvbi:libzvbi
)

IUSE="manpages soc ${FFMPEG_IUSE_MAP[*]%:*}"

REQUIRED_USE="
	fribidi? ( truetype )
	libplacebo? ( vulkan )
"

RESTRICT="gpl? ( fdk? ( bindist ) )"

COMMON_DEPEND="
	virtual/libiconv
	alsa? ( media-libs/alsa-lib )
	bluray? ( media-libs/libbluray )
	...
"

# encurtei dependências pra caber no exemplo, você mantém o bloco completo

PATCHES=( "${WORKDIR}"/patches )

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		die "live ebuild não suportado"
	else
		use verify-sig && verify-sig_verify_detached \
			"${DISTDIR}/ffmpeg-${PV}.tar.xz"{,.asc} \
			"${BROOT}/usr/share/openpgp-keys/ffmpeg.asc"
		default
	fi
}

src_prepare() {
	default
	sed -i '/cflags -fdiagnostics-color/d' configure || die
}

src_configure() {
	local conf=( "${S}"/configure )

	conf+=(
		--prefix=/usr
		--libdir=/usr/lib
		--shlibdir=/usr/lib
		--mandir=/usr/share/man
		--docdir=/usr/share/doc/${PF}/html
		--enable-shared
		--disable-static
		--enable-pic
		--disable-stripping
		--disable-debug
		--disable-optimizations
	)

	# manpages só se USE
	conf+=( $(use_enable manpages manpages) )

	# gnutls/openssl toggle
	use openssl && conf+=( --disable-gnutls ) || conf+=( --disable-openssl )

	einfo "${conf[*]}"
	"${conf[@]}" || die
}

src_compile() {
	emake V=1
}

src_install() {
	emake V=1 DESTDIR="${D}" install
	dodoc CREDITS Changelog README.md doc/APIchanges
	[[ -f RELEASE_NOTES ]] && dodoc RELEASE_NOTES
}
