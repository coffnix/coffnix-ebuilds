# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit meson

DESCRIPTION="Good plugins for GStreamer"
HOMEPAGE="https://gstreamer.freedesktop.org/"
SRC_URI="https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.26.10.tar.xz -> gst-plugins-good-1.26.10.tar.xz"
LICENSE="LGPL-2+"
SLOT="1.0"
KEYWORDS="*"
IUSE="+orc flac +soup lame +mp3 +pulseaudio taglib v4l udev vpx wavpack"
BDEPEND="virtual/perl-JSON-PP
	virtual/pkgconfig
	sys-apps/sed
	
"
RDEPEND=">=media-libs/gst-plugins-base-1.26.10:1.0
	app-arch/bzip2
	sys-libs/zlib
	orc? ( dev-lang/orc )
	flac? (
	  media-libs/flac:=
	)
	soup? (
	  net-libs/libsoup:3
	)
	lame? (
	  media-sound/lame
	)
	mp3? (
	  media-sound/mpg123
	)
	pulseaudio? (
	  media-sound/pulseaudio
	)
	taglib? (
	  media-libs/taglib:=
	)
	v4l? (
	  media-libs/libv4l
	  udev? ( dev-libs/libgudev:= )
	)
	vpx? (
	  media-libs/libvpx:=
	)
	wavpack? (
	  media-sound/wavpack
	)
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local emesonargs=(
	  -Dbz2=enabled
	  -Dflac=enabled
	  -Dcairo=enabled
	  -Djpeg=enabled
	  -Dlame=enabled
	  -Dmpg123=enabled
	  -Doss=enabled
	  -Dpulse=enabled
	  -Dpng=enabled
	  -Dsoup=enabled
	  -Dtaglib=enabled
	  -Dvpx=enabled
	  -Dwavpack=enabled
	  $(meson_feature flac)
	  $(meson_feature soup)
	  $(meson_feature lame)
	  $(meson_feature mp3 mpg123)
	  $(meson_feature pulseaudio pulse)
	  $(meson_feature taglib)
	  $(meson_feature v4l v4l2)
	  $(meson_feature vpx)
	  $(meson_feature wavpack)
	  -Dpackage-name="GStreamer good plug-ins (MacaroniOS Linux)"
	  -Dpackage-origin="https://macaronios.org"
	)
	if use v4l ; then
	  emesonargs+=(
	    -Dv4l2-gudev=$(usex udev enabled disabled)
	  )
	fi
	meson_src_configure
}


# vim: filetype=ebuild
