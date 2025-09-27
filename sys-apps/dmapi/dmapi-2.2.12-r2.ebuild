# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils toolchain-funcs

DESCRIPTION="XFS data management API library"
HOMEPAGE="https://xfs.wiki.kernel.org/"
SRC_URI="ftp://oss.sgi.com/projects/xfs/cmd_tars/${P}.tar.gz
	ftp://oss.sgi.com/projects/xfs/previous/cmd_tars/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND="sys-fs/xfsprogs"
DEPEND="${RDEPEND}"

src_prepare() {
	# Ajusta docdir no build system
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		include/builddefs.in \
		|| die

	# Patch de headers jÃ¡ existente
	epatch "${FILESDIR}/${P}-headers.patch"

	# Fix arm64 sem depender de <linux/dirent.h>
	if [[ ${ARCH} == arm64 ]]; then
		# remove qualquer include antigo
		sed -i '/<linux\/dirent.h>/d' libdm/getdents.c || die
		# injeta definiÃ§Ã£o mÃ­nima de struct linux_dirent64
		sed -i '/#include <sys\/syscall.h>/a \
#if defined(__aarch64__)\n#include <stdint.h>\nstruct linux_dirent64 { uint64_t d_ino; int64_t d_off; unsigned short d_reclen; unsigned char d_type; char d_name[]; };\n#endif' \
			libdm/getdents.c || die
		# troca syscall
		sed -i 's/\bSYS_getdents\b/SYS_getdents64/' libdm/getdents.c || die
		einfo "Aplicado fallback getdents64 com struct local no arm64"
	fi
}

src_configure() {
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		--libexecdir=/usr/libexec \
		$(use_enable static-libs static)
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install install-dev

	# remover lixo multilib em arm64
	if [[ ${ARCH} == arm64 ]]; then
		rm -f "${ED}/usr/lib/libdm.so" || die
		rm -f "${ED}/usr/lib/libdm.la" 2>/dev/null
		rmdir -p --ignore-fail-on-non-empty "${ED}/usr/lib" 2>/dev/null
	fi

	# descomprimir doc para nÃ£o conflitar com docompress
	if [[ -f "${ED}/usr/share/doc/${PF}/CHANGES.gz" ]]; then
		gunzip -f "${ED}/usr/share/doc/${PF}/CHANGES.gz" || die
	fi

	# remover .la
	find "${ED}" -name '*.la' -type f -delete || die

	# limpar COPYING duplicado no docdir
	rm -f "${ED}/usr/share/doc/${PF}/COPYING"
}
