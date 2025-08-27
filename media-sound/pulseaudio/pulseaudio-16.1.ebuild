# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit bash-completion-r1 gnome2-utils meson optfeature systemd tmpfiles udev

DESCRIPTION="Daemon component of PulseAudio (networked sound server)"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/PulseAudio/"

SRC_URI="https://distributions.freedesktop.org/software/pulseaudio/releases/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1"

SLOT="0"

# +alsa-plugin as discussed in bug #519530
# TODO: Find out why webrtc-aec is + prefixed - there's already the always available speexdsp-aec
# NOTE: The current ebuild sets +X almost certainly just for the pulseaudio.desktop file
IUSE="+alsa +alsa-plugin aptx +asyncns bluetooth dbus elogind equalizer fftw +gdbm +glib gstreamer gtk jack ldac lirc
ofono-headset +orc oss selinux sox ssl systemd tcpd test +udev valgrind +webrtc-aec +X zeroconf"

RESTRICT="!test? ( test )"

# See "*** BLUEZ support not found (requires D-Bus)" in configure.ac
# Basically all IUSE are either ${MULTILIB_USEDEP} for client libs or they belong under !daemon ()
# We duplicate alsa-plugin, {native,ofono}-headset under daemon to let users deal with them at once
REQUIRED_USE="
	?? ( elogind systemd )
	alsa-plugin? ( alsa )
	aptx? ( bluetooth )
	bluetooth? ( dbus )
	equalizer? ( dbus )
	ldac? ( bluetooth )
	ofono-headset? ( bluetooth )
	udev? ( || ( alsa oss ) )
	zeroconf? ( dbus )
"

LIBS_RDEPEND="
	dev-libs/libatomic_ops
	>=media-libs/libsndfile-1.0.20
	virtual/libc
	asyncns? ( >=net-libs/libasyncns-0.1 )
	dbus? ( >=sys-apps/dbus-1.4.12 )
	elibc_mingw? ( dev-libs/libpcre:3 )
	glib? ( >=dev-libs/glib-2.28.0:2 )
	gtk? ( x11-libs/gtk+:3 )
	selinux? ( sec-policy/selinux-pulseaudio )
	systemd? ( sys-apps/systemd:= )
	valgrind? ( dev-util/valgrind )
	X? (
		x11-libs/libX11
		>=x11-libs/libxcb-1.6
	)
	!<media-sound/pulseaudio-15.0-r100
"

LIBS_DEPEND="${LIBS_RDEPEND}
	test? ( >=dev-libs/check-0.9.10 )
	X? ( xlibre-base/xorg-proto )
"


# NOTE:
# - libpcre needed in some cases, bug #472228
# - media-libs/speexdsp is providing echo canceller implementation and used in resampler
# TODO: libatomic_ops is only needed on some architectures and conditions, and then at runtime too
gstreamer_deps="
	media-libs/gst-plugins-base
	>=media-libs/gstreamer-1.14
"
COMMON_DEPEND="
	dev-libs/libatomic_ops
	>=media-libs/libsndfile-1.0.20
	=media-libs/speexdsp-1.2*
	alsa? ( >=media-libs/alsa-lib-1.0.24 )
	aptx? ( ${gstreamer_deps} )
	asyncns? ( >=net-libs/libasyncns-0.1 )
	bluetooth? (
		>=net-wireless/bluez-5
		media-libs/sbc
	)
	dev-libs/libltdl
	sys-kernel/linux-headers
	>=sys-libs/libcap-2.22-r2
	dbus? ( >=sys-apps/dbus-1.4.12 )
	elibc_mingw? ( dev-libs/libpcre:3 )
	elogind? ( sys-auth/elogind )
	equalizer? (
		sci-libs/fftw:3.0=
	)
	fftw? (
		sci-libs/fftw:3.0=
	)
	gdbm? ( sys-libs/gdbm:= )
	glib? ( >=dev-libs/glib-2.28.0:2 )
	gstreamer? (
		${gstreamer_deps}
		>=dev-libs/glib-2.26.0:2
	)
	jack? ( virtual/jack )
	ldac? ( ${gstreamer_deps} )
	lirc? ( app-misc/lirc )
	ofono-headset? ( >=net-misc/ofono-1.13 )
	orc? ( >=dev-lang/orc-0.4.15 )
	selinux? ( sec-policy/selinux-pulseaudio )
	sox? ( >=media-libs/soxr-0.1.1 )
	ssl? ( dev-libs/openssl:= )
	systemd? ( sys-apps/systemd:= )
	tcpd? ( sys-apps/tcp-wrappers )
	udev? ( >=virtual/udev-143[hwdb(+)] )
	valgrind? ( dev-util/valgrind )
	webrtc-aec? ( >=media-libs/webrtc-audio-processing-0.2:0 )
	X? (
		>=x11-libs/libxcb-1.6
		x11-libs/libICE
		x11-libs/libSM
		>=x11-libs/libX11-1.4.0
		>=x11-libs/libXtst-1.0.99.2
	)
	zeroconf? ( >=net-dns/avahi-0.6.12[dbus] )
	!<media-sound/pulseaudio-15.0-r100
"

# pulseaudio ships a bundle xmltoman, which uses XML::Parser
DEPEND="
	${COMMON_DEPEND}
	${LIBS_DEPEND}
	test? ( >=dev-libs/check-0.9.10 )
	X? ( xlibre-base/xorg-proto )
"

RDEPEND="
	${COMMON_DEPEND}
	${LIBS_RDEPEND}
	bluetooth? (
		ldac? ( media-plugins/gst-plugins-ldac )
		aptx? ( media-plugins/gst-plugins-openaptx )
	)
"
unset gstreamer_deps

# This is a PDEPEND to avoid a circular dep
PDEPEND="
	alsa? ( alsa-plugin? ( >=media-plugins/alsa-plugins-1.0.27-r1[pulseaudio] ) )
"

BDEPEND="
	dev-lang/perl
	dev-perl/XML-Parser
	sys-devel/gettext
	virtual/libiconv
	virtual/libintl
	virtual/pkgconfig
	orc? ( >=dev-lang/orc-0.4.15 )
"

DOCS=( NEWS README )

# patches merged upstream, to be removed with 16.2 or later bump
PATCHES=(
	"${FILESDIR}"/pulseaudio-16.0-optional-module-console-kit.patch
	"${FILESDIR}"/pulseaudio-16.1-module-combine-sink-load-crash.patch
	"${FILESDIR}"/pulseaudio-16.1-module-combine-sink-unload-crash.patch
	"${FILESDIR}"/pulseaudio-16.1-memfd-cleanup.patch
)

src_prepare() {
	default

	# disable autospawn by client
	sed -i -e 's:; autospawn = yes:autospawn = no:g' src/pulse/client.conf.in || die

	gnome2_environment_reset
}

src_configure() {
	local enable_bluez5_gstreamer="disabled"
	if use aptx || use ldac ; then
		enable_bluez5_gstreamer="enabled"
	fi

	local enable_fftw="disabled"
	if use equalizer || use fftw ; then
		enable_fftw="enabled"
	fi

	local emesonargs=(
		--localstatedir="${EPREFIX}"/var
		-Ddaemon=true
		-Dclient=true
		-Ddoxygen=false
		-Dgcov=false
		-Dman=true
		$(meson_use test tests)
		-Ddatabase=$(usex gdbm gdbm simple) # tdb is also an option but no one cares about it
		-Dstream-restore-clear-old-devices=true
		-Drunning-from-build-tree=false

		# Paths
		-Dmodlibexecdir="${EPREFIX}/usr/$(get_libdir)/pulseaudio/modules" # Was $(get_libdir)/${P}
		-Dsystemduserunitdir=$(systemd_get_userunitdir)
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)/rules.d"
		-Dbashcompletiondir="$(get_bashcompdir)" # Alternatively DEPEND on app-shells/bash-completion for pkg-config to provide the value

		# Optional features
		$(meson_feature alsa)
		$(meson_feature asyncns)
		$(meson_feature zeroconf avahi)
		$(meson_feature bluetooth bluez5)
		-Dbluez5-gstreamer=${enable_bluez5_gstreamer}
		$(meson_use bluetooth bluez5-native-headset)
		$(meson_use ofono-headset bluez5-ofono-headset)
		-Dconsolekit=disabled
		$(meson_feature dbus)
		$(meson_feature elogind)
		-Dfftw=${enable_fftw}
		$(meson_feature glib) # WARNING: toggling this likely changes ABI
		$(meson_feature glib gsettings) # Supposedly correct?
		$(meson_feature gstreamer)
		$(meson_feature gtk)
		-Dhal-compat=false
		-Dipv6=true
		$(meson_feature jack)
		$(meson_feature lirc)
		$(meson_feature ssl openssl)
		$(meson_feature orc)
		$(meson_feature oss oss-output)
		-Dsamplerate=disabled # Matches upstream
		$(meson_feature sox soxr)
		-Dspeex=enabled
		$(meson_feature systemd)
		$(meson_feature tcpd tcpwrap)
		$(meson_feature udev)
		$(meson_feature valgrind)
		$(meson_feature X x11)

		# Echo cancellation
		-Dadrian-aec=false # Not packaged?
		$(meson_feature webrtc-aec)
	)
	
	# Make padsp work for non-native ABI, supposedly only possible with glibc;
	# this is used by /usr/bin/padsp that comes from native build, thus we need
	# this argument for native build
	if use elibc_glibc; then
		emesonargs+=( -Dpulsedsp-location="${EPREFIX}"'/usr/\\$$LIB/pulseaudio' )
	fi

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install

	# Daemon configuration scripts will try to load snippets from corresponding '.d' dirs.
	# Install these dirs to silence a warning if they are missing.
	keepdir /etc/pulse/default.pa.d
	keepdir /etc/pulse/system.pa.d

	# Prevent warnings, bug 447694
	if use dbus; then
		rm "${ED}"/etc/dbus-1/system.d/pulseaudio-system.conf || die
	fi

	if use zeroconf; then
		sed -i \
			-e '/module-zeroconf-publish/s:^#::' \
			"${ED}/etc/pulse/default.pa" \
			|| die
	fi

	# Only enable autospawning pulseaudio daemon on systems without systemd
	if ! use systemd; then
		insinto /etc/pulse/client.conf.d
		newins "${FILESDIR}/enable-autospawn.conf" "enable-autospawn.conf"
	fi

	find "${ED}" \( -name '*.a' -o -name '*.la' \) -delete || die
}

pkg_postinst() {
	gnome2_schemas_update
	optfeature_header "PulseAudio can be enhanced by installing the following:"
	use dbus && optfeature "restricted realtime capabilities via D-Bus" sys-auth/rtkit

	use udev && udev_reload

	if use equalizer; then
		elog "You will need to load some extra modules to make qpaeq work."
		elog "You can do that by adding the following two lines in"
		elog "/etc/pulse/default.pa and restarting pulseaudio:"
		elog "load-module module-equalizer-sink"
		elog "load-module module-dbus-protocol"
		elog ""
	fi

	if use bluetooth; then
		elog "You have enabled bluetooth USE flag for pulseaudio. Daemon will now handle"
		elog "bluetooth Headset (HSP HS and HSP AG) and Handsfree (HFP HF) profiles using"
		elog "native headset backend by default. This can be selectively disabled"
		elog "via runtime configuration arguments to module-bluetooth-discover"
		elog "in /etc/pulse/default.pa"
		elog "To disable HFP HF append enable_native_hfp_hf=false"
		elog "To disable HSP HS append enable_native_hsp_hs=false"
		elog "To disable HSP AG append headset=auto or headset=ofono"
		elog "(note this does NOT require enabling USE ofono)"
		elog ""
	fi

	if use ofono-headset; then
		elog "You have enabled both native and ofono headset profiles. The runtime decision"
		elog "which to use is done via the 'headset' argument of module-bluetooth-discover."
		elog ""
	fi

	if use gstreamer; then
		elog "GStreamer-based RTP implementation modile enabled."
		elog "To use OPUS payload install media-plugins/gst-plugins-opus"
		elog "and add enable_opus=1 argument to module-rtp-send"
		elog ""
	fi

	optfeature_header "PulseAudio can be enhanced by installing the following:"
	use equalizer && optfeature "using the qpaeq script" dev-python/PyQt5[dbus,widgets]
	use dbus && optfeature "restricted realtime capabilities via D-Bus" sys-auth/rtkit
}

pkg_postrm() {
	gnome2_schemas_update
	use udev && udev_reload
}
