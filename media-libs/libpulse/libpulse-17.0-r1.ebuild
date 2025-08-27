EAPI=7

MY_PV="${PV/_pre*}"
MY_P="pulseaudio-${MY_PV}"
inherit bash-completion-r1 meson systemd udev

DESCRIPTION="Libraries for PulseAudio clients"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/PulseAudio/"

SRC_URI="https://freedesktop.org/software/pulseaudio/releases/${MY_P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="+asyncns dbus doc glib gtk selinux systemd test valgrind X"

S="${WORKDIR}/${MY_P}"

RDEPEND="
	>=media-libs/libsndfile-1.0.20
	dev-libs/libatomic_ops
	asyncns? ( >=net-libs/libasyncns-0.1 )
	dbus? ( >=sys-apps/dbus-1.4.12 )
	glib? ( >=dev-libs/glib-2.28.0 )
	gtk? ( x11-libs/gtk+:3 )
	systemd? ( sys-apps/systemd )
	valgrind? ( dev-debug/valgrind )
	X? (
		x11-libs/libX11
		>=x11-libs/libxcb-1.6
	)
	!<media-sound/pulseaudio-16.1
	!<media-sound/pulseaudio-daemon-16.99.1
"
DEPEND="${RDEPEND}
	test? ( >=dev-libs/check-0.9.10 )
	X? ( xlibre-base/xorg-proto )
"
BDEPEND="
	dev-lang/perl
	dev-perl/XML-Parser
	sys-devel/gettext
	sys-devel/m4
	virtual/libiconv
	virtual/libintl
	virtual/pkgconfig
	doc? ( app-text/doxygen )
"
PDEPEND="
	|| (
		media-video/pipewire[sound-server(+)]
		media-sound/pulseaudio-daemon
	)
"

PATCHES=(
	"${FILESDIR}/pulseaudio-17.0-backport-pr807.patch"
)

src_prepare() {
	default

	# Desativar autospawn no cliente, padrão no Funtoo
	sed -i -e 's:; autospawn = yes:autospawn = no:g' src/pulse/client.conf.in || die
}


src_configure() {
	local emesonargs=(
		--localstatedir="${EPREFIX}/var"
		-Ddaemon=false
		-Dclient=true
		# Usar true/false para doxygen, pois Ã© booleano
		$(use doc && echo -Ddoxygen=true || echo -Ddoxygen=false)
		-Dgcov=false
		# Usar true/false para tests, pois Ã© booleano
		$(use test && echo -Dtests=true || echo -Dtests=false)
		-Ddatabase=simple
		-Dstream-restore-clear-old-devices=true
		-Drunning-from-build-tree=false

		# Caminhos ajustados para Funtoo
		-Dmodlibexecdir="${EPREFIX}/usr/$(get_libdir)/pulseaudio/modules"
		-Dsystemduserunitdir=$(systemd_get_userunitdir)
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)/rules.d"
		-Dbashcompletiondir="$(get_bashcompdir)"

		# Recursos opcionais
		-Dalsa=disabled
		$(meson_feature asyncns asyncns)
		-Davahi=disabled
		$(meson_feature dbus dbus)
		-Delogind=disabled
		-Dfftw=disabled
		$(meson_feature glib glib)
		-Dgsettings=disabled
		-Dgstreamer=disabled
		$(meson_feature gtk gtk)
		-Dhal-compat=false
		-Dipv6=true
		-Djack=disabled
		-Dlirc=disabled
		-Dopenssl=disabled
		-Dorc=disabled
		-Doss-output=disabled
		-Dsamplerate=disabled
		-Dsoxr=disabled
		-Dspeex=disabled
		$(meson_feature systemd systemd)
		-Dtcpwrap=disabled
		-Dudev=disabled
		$(meson_feature valgrind valgrind)
		$(meson_feature X x11)
		-Dadrian-aec=false
		-Dwebrtc-aec=disabled
	)

	# Suporte a padsp apenas com glibc
	if use elibc_glibc; then
		emesonargs+=( -Dpulsedsp-location="${EPREFIX}/usr/$(get_libdir)/pulseaudio" )
	else
		emesonargs+=( -Dpulsedsp-location=disabled )
	fi

	meson_src_configure
}

src_compile() {
	meson_src_compile

	if use doc; then
		einfo "Generating documentation ..."
		meson_src_compile doxygen
	fi
}

src_install() {
	meson_src_install

	# Aliases para bash completion
	bashcomp_alias pactl pulseaudio
	bashcomp_alias pactl pacmd
	bashcomp_alias pactl pasuspender

	if use doc; then
		einfo "Installing documentation ..."
		docinto html
		dodoc -r doxygen/html/.
	fi

	# Remover arquivos estáticos
	find "${ED}" \( -name '*.a' -o -name '*.la' \) -delete || die
}

pkg_postinst() {
	if use dbus; then
		elog "For restricted realtime capabilities via D-Bus, consider installing sys-auth/rtkit."
	fi
}
