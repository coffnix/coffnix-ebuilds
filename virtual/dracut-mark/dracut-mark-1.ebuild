# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="A virtual package that installs a Dracut config for MARK"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}"
src_install() {
	insinto /etc/dracut.conf.d/
	newins ${FILESDIR}/dracut-mark.conf 99-macaroni.conf
	sed -i -e "s|LIBDIR|$(get_libdir)|g" "${ED}/etc/dracut.conf.d/99-macaroni.conf" || die

}


# vim: filetype=ebuild
