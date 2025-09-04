EAPI=7

inherit meson git-r3

DESCRIPTION="Raspberry Pi libcamera command-line apps (rpicam-*)"
HOMEPAGE="https://github.com/raspberrypi/rpicam-apps"
EGIT_REPO_URI="https://github.com/raspberrypi/rpicam-apps.git"
EGIT_BRANCH="main"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"

IUSE="libav drm egl qt opencv tflite hailo imx500 rpi-extensions"

RDEPEND="
	media-libs/libexif
	media-libs/libcamera
	libav? ( media-video/ffmpeg )
	drm? ( x11-libs/libdrm )
	egl? ( media-libs/mesa[egl] )
	qt? ( dev-qt/qtbase:5 )
	opencv? ( media-libs/opencv )
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Denable_libav=$(usex libav enabled disabled)
		-Denable_drm=$(usex drm enabled disabled)
		-Denable_egl=$(usex egl enabled disabled)
		-Denable_qt=$(usex qt enabled disabled)
		-Denable_opencv=$(usex opencv enabled disabled)
		-Denable_tflite=$(usex tflite enabled disabled)
		-Denable_hailo=$(usex hailo enabled disabled)
		-Ddownload_hailo_models=false
		-Denable_imx500=$(usex imx500 true false)
		-Ddownload_imx500_models=false
		-Dneon_flags=auto
		-Ddisable_rpi_features=$(usex rpi-extensions false true)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
}
