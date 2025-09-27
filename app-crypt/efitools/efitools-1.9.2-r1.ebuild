# Copyright 1999-2025
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Tools for manipulating UEFI Secure Boot platforms"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/jejb/efitools.git"
SRC_URI="https://git.kernel.org/pub/scm/linux/kernel/git/jejb/efitools.git/snapshot/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="libressl static"

LIB_DEPEND="
	!libressl? ( dev-libs/openssl:0=[static-libs(+)] )
	libressl?  ( dev-libs/libressl:0=[static-libs(+)] )
"

RDEPEND="
	!static? ( ${LIB_DEPEND//\[static-libs(+)]} )
	sys-apps/util-linux
"
DEPEND="
	${RDEPEND}
	app-crypt/sbsigntools
	dev-perl/File-Slurp
	static? ( ${LIB_DEPEND} )
	sys-apps/help2man
	sys-boot/gnu-efi
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/1.7.0-Make.rules.patch"
	"${FILESDIR}/${PN}-1.8.1-libressl-compatibility.patch"
)

src_prepare() {
	if use static ; then
		append-ldflags -static
		sed -i "s/-lcrypto\b/$($(tc-getPKG_CONFIG) --static --libs libcrypto)/g" \
			Makefile || die
	fi

	# respeitar CFLAGS do usuário
	sed -i -e 's/CFLAGS.*= -O2 -g/CFLAGS += /' Make.rules || die
	# respeitar LDFLAGS do usuário
	sed -i -e 's/LDFLAGS/LIBS/g' Make.rules || die
	sed -i -e 's/\$(CC)/& $(LDFLAGS)/g' Makefile || die

	default
}

src_compile() {
	# selecionar toolchain e alvo PE correto por arch
	local -a emkargs=(
		CC="$(tc-getCC)"
		LD="$(tc-getLD)"
		AR="$(tc-getAR)"
		OBJCOPY="$(tc-getOBJCOPY)"
		GNUEFI_INCDIR="/usr/include/efi"
		GNUEFI_LIBDIR="/usr/$(get_libdir)/gnu-efi"
		EFILIB="/usr/$(get_libdir)"
	)

	case "$(tc-arch)" in
		amd64)
			emkargs+=( EFI_ARCH=x64 FORMAT="-O efi-app-x86_64" )
			;;
		arm64)
			emkargs+=( EFI_ARCH=aa64 FORMAT="-O efi-app-aarch64" )
			;;
		x86)
			emkargs+=( EFI_ARCH=ia32 FORMAT="-O efi-app-ia32" )
			;;
		*)
			die "Arquitetura não suportada para geração de PE EFI: $(tc-arch)"
			;;
	esac

	emake "${emkargs[@]}"
}

src_install() {
	# instalar apenas os binários que realmente foram gerados
	local bins=(
		cert-to-efi-sig-list
		sign-efi-sig-list
		efi-readvar
		efi-updatevar
		cert-to-efi-hash-list
		hash-to-efi-sig-list
		sig-list-to-certs
		hash-sig-list
		flash-var
	)
	local b
	for b in "${bins[@]}"; do
		[[ -x ${b} ]] && dobin "${b}"
	done

	# aplicativos EFI, se existirem
	insinto /usr/share/${PN}
	find . -maxdepth 1 -type f -name '*.efi' -print0 | xargs -0 -r doins

	# manpages se existirem
	if compgen -G "doc/*.1" >/dev/null ; then
		doman doc/*.1
	fi

	# docs opcionais, sem falhar caso ausentes
	local docs=(README README.txt README.md COPYING COPYING.LIB LICENSE LICENSE.* USAGE)
	local have_docs=()
	for f in "${docs[@]}"; do
		[[ -e ${f} ]] && have_docs+=( "${f}" )
	done
	[[ ${#have_docs[@]} -gt 0 ]] && dodoc "${have_docs[@]}"
}
