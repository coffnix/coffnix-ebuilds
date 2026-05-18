# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="ncurses,readline"
QA_PREBUILT="
usr/share/qemu/hppa-firmware.img
usr/share/qemu/hppa-firmware64.img
usr/share/qemu/openbios-ppc
usr/share/qemu/openbios-sparc64
usr/share/qemu/openbios-sparc32
usr/share/qemu/opensbi-riscv64-generic-fw_dynamic.elf
usr/share/qemu/opensbi-riscv32-generic-fw_dynamic.elf
usr/share/qemu/palcode-clipper
usr/share/qemu/s390-ccw.img
usr/share/qemu/s390-netboot.img
usr/share/qemu/u-boot.e500
"

QA_WX_LOAD="
usr/bin/qemu-i386
usr/bin/qemu-x86_64
usr/bin/qemu-alpha
usr/bin/qemu-arm
usr/bin/qemu-cris
usr/bin/qemu-m68k
usr/bin/qemu-microblaze
usr/bin/qemu-microblazeel
usr/bin/qemu-mips
usr/bin/qemu-mipsel
usr/bin/qemu-or1k
usr/bin/qemu-ppc
usr/bin/qemu-ppc64
usr/bin/qemu-sh4
usr/bin/qemu-sh4eb
usr/bin/qemu-sparc
usr/bin/qemu-sparc64
usr/bin/qemu-armeb
usr/bin/qemu-sparc32plus
usr/bin/qemu-s390x
usr/bin/qemu-unicore32
"

inherit toolchain-funcs python-r1 udev fcaps pax-utils xdg-utils

DESCRIPTION="QEMU + Kernel-based Virtual Machine userland tools"
HOMEPAGE="https://www.qemu.org https://www.linux-kvm.org"
SRC_URI="https://download.qemu.org/qemu-11.0.0.tar.xz -> qemu-11.0.0.tar.xz"
LICENSE="GPL-2 LGPL-2 BSD-2"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/qemu-10.1.2-fix_passt.patch"
	"${FILESDIR}/qemu-9.0.0-disable-keymap.patch"
	"${FILESDIR}/qemu-9.2.0-capstone-include-path.patch"
	"${FILESDIR}/qemu-8.1.0-skip-tests.patch"
	"${FILESDIR}/qemu-8.1.0-find-sphinx.patch"
	"${FILESDIR}/qemu-7.2.16-optionrom-pass-Wl-no-error-rwx-segments.patch"
)
IUSE="accessibility +aio alsa bpf bzip2 capstone +curl debug doc
+fdt fuse glusterfs +gnutls gtk infiniband iscsi io-uring
jack jemalloc +jpeg keyutils lzo multipath ncurses nfs
nls numa opengl +oss pam passt +pin-upstream-blobs
plugins +png pulseaudio python rbd sasl +seccomp sdl
sdl-image +slirp smartcard snappy spice ssh static static-user
systemtap udev usb usbredir vde +vhost-net vhost-user-fs
virgl virtfs +vnc vte xattr xen zstd
qemu_softmmu_targets_aarch64
qemu_softmmu_targets_alpha
qemu_softmmu_targets_arm
qemu_softmmu_targets_hppa
qemu_softmmu_targets_i386
qemu_softmmu_targets_loongarch64
qemu_softmmu_targets_m68k
qemu_softmmu_targets_microblaze
qemu_softmmu_targets_microblazeel
qemu_softmmu_targets_mips
qemu_softmmu_targets_mips64
qemu_softmmu_targets_mips64el
qemu_softmmu_targets_mipsel
qemu_softmmu_targets_nios2
qemu_softmmu_targets_or1k
qemu_softmmu_targets_ppc
qemu_softmmu_targets_ppc64
qemu_softmmu_targets_riscv32
qemu_softmmu_targets_riscv64
qemu_softmmu_targets_s390x
qemu_softmmu_targets_sh4
qemu_softmmu_targets_sh4eb
qemu_softmmu_targets_sparc
qemu_softmmu_targets_sparc64
qemu_softmmu_targets_x86_64
qemu_softmmu_targets_xtensa
qemu_softmmu_targets_xtensaeb
qemu_softmmu_targets_avr
qemu_softmmu_targets_rx
qemu_softmmu_targets_tricore
qemu_user_targets_aarch64
qemu_user_targets_alpha
qemu_user_targets_arm
qemu_user_targets_hppa
qemu_user_targets_i386
qemu_user_targets_loongarch64
qemu_user_targets_m68k
qemu_user_targets_microblaze
qemu_user_targets_microblazeel
qemu_user_targets_mips
qemu_user_targets_mips64
qemu_user_targets_mips64el
qemu_user_targets_mipsel
qemu_user_targets_nios2
qemu_user_targets_or1k
qemu_user_targets_ppc
qemu_user_targets_ppc64
qemu_user_targets_riscv32
qemu_user_targets_riscv64
qemu_user_targets_s390x
qemu_user_targets_sh4
qemu_user_targets_sh4eb
qemu_user_targets_sparc
qemu_user_targets_sparc64
qemu_user_targets_x86_64
qemu_user_targets_xtensa
qemu_user_targets_xtensaeb
qemu_user_targets_aarch64_be
qemu_user_targets_armeb
qemu_user_targets_hexagon
qemu_user_targets_mipsn32
qemu_user_targets_mipsn32el
qemu_user_targets_ppc64le
qemu_user_targets_sparc32plus
"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
qemu_softmmu_targets_arm? ( fdt )
qemu_softmmu_targets_microblaze? ( fdt )
qemu_softmmu_targets_mips64el? ( fdt )
qemu_softmmu_targets_ppc64? ( fdt )
qemu_softmmu_targets_ppc? ( fdt )
qemu_softmmu_targets_riscv32? ( fdt )
qemu_softmmu_targets_riscv64? ( fdt )
qemu_softmmu_targets_x86_64? ( fdt )
sdl-image? ( sdl )
static? ( static-user !alsa !gtk !jack !opengl !pam !pulseaudio !plugins !rbd !snappy !udev )
static-user? ( !plugins )
vhost-user-fs? ( seccomp )
virgl? ( opengl )
virtfs? ( xattr )
vnc? ( gnutls )
vte? ( gtk )
multipath? ( udev )
plugins? ( !static !static-user )
"
# Commons depends
CDEPEND="dev-libs/glib:2
	sys-libs/zlib:=
	python? ( ${PYTHON_DEPS} )
	systemtap? ( dev-util/systemtap )
	xattr? ( sys-apps/attr )
	!static? (
	  sys-libs/libcap-ng
	  x11-libs/pixman
	  accessibility? (
	      app-accessibility/brltty[api]
	  )
	  aio? (
	      dev-libs/libaio
	  )
	  alsa? (
	      media-libs/alsa-lib
	  )
	  bpf? (
	      dev-libs/libbpf:=
	  )
	  bzip2? (
	      app-arch/bzip2
	  )
	  capstone? (
	      dev-libs/captone:=
	  )
	  curl? (
	      net-misc/curl
	  )
	  fdt? (
	      sys-apps/dtc
	  )
	  fuse? (
	      sys-fs/fuse:3
	  )
	  glusterfs? (
	      sys-cluster/glusterfs
	  )
	  gnutls? (
	      dev-libs/nettle:=
	      net-libs/gnutls:=
	  )
	  gtk? (
	      x11-libs/gtk+:3
	      vte? ( x11-libs/vte:2.91 )
	  )
	  infiniband? (
	      sys-cluster/rdma-core
	  )
	  iscsi? (
	      net-libs/libiscsi
	  )
	  io-uring? (
	      sys-libs/liburing:=
	  )
	  jack? (
	      virtual/jack
	  )
	  jemalloc? (
	      dev-libs/jemalloc
	  )
	  jpeg? (
	      media-libs/libjpeg-turbo:=
	  )
	  lzo? (
	      dev-libs/lzo:2
	  )
	  multipath? (
	      sys-fs/multipath-tools
	  )
	  ncurses? (
	      sys-libs/ncurses:=
	  )
	  nfs? (
	      net-fs/libnfs:=
	  )
	  numa? (
	      sys-process/numactl
	  )
	  opengl? (
	      virtual/opengl
	  )
	  opengl? (
	      media-libs/libepoxy
	  )
	  opengl? (
	      media-libs/mesa[egl(+),gbm(+)]
	  )
	  pam? (
	      sys-libs/pam
	  )
	  png? (
	      media-libs/libpng:=
	  )
	  pulseaudio? (
	      media-sound/pulseaudio
	  )
	  rbd? (
	      sys-cluster/ceph
	  )
	  sasl? (
	      dev-libs/cyrus-sasl
	  )
	  sdl? (
	      media-libs/libsdl2[video]
	  )
	  sdl-image? (
	      media-libs/sdl2-image
	  )
	  seccomp? (
	      sys-libs/libseccomp
	  )
	  slirp? (
	      net-libs/libslirp
	  )
	  smartcard? (
	      app-emulation/libcacard
	  )
	  snappy? (
	      app-arch/snappy:=
	  )
	  spice? (
	      app-emulation/spice-protocol
	  )
	  spice? (
	      app-emulation/spice
	  )
	  ssh? (
	      net-libs/libssh
	  )
	  udev? (
	      virtual/libudev:=
	  )
	  usb? (
	      virtual/libusb
	  )
	  usbredir? (
	      sys-apps/usbredir
	  )
	  vde? (
	      net-misc/vde
	  )
	  virgl? (
	      media-libs/virglrenderer
	  )
	  virtfs? (
	      sys-libs/libcap
	  )
	  xen? (
	      app-emulation/xen-tools:=
	  )
	  zstd? (
	      app-arch/zstd
	  )
	)
	qemu_softmmu_targets_i386? (
	  pin-upstream-blobs? (
	    sys-firmware/edk2-ovmf-bin
	    sys-firmware/seabios-bin
	  )
	  !pin-upstream-blobs? (
	    sys-firmware/edk2-ovmf
	  )
	  !pin-upstream-blobs? (
	    sys-firmware/seabios[seavgabios]
	  )
	)
	qemu_softmmu_targets_x86_64? (
	  pin-upstream-blobs? (
	    sys-firmware/edk2-ovmf-bin
	    sys-firmware/seabios-bin
	  )
	  !pin-upstream-blobs? (
	    sys-firmware/edk2-ovmf
	  )
	  !pin-upstream-blobs? (
	    sys-firmware/seabios[seavgabios]
	  )
	)
	qemu_softmmu_targets_ppc? (
	  pin-upstream-blobs? (
	    sys-firmware/seabios-bin
	  )
	  !pin-upstream-blobs? (
	    sys-firmware/seabios[seavgabios]
	  )
	)
	qemu_softmmu_targets_ppc64? (
	  pin-upstream-blobs? (
	    sys-firmware/seabios-bin
	  )
	  !pin-upstream-blobs? (
	    sys-firmware/seabios[seavgabios]
	  )
	)
	
"
BDEPEND="dev-libs/libpcre2[static-libs]
	${PYTHON_DEPS}
	dev-python/distlib[${PYTHON_USEDEP}]
	dev-lang/perl
	dev-util/meson
	dev-python/qemu-qmp[${PYTHON_USEDEP}]
	dev-python/qemu-python[${PYTHON_USEDEP}]
	dev-util/ninja
	virtual/pkgconfig
	doc? (
	  dev-python/sphinx[${PYTHON_USEDEP}]
	  dev-python/sphinx-rtd-theme[${PYTHON_USEDEP}]
	)
	sys-devel/gettext
	sys-kernel/linux-headers
	
"
RDEPEND="${CDEPEND}
	
"
DEPEND="${CDEPEND}
	sys-firmware/ipxe[qemu]
	sys-firmware/sgabios
	static? (
	  dev-libs/glib:2[static-libs(+)]
	  sys-libs/zlib:=[static-libs(+)]
	  xattr? ( sys-apps/attr[static-libs(+)] )
	    sys-libs/libcap-ng[static-libs(+)]
	    x11-libs/pixman[static-libs(+)]
	  accessibility? (
	    app-accessibility/brltty[api,static-libs(+)]
	  )
	  aio? (
	    dev-libs/libaio[static-libs(+)]
	  )
	  alsa? (
	    media-libs/alsa-lib[static-libs(+)]
	  )
	  bpf? (
	    dev-libs/libbpf:=
	  )
	  bzip2? (
	    app-arch/bzip2[static-libs(+)]
	  )
	  capstone? (
	    dev-libs/captone:=
	  )
	  curl? (
	    net-misc/curl[static-libs(+)]
	  )
	  fdt? (
	    sys-apps/dtc[static-libs(+)]
	  )
	  fuse? (
	    sys-fs/fuse:3[static-libs(+)]
	  )
	  glusterfs? (
	    sys-cluster/glusterfs[static-libs(+)]
	  )
	  gnutls? (
	    dev-libs/nettle:=[static-libs(+)]
	    net-libs/gnutls:=[static-libs(+)]
	  )
	  gtk? (
	    x11-libs/gtk+:3
	    vte? ( x11-libs/vte:2.91 )
	  )
	  infiniband? (
	    sys-cluster/rdma-core[static-libs(+)]
	  )
	  iscsi? (
	    net-libs/libiscsi
	  )
	  io-uring? (
	    sys-libs/liburing:=[static-libs(+)]
	  )
	  jack? (
	    virtual/jack
	  )
	  jemalloc? (
	    dev-libs/jemalloc
	  )
	  jpeg? (
	    media-libs/libjpeg-turbo:=[static-libs(+)]
	  )
	  lzo? (
	    dev-libs/lzo:2[static-libs(+)]
	  )
	  multipath? (
	    sys-fs/multipath-tools
	  )
	  ncurses? (
	    sys-libs/ncurses:=[static-libs(+)]
	  )
	  nfs? (
	    net-fs/libnfs:=[static-libs(+)]
	  )
	  numa? (
	    sys-process/numactl[static-libs(+)]
	  )
	  opengl? (
	    virtual/opengl
	  )
	  opengl? (
	    media-libs/libepoxy[static-libs(+)]
	  )
	  opengl? (
	    media-libs/mesa[static-libs(+),egl(+),gbm(+)]
	  )
	  pam? (
	    sys-libs/pam
	  )
	  png? (
	    media-libs/libpng:=[static-libs(+)]
	  )
	  pulseaudio? (
	    media-sound/pulseaudio
	  )
	  rbd? (
	    sys-cluster/ceph
	  )
	  sasl? (
	    dev-libs/cyrus-sasl[static-libs(+)]
	  )
	  sdl? (
	    media-libs/libsdl2[video,static-libs(+)]
	  )
	  sdl-image? (
	    media-libs/sdl2-image[static-libs(+)]
	  )
	  seccomp? (
	    sys-libs/libseccomp[static-libs(+)]
	  )
	  slirp? (
	    net-libs/libslirp[static-libs(+)]
	  )
	  smartcard? (
	    app-emulation/libcacard[static-libs(+)]
	  )
	  snappy? (
	    app-arch/snappy:=
	  )
	  spice? (
	    app-emulation/spice-protocol
	  )
	  spice? (
	    app-emulation/spice[static-libs(+)]
	  )
	  ssh? (
	    net-libs/libssh[static-libs(+)]
	  )
	  udev? (
	    virtual/libudev:=
	  )
	  usb? (
	    virtual/libusb[static-libs(+)]
	  )
	  usbredir? (
	    sys-apps/usbredir[static-libs(+)]
	  )
	  vde? (
	    net-misc/vde[static-libs(+)]
	  )
	  virgl? (
	    media-libs/virglrenderer[static-libs(+)]
	  )
	  virtfs? (
	    sys-libs/libcap
	  )
	  xen? (
	    app-emulation/xen-tools:=
	  )
	  zstd? (
	    app-arch/zstd[static-libs(+)]
	  )
	)
	static-user? (
	  dev-libs/glib:2[static-libs(+)]
	  sys-libs/zlib:=[static-libs(+)]
	  xattr? ( sys-apps/attr[static-libs(+)] )
	)
	
"
src_prepare() {
	default
	# bugfix deps
	sed -i 's|"qemu" = { path = "python/" }|"qemu" = { accepted = ">=0.6.1.0a1" }|' pythondeps.toml || die
	# Permits compilation when pip installed and
	# pycotap is not available
	sed -e '/^pycotap =/d' pythondeps.toml -i
	# Use correct toolchain to fix cross-compiling
	tc-export AR AS LD NM OBJCOPY PKG_CONFIG RANLIB STRINGS
	export WINDRES=${CHOST}-windres
	# Verbose builds
	MAKEOPTS+=" V=1"
	sed -i -e 's/-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2//' configure || die
	# Remove bundled copy of libfdt
	rm -r roms/*/ || die
}
##
# configures qemu based on the build directory and the build type
# we are using.
#
qemu_src_configure() {
	debug-print-function ${FUNCNAME} "$@"
	 local buildtype=$1
	local builddir="${S}/${buildtype}-build"
	 mkdir "${builddir}" || die
	 local conf_opts=(
	  --prefix=/usr
	  --sysconfdir=/etc
	  --bindir=/usr/bin
	  --libdir=/usr/$(get_libdir)
	  --datadir=/usr/share
	  --docdir=/usr/share/doc/${PF}/html
	  --mandir=/usr/share/man
	  --localstatedir=/var
	  --disable-bsd-user
	  --disable-containers # bug #732972
	  --disable-guest-agent
	  --disable-strip
	   # bug #746752: TCG interpreter has a few limitations:
	  # - it does not support FPU
	  # - it's generally slower on non-self-modifying code
	  # It's advantage is support for host architectures
	  # where native codegeneration is not implemented.
	  # Gentoo has qemu keyworded only on targets with
	  # native code generation available. Avoid the interpreter.
	  --disable-tcg-interpreter
	   --disable-werror
	  # We support gnutls/nettle for crypto operations.  It is possible
	  # to use gcrypt when gnutls/nettle are disabled (but not when they
	  # are enabled), but it's not really worth the hassle.  Disable it
	  # all the time to avoid automatically detecting it. #568856
	  --disable-gcrypt
	  --python="${PYTHON}"
	  --cc="$(tc-getCC)"
	  --cxx="$(tc-getCXX)"
	  --host-cc="$(tc-getBUILD_CC)"
	   $(use_enable alsa)
	  $(use_enable debug debug-info)
	  $(use_enable debug debug-tcg)
	  $(use_enable jack)
	  $(use_enable nls gettext)
	  $(use_enable oss)
	  $(use_enable plugins)
	  $(use_enable pulseaudio pa)
	  $(use_enable xattr attr)
	  --disable-selinux
	)
	 # Disable options not used by user targets. This simplifies building
	# static user targets (USE=static-user) considerably.
	conf_notuser() {
	  if [[ ${buildtype} == "user" ]] ; then
	    echo "--disable-${2:-$1}"
	  else
	    use_enable "$@"
	  fi
	}
	# Enable option only for softmmu build, but not 'user' or 'tools'
	conf_softmmu() {
	  if [[ ${buildtype} == "softmmu" ]] ; then
	    use_enable "$@"
	  else
	    echo "--disable-${2:-$1}"
	  fi
	}
	# Enable option only for tools build, but not 'user' or 'softmmu'
	conf_tools() {
	  if [[ ${buildtype} == "tools" ]] ; then
	    use_enable "$@"
	  else
	    echo "--disable-${2:-$1}"
	  fi
	}
	# Special case for the malloc flag, because the --disable flag does
	# not exist and trying like above will break configuring.
	conf_malloc() {
	  if [[ ! ${buildtype} == "user" ]] ; then
	    usex "${1}" "--enable-malloc=${1}" ""
	  fi
	}
	conf_opts+=(
	  $(conf_notuser accessibility brlapi)
	  $(conf_notuser aio linux-aio)
	  $(conf_softmmu bpf)
	  $(conf_notuser bzip2)
	  $(conf_notuser capstone)
	  $(conf_notuser curl)
	  $(conf_tools doc docs)
	  $(conf_notuser fdt)
	  $(conf_notuser fuse)
	  $(conf_notuser glusterfs)
	  $(conf_notuser gnutls)
	  $(conf_notuser gnutls nettle)
	  $(conf_notuser gtk)
	  $(conf_notuser infiniband rdma)
	  $(conf_notuser iscsi libiscsi)
	  $(conf_notuser io-uring linux-io-uring)
	  $(conf_malloc jemalloc)
	  $(conf_notuser jpeg vnc-jpeg)
	  $(conf_notuser kernel_linux kvm)
	  $(conf_notuser lzo)
	  $(conf_notuser multipath mpath)
	  $(conf_notuser ncurses curses)
	  $(conf_notuser nfs libnfs)
	  $(conf_notuser numa)
	  $(conf_notuser opengl)
	  $(conf_notuser pam auth-pam)
	  $(conf_notuser png)
	  $(conf_notuser rbd)
	  $(conf_notuser sasl vnc-sasl)
	  $(conf_notuser sdl)
	  $(conf_softmmu sdl-image)
	  $(conf_notuser seccomp)
	  $(conf_notuser slirp)
	  $(conf_notuser smartcard)
	  $(conf_notuser snappy)
	  $(conf_notuser spice)
	  $(conf_notuser ssh libssh)
	  $(conf_notuser udev libudev)
	  $(conf_notuser usb libusb)
	  $(conf_notuser usbredir usb-redir)
	  $(conf_notuser vde)
	  $(conf_notuser vhost-net)
	  $(conf_notuser virgl virglrenderer)
	  $(conf_softmmu virtfs)
	  $(conf_notuser vnc)
	  $(conf_notuser vte)
	  $(conf_notuser xen)
	  $(conf_notuser xen xen-pci-passthrough)
	  # use prebuilt keymaps, bug #759604
	  --disable-xkbcommon
	  $(conf_notuser zstd)
	)
	 if [[ ! ${buildtype} == "user" ]] ; then
	  # check if it's really needed in order avoid this warnign
	  # in function `g_get_user_database_entry':
	  # warning: Using 'getpwuid' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
	  conf_opts+=(
	    --enable-gio
	  )
	  # audio options
	  local audio_opts=(
	    # Note: backend order matters here: #716202
	    # We iterate from higher-level to lower level.
	    $(usex pulseaudio pa "")
	    $(usev jack)
	    $(usev sdl)
	    $(usev alsa)
	    $(usev oss)
	  )
	  conf_opts+=(
	    --audio-drv-list=$(IFS=,; echo "${audio_opts[*]}")
	  )
	fi
	 case ${buildtype} in
	user)
	  conf_opts+=(
	    --enable-linux-user
	    --disable-system
	    --disable-tools
	    --disable-cap-ng
	  )
	  local static_flag="static-user"
	  ;;
	softmmu)
	  conf_opts+=(
	    --disable-linux-user
	    --enable-system
	    --disable-tools
	    --enable-cap-ng
	    --enable-seccomp
	  )
	  local static_flag="none"
	  ;;
	tools)
	  conf_opts+=(
	    --disable-linux-user
	    --disable-system
	    --enable-tools
	    --enable-cap-ng
	  )
	  local static_flag="none"
	  ;;
	esac
	 local targets="${buildtype}_targets"
	[[ -n ${targets} ]] && conf_opts+=( --target-list="${!targets}" )
	 # Add support for SystemTAP
	use systemtap && conf_opts+=( --enable-trace-backend=dtrace )
	 # We always want to attempt to build with PIE support as it results
	# in a more secure binary. But it doesn't work with static or if
	# the current GCC doesn't have PIE support.
	if [[ ${static_flag} != "none" ]] && use ${static_flag}; then
	  conf_opts+=( --static --disable-pie )
	else
	  tc-enables-pie && conf_opts+=( --enable-pie )
	fi
	 # Meson will not use a cross-file unless cross_prefix is set.
	tc-is-cross-compiler && conf_opts+=( --cross-prefix="${CHOST}-" )
	 # Plumb through equivalent of EXTRA_ECONF to allow experiments
	# like bug #747928.
	conf_opts+=( ${EXTRA_CONF_QEMU} )
	 echo "../configure ${conf_opts[*]}"
	cd "${builddir}"
	../configure "${conf_opts[@]}" || die "configure failed"
}
src_configure() {
	local target
	 python_setup
	 softmmu_targets= softmmu_bins=()
	user_targets= user_bins=()
	 iuse_softmmu_targets=(
	  aarch64
	  alpha
	  arm
	  hppa
	  i386
	  loongarch64
	  m68k
	  microblaze
	  microblazeel
	  mips
	  mips64
	  mips64el
	  mipsel
	  nios2
	  or1k
	  ppc
	  ppc64
	  riscv32
	  riscv64
	  s390x
	  sh4
	  sh4eb
	  sparc
	  sparc64
	  x86_64
	  xtensa
	  xtensaeb
	  avr
	  rx
	  tricore
	)
	iuse_user_targets=(
	  aarch64
	  alpha
	  arm
	  hppa
	  i386
	  loongarch64
	  m68k
	  microblaze
	  microblazeel
	  mips
	  mips64
	  mips64el
	  mipsel
	  nios2
	  or1k
	  ppc
	  ppc64
	  riscv32
	  riscv64
	  s390x
	  sh4
	  sh4eb
	  sparc
	  sparc64
	  x86_64
	  xtensa
	  xtensaeb
	  aarch64_be
	  armeb
	  hexagon
	  mipsn32
	  mipsn32el
	  ppc64le
	  sparc32plus
	)
	export iuse_softmmu_targets iuse_user_targets
	 for target in ${iuse_softmmu_targets[@]} ; do
	  if use "qemu_softmmu_targets_${target}"; then
	    softmmu_targets+=",${target}-softmmu"
	    softmmu_bins+=( "qemu-system-${target}" )
	     if use vhost-user-fs; then
	      echo "CONFIG_VHOST_USER_FS=y for ${target}-softmmu" || die
	      echo "CONFIG_VIRTIO=y" >> "configs/devices/${target}-softmmu/gentoo.mak" || die
	      echo "CONFIG_VHOST_USER_FS=y" >> "configs/devices/${target}-softmmu/gentoo.mak" || die
	    else
	      echo "CONFIG_VHOST_USER_FS=n for ${target}-softmmu" || die
	      echo "CONFIG_VIRTIO=n" >> "configs/devices/${target}-softmmu/gentoo.mak" || die
	      echo "CONFIG_VHOST_USER_FS=n" >> "configs/devices/${target}-softmmu/gentoo.mak" || die
	    fi
	  fi
	done
	 for target in ${iuse_user_targets[@]} ; do
	  if use "qemu_user_targets_${target}"; then
	    user_targets+=",${target}-linux-user"
	    user_bins+=( "qemu-${target}" )
	  fi
	done
	 softmmu_targets=${softmmu_targets#,}
	user_targets=${user_targets#,}
	 [[ -n ${softmmu_targets} ]] && qemu_src_configure "softmmu"
	[[ -n ${user_targets}    ]] && qemu_src_configure "user"
	qemu_src_configure "tools"
}
src_compile() {
	if [[ -n ${user_targets} ]]; then
	  cd "${S}/user-build" || die
	  default
	fi
	if [[ -n ${softmmu_targets} ]]; then
	  cd "${S}/softmmu-build" || die
	  default
	fi
	cd "${S}/tools-build" || die
	default
}
qemu_python_install() {
	python_domodule "${S}/python/qemu"
	python_doscript "${S}/scripts/kvm/vmxcap"
	python_doscript "${S}/scripts/qmp/qmp-shell"
	python_doscript "${S}/scripts/qmp/qemu-ga-client"
}
src_install() {
	if [[ -n ${user_targets} ]]; then
	  cd "${S}/user-build"
	  emake DESTDIR="${ED}" install
	  # Install binfmt handler init script for user targets.
	  generate_initd
	  doinitd "${T}/qemu-binfmt"
	  # Install binfmt/qemu.conf.
	  insinto "/usr/share/qemu/binfmt.d"
	  doins "${T}/qemu.conf"
	fi
	if [[ -n ${softmmu_targets} ]]; then
	  cd "${S}/softmmu-build"
	  emake DESTDIR="${ED}" install
	  # This might not exist if the test failed. #512010
	  [[ -e check-report.html ]] && dodoc check-report.html
	  if use kernel_linux; then
	    udev_newrules "${FILESDIR}"/65-kvm.rules-r2 65-kvm.rules
	  fi
	  if use python; then
	    python_foreach_impl qemu_python_install
	  fi
	fi
	cd "${S}/tools-build" || die
	emake DESTDIR="${ED}" install
	# Disable mprotect on the qemu binaries as they use JITs to be fast #459348
	pushd "${ED}"/usr/bin >/dev/null || die
	pax-mark mr "${softmmu_bins[@]}" "${user_bins[@]}" # bug 575594
	popd >/dev/null || die
	# Install config file example for qemu-bridge-helper
	insinto "/etc/qemu"
	doins "${FILESDIR}/bridge.conf"
	cd "${S}" || die
	dodoc MAINTAINERS
	newdoc pc-bios/README README.pc-bios
	# Disallow stripping of prebuilt firmware files.
	dostrip -x ${QA_PREBUILT}
	if [[ -n ${softmmu_targets} ]]; then
	  # Remove SeaBIOS since we're using the SeaBIOS packaged one
	  #rm "${ED}/usr/share/qemu/bios.bin"
	  rm "${ED}/usr/share/qemu/bios-256k.bin"
	  if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386; then
	    #dosym ../seabios/bios.bin /usr/share/qemu/bios.bin
	    dosym ../seabios/bios-256k.bin /usr/share/qemu/bios-256k.bin
	  fi
	  # Remove vgabios since we're using the seavgabios packaged one
	  rm "${ED}/usr/share/qemu/vgabios.bin"
	  rm "${ED}/usr/share/qemu/vgabios-cirrus.bin"
	  rm "${ED}/usr/share/qemu/vgabios-qxl.bin"
	  rm "${ED}/usr/share/qemu/vgabios-stdvga.bin"
	  rm "${ED}/usr/share/qemu/vgabios-virtio.bin"
	  rm "${ED}/usr/share/qemu/vgabios-vmware.bin"
	  # PPC/PPC64 loads vgabios-stdvga
	  if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386 || use qemu_softmmu_targets_ppc || use qemu_softmmu_targets_ppc64; then
	    dosym ../seavgabios/vgabios-isavga.bin /usr/share/qemu/vgabios.bin
	    dosym ../seavgabios/vgabios-cirrus.bin /usr/share/qemu/vgabios-cirrus.bin
	    dosym ../seavgabios/vgabios-qxl.bin /usr/share/qemu/vgabios-qxl.bin
	    dosym ../seavgabios/vgabios-stdvga.bin /usr/share/qemu/vgabios-stdvga.bin
	    dosym ../seavgabios/vgabios-virtio.bin /usr/share/qemu/vgabios-virtio.bin
	    dosym ../seavgabios/vgabios-vmware.bin /usr/share/qemu/vgabios-vmware.bin
	  fi
	  # Remove sgabios since we're using the sgabios packaged one
	  rm "${ED}/usr/share/qemu/sgabios.bin"
	  if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386; then
	    dosym ../sgabios/sgabios.bin /usr/share/qemu/sgabios.bin
	  fi
	  # Remove iPXE since we're using the iPXE packaged one
	  rm "${ED}"/usr/share/qemu/pxe-*.rom
	  if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386; then
	    dosym ../ipxe/8086100e.rom /usr/share/qemu/pxe-e1000.rom
	    dosym ../ipxe/80861209.rom /usr/share/qemu/pxe-eepro100.rom
	    dosym ../ipxe/10500940.rom /usr/share/qemu/pxe-ne2k_pci.rom
	    dosym ../ipxe/10222000.rom /usr/share/qemu/pxe-pcnet.rom
	    dosym ../ipxe/10ec8139.rom /usr/share/qemu/pxe-rtl8139.rom
	    dosym ../ipxe/1af41000.rom /usr/share/qemu/pxe-virtio.rom
	  fi
	fi
}
pkg_postinst() {
	if [[ -n ${softmmu_targets} ]] && use kernel_linux; then
	  udev_reload
	fi
	xdg_icon_cache_update
	[[ -z ${EPREFIX} ]] && [[ -f ${EROOT}/usr/libexec/qemu-bridge-helper ]] && \
	  fcaps cap_net_admin "${EROOT}"/usr/libexec/qemu-bridge-helper
}
pkg_postrm() {
	xdg_icon_cache_update
}

# Generate binfmt support files.
#   - /etc/init.d/qemu-binfmt script which registers the user handlers (openrc)
#   - /usr/share/qemu/binfmt.d/qemu.conf (for use with systemd-binfmt)
generate_initd() {
  local out="${T}/qemu-binfmt"
  local out_systemd="${T}/qemu.conf"
  local d="${T}/binfmt.d"

  einfo "Generating qemu binfmt scripts and configuration files"

  # Generate the debian fragments first.
  mkdir -p "${d}"
  "${S}"/scripts/qemu-binfmt-conf.sh \
    --debian \
    --exportdir "${d}" \
    --qemu-path "${EPREFIX}/usr/bin" \
    || die
  # Then turn the fragments into a shell script we can source.
  sed -E -i \
    -e 's:^([^ ]+) (.*)$:\1="\2":' \
    "${d}"/* || die

  # Generate the init.d script by assembling the fragments from above.
  local f qcpu package interpreter magic mask
  cat "${FILESDIR}"/qemu-binfmt.initd.head >"${out}" || die
  for f in "${d}"/qemu-* ; do
    source "${f}"

    # Normalize the cpu logic like we do in the init.d for the native cpu.
    qcpu=${package#qemu-}
    case ${qcpu} in
    arm*)   qcpu="arm";;
    mips*)  qcpu="mips";;
    ppc*)   qcpu="ppc";;
    s390*)  qcpu="s390";;
    sh*)    qcpu="sh";;
    sparc*) qcpu="sparc";;
    esac
    # we use 'printf' here to be portable across 'sh'
    # implementations: #679168
cat <<EOF >>"${out}"
if [ "\${cpu}" != "${qcpu}" -a -x "${interpreter}" ] ; then
  printf '%s\n' ':${package}:M::${magic}:${mask}:${interpreter}:'"\${QEMU_BINFMT_FLAGS}" >/proc/sys/fs/binfmt_misc/register
fi
EOF
    echo ":${package}:M::${magic}:${mask}:${interpreter}:OC" >>"${out_systemd}"
  done
  cat "${FILESDIR}"/qemu-binfmt.initd.tail >>"${out}" || die
}


# vim: filetype=ebuild
