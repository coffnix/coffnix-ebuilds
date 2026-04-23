# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit meson pam udev python-any-r1 xdg-utils

DESCRIPTION="The systemd project's "logind", extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"
SRC_URI="https://api.github.com/repos/elogind/elogind/tarball/refs/tags/v255.17 -> elogind-255.17-36917dd.tar.gz"
LICENSE="GPL-2.0"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/elogind-252.9-nodocs.patch"
	"${FILESDIR}/elogind-255.17-revert-s2idle.patch"
)
IUSE="+acl audit cgroup-hybrid debug doc +pam +policykit"
BDEPEND="app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-util/gperf
	dev-util/intltool
	virtual/pkgconfig
	
"
RDEPEND="audit? ( sys-process/audit )
	sys-apps/util-linux
	sys-libs/libcap
	virtual/libudev:=
	acl? ( sys-apps/acl )
	pam? ( sys-libs/pam )
	!sys-apps/systemd
	
"
DEPEND="${RDEPEND}
"
PDEPEND="sys-apps/dbus
	policykit? ( sys-auth/polkit )
	
"

post_src_unpack() {
	mv elogind-elogind-* ${S}
}


src_prepare() {
	default
	xdg_environment_reset
	 sed -e "s/#RemoveIPC=yes/RemoveIPC=no/" \
	  -i src/login/logind.conf.in || die

}
src_configure() {
	if use cgroup-hybrid; then
	  cgroupmode="hybrid"
	else
	  cgroupmode="unified"
	fi
	 python_setup
	 EMESON_BUILDTYPE="$(usex debug debug release)"
	 local emesonargs=(
	  -Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
	  -Dhtmldir="${EPREFIX}/usr/share/doc/${PF}/html"
	  -Dudevrulesdir="${EPREFIX}$(get_udevdir)"/rules.d
	  --libexecdir="lib/elogind"
	  --localstatedir="${EPREFIX}"/var
	  -Dbashcompletiondir="${EPREFIX}/usr/share/bash-completion/completions"
	  -Dman=auto
	  -Dsmack=true
	  -Dcgroup-controller=openrc
	  -Ddefault-hierarchy=${cgroupmode}
	  -Ddefault-kill-user-processes=false
	  -Dacl=$(usex acl enabled disabled)
	  -Daudit=$(usex audit enabled disabled)
	  -Dhtml=$(usex doc auto disabled)
	  -Dpam=$(usex pam enabled disabled)
	  -Dpamlibdir="$(getpam_mod_dir)"
	  -Dselinux=disabled
	  -Dtests=false
	  -Dutmp=true
	  -Dmode=release
	  -Dhalt-path="${EPREFIX}/sbin/halt"
	  -Dkexec-path="${EPREFIX}/usr/sbin/kexec"
	  -Dnologin-path="${EPREFIX}/sbin/nologin"
	  -Dpoweroff-path="${EPREFIX}/sbin/poweroff"
	  -Dreboot-path="${EPREFIX}/sbin/reboot"
	)
	 meson_src_configure
}
src_install() {
	meson_src_install
	keepdir /var/lib/elogind
	newinitd "${FILESDIR}"/${PN}.init-r1 ${PN}
	newconfd "${FILESDIR}"/${PN}.conf ${PN}
}
pkg_postinst() {
	udev_reload
	local file files
	# find custom hooks excluding known (nvidia-drivers, sys-power/tlp)
	if [[ -d "${EROOT}"/$(get_libdir)/elogind/system-sleep ]]; then
	  readarray -t files < <(find "${EROOT}"/$(get_libdir)/elogind/system-sleep/ \
	    -type f \( -not -iname ".keep_dir" -a \
	      -not -iname "nvidia" -a \
	      -not -iname "49-tlp-sleep" \) || die)
	fi
	if [[ ${#files[@]} -gt 0 ]]; then
	  ewarn "*** Custom hooks in obsolete path detected ***"
	  for file in "${files[@]}"; do
	    ewarn "    ${file}"
	  done
	  ewarn "Move these custom hooks to ${EROOT}/etc/elogind/system-sleep/ instead."
	fi
}
pkg_postrm() {
	udev_reload
}



# vim: filetype=ebuild
