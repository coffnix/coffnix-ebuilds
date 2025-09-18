# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
EGO_SKIP_TIDY=1
MY_PV="$(ver_cut 1-3)T$(ver_cut 4-7)Z"
MY_PV=${MY_PV//./-}
inherit go-module

DESCRIPTION="Fast tool to manage MinIO clusters"
HOMEPAGE="https://min.io/ https://github.com/minio/mc"
SRC_URI="
https://api.github.com/repos/minio/mc/tarball/RELEASE.2025-08-13T08-35-41Z -> minio-client-2025.08.13-7394ce0.tar.gz
mirror://macaroni/minio-client-2025.08.13-mark-go-bundle-7394ce0.tar.xz -> minio-client-2025.08.13-mark-go-bundle-7394ce0.tar.xz"
LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="*"
BDEPEND="dev-lang/go"
RESTRICT="network-sandbox"


src_prepare() {
	default
	git init -q || die
	git config user.email "builder@local" || die
	git config user.name "builder" || die
	git add -A || die
	export GIT_AUTHOR_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	export GIT_COMMITTER_DATE="${GIT_AUTHOR_DATE}"
	git commit -q -m "snapshot" --allow-empty || die
}

src_unpack() {
	go-module_src_unpack
	mv ${WORKDIR}/minio-mc-* ${S} || die
}

src_compile() {
	unset XDG_CACHE_HOME

	# proxy local do bundle, com fallback para preencher módulos que não vieram no bundle
	local GPROXY="file://${T}/go-proxy,https://proxy.golang.org,direct"
	# remove -mod=readonly que o eclass injeta
	local GFLAGS="${GOFLAGS//-mod=readonly/}"

	export MINIO_RELEASE="${MY_PV}"
	export GOPROXY="${GPROXY}"
	export GOSUMDB="sum.golang.org"
	export GOMODCACHE="${T}/gomod"

	# gera ldflags com o repo git fake
	local LDF
	LDF="$(go run buildscripts/gen-ldflags.go)" || die "gen ldflags falhou"

	# compila usando cache local e, se faltar algo, baixa pela rede
	CGO_ENABLED=0 GOFLAGS="${GFLAGS}" \
		go build -mod=mod --ldflags "${LDF}" -o mc || die "go build falhou"
}

src_install() {
	dobin mc
}

# vim: filetype=ebuild
