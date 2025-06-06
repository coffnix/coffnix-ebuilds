# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools bash-completion-r1 desktop flag-o-matic toolchain-funcs

DESCRIPTION="Displays the hardware topology in convenient formats"
HOMEPAGE="https://www.open-mpi.org/projects/hwloc/"
SRC_URI="https://github.com/open-mpi/hwloc/tarball/86c9e486a5212611abf0c20d84c0a833e145f1bd -> hwloc-2.12.1-86c9e48.tar.gz"

LICENSE="BSD"
SLOT="0/15"
KEYWORDS="*"
IUSE="cairo +cpuid debug +pci static-libs svg udev xml X"

RDEPEND=">=sys-libs/ncurses-5.9-r3:=
	cairo? ( >=x11-libs/cairo-1.12.14-r4[X?,svg(+)?] )
	pci? (
		>=sys-apps/pciutils-3.3.0-r2
		>=x11-libs/libpciaccess-0.13.1-r1
	)
	udev? ( virtual/libudev:= )
	xml? ( >=dev-libs/libxml2-2.9.1-r4 )"
DEPEND="${RDEPEND}"
BDEPEND=">=sys-devel/autoconf-2.69-r4
	virtual/pkgconfig"

DOCS=( AUTHORS NEWS README VERSION )

src_unpack() {
	unpack "${A}"
	mv "${WORKDIR}"/*-${PN}-* "${S}"
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# bug #393467
	export HWLOC_PKG_CONFIG="$(tc-getPKG_CONFIG)"

	local myconf=(
		--disable-opencl
		--disable-netloc
		--disable-plugin-ltdl
		--enable-plugins
		--enable-shared
		--disable-cuda
		--disable-gl
		--disable-nvml
		$(use_enable cairo)
		$(use_enable cpuid)
		$(use_enable debug)
		$(use_enable udev libudev)
		$(use_enable pci)
		$(use_enable static-libs static)
		$(use_enable xml libxml2)
		$(use_with X x)
	)

	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

src_install() {
	default

	mv "${ED}"/usr/share/bash-completion/completions/hwloc{,-annotate} || die
	bashcomp_alias hwloc-annotate \
		hwloc-{diff,ps,compress-dir,gather-cpuid,distrib,info,bind,patch,calc,ls,gather-topology}
	bashcomp_alias hwloc-annotate lstopo{,-no-graphics}

	find "${ED}" -name '*.la' -delete || die
	doicon "${S}"/contrib/android/assets/lstopo.png
}