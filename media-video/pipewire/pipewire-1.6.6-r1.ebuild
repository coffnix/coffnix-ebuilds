# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit meson python-any-r1 udev

DESCRIPTION="Multimedia processing graphs"
HOMEPAGE="http://pipewire.org/"
SRC_URI="https://api.github.com/repos/PipeWire/pipewire/tarball/refs/tags/1.6.6 -> pipewire-1.6.6-a1c1d9f.tar.gz"
LICENSE="NOASSERTION"
SLOT="0"
KEYWORDS="*"
IUSE="bluetooth doc echo-cancel extra elogind flatpak gstreamer jack-client jack-sdk lv2
modemmanager pipewire-alsa ssl systemd v4l X zeroconf examples
"
REQUIRED_USE="jack-sdk? ( !jack-client )
?? ( elogind systemd )
"
BDEPEND="virtual/pkgconfig
	${PYTHON_DEPS}
	$(python_gen_any_dep 'dev-python/docutils[${PYTHON_USEDEP}]')
	doc? (
	  app-doc/doxygen
	  media-gfx/graphviz
	)
	
"
RDEPEND="media-libs/alsa-lib
	sys-apps/dbus
	sys-libs/readline:=
	sys-libs/ncurses:=
	media-video/wireplumber
	virtual/libintl
	virtual/libudev
	bluetooth? (
	  media-libs/fdk-aac
	  media-libs/libldac
	  media-libs/libfreeaptx
	  media-libs/opus
	  media-libs/sbc
	  net-wireless/bluez:=
	  virtual/libusb:1
	)
	echo-cancel? ( media-libs/webrtc-audio-processing )
	extra? (
	  media-libs/libsndfile
	)
	gstreamer? (
	  dev-libs/glib:2
	  media-libs/gstreamer:1.0
	  media-libs/gst-plugins-base:1.0
	)
	jack-client? ( media-sound/jack2[dbus] )
	jack-sdk? (
	  !media-sound/jack-audio-connection-kit
	  !media-sound/jack2
	)
	lv2? ( media-libs/lilv )
	pipewire-alsa? (
	  media-libs/alsa-lib
	)
	ssl? ( dev-libs/openssl:= )
	systemd? ( sys-apps/systemd )
	v4l? ( media-libs/libv4l )
	X? (
	  media-libs/libcanberra
	  x11-libs/libX11
	  x11-libs/libXfixes
	)
	zeroconf? ( net-dns/avahi )
	
"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	
"

post_src_unpack() {
	mv PipeWire-pipewire-* ${S}
}


src_configure() {
	local emesonargs=(
	  -Ddocdir=/usr/share/doc/${PF}
	  $(meson_feature zeroconf avahi)
	  $(meson_feature doc docs)
	  $(meson_feature examples) # TODO: Figure out if this is still important now that media-session gone
	  $(meson_feature doc man)
	  $(meson_feature gstreamer)
	  $(meson_feature gstreamer gstreamer-device-provider)
	  $(meson_feature systemd systemd-system-service)
	  $(meson_feature systemd systemd-user-service)
	  $(meson_feature pipewire-alsa) # Allows integrating ALSA apps into PW graph
	  -Dspa-plugins=enabled
	  -Dalsa=enabled
	  -Dtests=disabled
	  -Dinstalled_tests=disabled
	  -Daudiomixer=enabled # Matches upstream
	  -Daudioconvert=enabled # Matches upstream
	  $(meson_feature bluetooth bluez5)
	  $(meson_feature bluetooth bluez5-backend-hsp-native)
	  $(meson_feature bluetooth bluez5-backend-hfp-native)
	  $(meson_feature modemmanager bluez5-backend-native-mm)
	  $(meson_feature bluetooth bluez5-backend-ofono)
	  $(meson_feature bluetooth bluez5-backend-hsphfpd)
	  $(meson_feature bluetooth bluez5-codec-aac)
	  $(meson_feature bluetooth bluez5-codec-aptx)
	  $(meson_feature bluetooth bluez5-codec-ldac)
	  $(meson_feature bluetooth opus)
	  $(meson_feature bluetooth bluez5-codec-opus)
	  $(meson_feature bluetooth libusb)
	  $(meson_feature echo-cancel echo-cancel-webrtc)
	  -Dcontrol=enabled # Matches upstream
	  -Daudiotestsrc=enabled # Matches upstream
	  -Dffmpeg=disabled # Disabled by upstream and no major developments to spa/plugins/ffmpeg/ since May 2020
	  $(meson_feature flatpak)
	  -Dpipewire-jack=enabled # Allows integrating JACK apps into PW graph
	  $(meson_feature jack-client jack) # Allows PW to act as a JACK client
	  $(meson_use jack-sdk jack-devel)
	  $(usex jack-sdk "-Dlibjack-path=/usr/$(get_libdir)" '')
	  -Dsupport=enabled # Miscellaneous/common plugins, such as null sink
	  -Devl=disabled # Matches upstream
	  -Dtest=disabled # fakesink and fakesource plugins
	  $(meson_feature lv2)
	  $(meson_feature v4l v4l2)
	  -Dlibcamera=disabled # libcamera is not in Portage tree
	  $(meson_feature ssl raop)
	  -Dvideoconvert=enabled # Matches upstream
	  -Dvideotestsrc=enabled # Matches upstream
	  -Dvolume=enabled # Matches upstream
	  -Dvulkan=disabled # Uses pre-compiled Vulkan compute shader to provide a CGI video source (dev thing; disabled by upstream)
	  $(meson_feature extra pw-cat)
	  -Dudev=enabled
	  -Dudevrulesdir="$(get_udevdir)/rules.d"
	  -Dsdl2=disabled # Controls SDL2 dependent code (currently only examples when -Dinstalled_tests=enabled which we never install)
	  $(meson_feature extra sndfile) # Enables libsndfile dependent code (currently only pw-cat)
	  -Dsession-managers="[]" # All available session managers are now their own projects, so there's nothing to build
	   # Just for bell sounds in X11 right now.
	  $(meson_feature X x11)
	  $(meson_feature X x11-xfixes)
	  $(meson_feature X libcanberra)
	)
	 if use elogind ; then
	  emesonargs+=(
	    -Dlibsystemd=disabled
	    -Dlogind=enabled
	    -Dlogind-provider=libelogind
	  )
	fi
	if use systemd ; then
	  emesonargs+=(
	    -Dlibsystemd=enabled
	    -Dlogind=enabled
	    -Dlogind-provider=libsystemd
	  )
	fi
	meson_src_configure
}

src_install() {

	meson_src_install
	newinitd "${FILESDIR}/pipewire.init" pipewire

}


# vim: filetype=ebuild
