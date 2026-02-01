EAPI="7"

DESCRIPTION="Scripts to build livecd Vipnix based on MacaroniOS"
HOMEPAGE="https://vipnix.com.br"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_compile() {
    einfo "Nothing to compile, install scripts only"
}

S="${WORKDIR}"

src_install() {
    dobin "${FILESDIR}/bashlogin"
    dobin "${FILESDIR}/bashlogin-banner" || die
    
    # Cria o diretório /etc/vipnix se não existir
    dodir /etc/vipnix
    
    # Instala os arquivos existentes em /etc
    insinto /etc
    doins "${FILESDIR}/macaronios.ascii"
    
    # Instala os novos arquivos em /etc/vipnix
    insinto /etc/vipnix
    doins "${FILESDIR}/30-vipnix-sysinfo"
    doins "${FILESDIR}/livecd-release"
    doins "${FILESDIR}/logo.ascii"
}
