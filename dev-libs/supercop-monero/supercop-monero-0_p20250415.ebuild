# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Fast cryptographic operations for Monero wallets"
HOMEPAGE="https://bench.cr.yp.to/supercop.html"
SRC_URI="https://bench.cr.yp.to/supercop/supercop-20250415.tar.xz"

S="${WORKDIR}/supercop-20250415"

LICENSE="public-domain BSD"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-lang/nasm"
RDEPEND="${DEPEND}"

src_prepare() {
	default

	local base="${S}/crypto_sign/ed25519/ref10"

	cat > "${base}/crypto_verify_32.h" <<-EOF || die "falha ao criar crypto_verify_32.h"
#ifndef SUPERCOP_CRYPTO_VERIFY_32_H
#define SUPERCOP_CRYPTO_VERIFY_32_H

static inline int crypto_verify_32(const unsigned char *x, const unsigned char *y) {
	int i;
	unsigned int d = 0;
	for (i = 0; i < 32; ++i)
		d |= x[i] ^ y[i];
	return (1 & ((d - 1) >> 8)) - 1;
}

#endif
EOF
	cat > "${base}/crypto_hash_sha512.h" <<-EOF || die
	#ifndef SUPERCOP_CRYPTO_HASH_SHA512_H
	#define SUPERCOP_CRYPTO_HASH_SHA512_H

	#define crypto_hash_sha512 crypto_hash_sha512_ref
	#define crypto_hash_sha512_BYTES 64

	int crypto_hash_sha512(unsigned char *, const unsigned char *, unsigned long long);

	#endif
	EOF

	cat > "${base}/crypto_sign.h" <<-EOF || die "falha ao criar crypto_sign.h"
	#ifndef SUPERCOP_CRYPTO_SIGN_H
	#define SUPERCOP_CRYPTO_SIGN_H

	#define crypto_sign_ref10 crypto_sign_ed25519_ref10
	#define crypto_sign_keypair_ref10 crypto_sign_ed25519_ref10_keypair
	#define crypto_sign_bytes_ref10 64
	#define crypto_sign_publickeybytes_ref10 32
	#define crypto_sign_secretkeybytes_ref10 64

	int crypto_sign_ref10(unsigned char *, unsigned long long *,
	                      const unsigned char *, unsigned long long,
	                      const unsigned char *);

	int crypto_sign_ed25519_ref10_keypair(unsigned char *pk, unsigned char *sk);

	#endif
	EOF

	cat > "${base}/fe_isnegative.h" <<-EOF || die "falha ao criar fe_isnegative.h"
	#ifndef SUPERCOP_FE_ISNEGATIVE_H
	#define SUPERCOP_FE_ISNEGATIVE_H

	#include "fe.h"

	int fe_isnegative(const fe f);

	#endif
	EOF

	cat > "${base}/fe_isnegative.c" <<-EOF || die "falha ao criar fe_isnegative.c"
	#include "fe.h"

	int fe_isnegative(const fe f) {
	  unsigned char s[32];
	  fe_tobytes(s, f);
	  return s[0] & 1;
	}
	EOF

	cat > "${base}/fe_tobytes.h" <<-EOF || die "falha ao criar fe_tobytes.h"
	#ifndef SUPERCOP_FE_TOBYTES_H
	#define SUPERCOP_FE_TOBYTES_H

	#include "fe.h"

	void fe_tobytes(unsigned char *s, const fe h);

	#endif
	EOF

	sed -i 's/#include "fe_isnegative.c"/#include "fe_isnegative.h"/' "${base}/ge_p3_tobytes.c" || die
	sed -i 's/#include "fe_tobytes.c"/#include "fe_tobytes.h"/' "${base}/ge_p3_tobytes.c" || die
}

src_compile() {
  local cc=$(tc-getCC)
  local ref10="${S}/crypto_sign/ed25519/ref10"
  local ref="${S}/crypto_sign/ed25519/ref"
  local hash="${S}/crypto_hash/sha512/ref"
  local rnd="${S}/include"
  local int="${S}/cryptoint"
  local krb="${S}/kernelrandombytes"

  cd "${ref10}" || die

  local sources_ref10=(
    keypair.c sign.c open.c fe_isnegative.c ge_p3_tobytes.c fe_tobytes.c
  )

  local sources_ref=(
    ge25519.c sc25519.c fe25519.c
  )

  for src in "${sources_ref10[@]}"; do
    ${cc} -DCRYPTO_NAMESPACE\(x\)=x ${CFLAGS} \
      -I"${ref10}" -I"${hash}" -I"${rnd}" -I"${int}" -I"${krb}" \
      -fPIC -c "${ref10}/${src}" -o "${src%.c}.o" || die
  done

  for src in "${sources_ref[@]}"; do
    ${cc} -DCRYPTO_NAMESPACE\(x\)=x ${CFLAGS} \
      -I"${ref}" -I"${hash}" -I"${rnd}" -I"${int}" -I"${krb}" \
      -fPIC -c "${ref}/${src}" -o "${src%.c}.o" || die
  done

  ar rcs libsupercop-ed25519-ref10.a *.o || die
}

src_install() {
	insinto /usr/include/supercop/ed25519
	doins "${S}/crypto_sign/ed25519/ref10/"*.h

	insinto /usr/lib
	doins "${S}/crypto_sign/ed25519/ref10/libsupercop-ed25519-ref10.a"
}

