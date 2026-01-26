# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit meson

DESCRIPTION="The OpenGL Utility Library"
HOMEPAGE="https://gitlab.freedesktop.org/mesa/glu"
SRC_URI="https://archive.mesa3d.org/glu/glu-9.0.3.tar.xz -> glu-9.0.3.tar.xz"
LICENSE="SGI-B-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="+libglvnd glvnd"
RDEPEND="virtual/opengl
	libglvnd? ( media-libs/libglvnd )
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local emesonargs=(
	  -Dgl_provider=$(usex glvnd glvnd gl)
	)
	meson_src_configure
}


# vim: filetype=ebuild
