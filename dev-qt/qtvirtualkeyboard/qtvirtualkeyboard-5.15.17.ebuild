# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Customizable input framework and virtual keyboard for Qt"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtvirtualkeyboard-everywhere-opensource-src-5.15.17.tar.xz -> qtvirtualkeyboard-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="handwriting +spell +X"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtsvg:5
	spell? ( app-text/hunspell:= )
	X? ( x11-libs/libxcb:= )
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local myqmakeargs=(
	  $(usex handwriting CONFIG+=lipi-toolkit '')
	  $(usex spell '' CONFIG+=disable-hunspell)
	  $(usex X '' CONFIG+=disable-desktop)
	  CONFIG+="lang-ar_AR lang-bg_BG lang-cs_CZ lang-da_DK lang-de_DE \
	    lang-el_GR lang-en_GB lang-en_US lang-es_ES lang-es_MX \
	    lang-et_EE lang-fa_FA lang-fi_FI lang-fr_CA lang-fr_FR \
	    lang-he_IL lang-hi_IN lang-hr_HR lang-hu_HU lang-id_ID \
	    lang-it_IT lang-ms_MY lang-nb_NO lang-nl_NL lang-pl_PL \
	    lang-pt_BR lang-pt_PT lang-ro_RO lang-ru_RU lang-sk_SK \
	    lang-sl_SI lang-sq_AL lang-sr_SP lang-sv_SE lang-tr_TR \
	    lang-uk_UA lang-vi_VN"
	)
	qt5-build_src_configure
}


# vim: filetype=ebuild
