# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

inherit meson git-r3

DESCRIPTION="Camera stack for Linux with Raspberry Pi pipeline"
HOMEPAGE="https://libcamera.org"
EGIT_REPO_URI="https://git.libcamera.org/libcamera/libcamera.git"
EGIT_COMMIT="v0.5.2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="opencv"
RESTRICT="test"

RDEPEND="
	dev-libs/libyaml
	net-libs/gnutls
	dev-libs/elfutils

	dev-libs/libevent
	media-libs/libv4l
	virtual/libudev
	media-libs/alsa-lib
	opencv? ( media-libs/opencv )
"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	dev-python/pybind11
	dev-lang/python
"


src_configure() {
	local emesonargs=(
		-Dpipelines=rpi/vc4
		-Dipas=rpi/vc4

		-Dv4l2=enabled
		-Dudev=enabled
		-Dpycamera=enabled

		-Dgstreamer=disabled
		-Dqcam=disabled
		-Dcam=disabled
		-Ddocumentation=disabled
		-Dtest=false
		-Dtracing=disabled
	)
	meson_src_configure
}
