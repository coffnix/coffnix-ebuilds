# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
RESTRICT="strip"
QA_EXECSTACK='*.syso'
QA_FLAGS_IGNORED='.*'
QA_MULTILIB_PATHS="usr/lib/go/pkg/tool/.*/.*"
QA_PREBUILT='.*'
export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}
inherit toolchain-funcs

DESCRIPTION="A concurrent garbage collected and typesafe programming language"
HOMEPAGE="https://golang.org"
SRC_URI="
https://go.dev/dl/go1.23.8.src.tar.gz -> go1.23.8.src.tar.gz
amd64? ( https://go.dev/dl/go1.23.8.linux-amd64.tar.gz -> go1.23.8-bootstrap.linux-amd64.tar.gz )
arm64? ( https://go.dev/dl/go1.23.8.linux-arm64.tar.gz -> go1.23.8-bootstrap.linux-arm64.tar.gz )
armv6? ( https://go.dev/dl/go1.23.8.linux-armv6l.tar.gz -> go1.23.8-bootstrap.linux-armv6l.tar.gz )"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/go-never-download-newer-toolchains.patch"
)
DOCS=(
	CONTRIBUTING.md
	PATENTS
	README.md
	SECURITY.md
)
IUSE="amd64 arm64 armv6"
S="${WORKDIR}/go"
src_unpack() {
	  for i in amd64 arm64 armv6 ; do
	      if use $i ; then
	          if [ $i = "armv6" ] ; then
	              i=${i}l
	          fi
	          unpack go1.23.8-bootstrap.linux-${i}.tar.gz || die
	          mv ${WORKDIR}/go ${WORKDIR}/go-bootstrap
	          break
	      fi
	  done
	  unpack go1.23.8.src.tar.gz || die
}

src_compile() {
	if has_version -b dev-lang/go; then
	  export GOROOT_BOOTSTRAP="${BROOT}/usr/lib/go"
	else
	  # Using bootstrap tarball.
	  export GOROOT_BOOTSTRAP="${WORKDIR}/go-bootstrap"
	fi
	 CARCH=${CHOST%%-*}
	 case "$CARCH" in
	  aarch64) export GOARCH="arm64" ;;
	  armel)   export GOARCH="arm" GOARM=5 ;;
	  armhf)   export GOARCH="arm" GOARM=6 ;;
	  armv7)   export GOARCH="arm" GOARM=7 ;;
	  s390x)   export GOARCH="s390x" ;;
	  x86)     export GOARCH="386" ;;
	  x86_64)  export GOARCH="amd64" ;;
	  ppc64)   export GOARCH="ppc64" ;;
	  ppc64le) export GOARCH="ppc64le" ;;
	  riscv64) export GOARCH="riscv64" ;;
	  loongarch64) export GOARCH="loong64" ;;
	  *)       export GOARCH="unsupported";;
	esac
	 case "$CARCH" in
	x86_64|s390x|aarch64) export GO_LDFLAGS=-buildmode=pie ;;
	esac
	 export GOROOT_FINAL="${EPREFIX}"/usr/lib/go
	export GOROOT="${PWD}"
	export GOBIN="${GOROOT}/bin"
	export GOCACHE="${T}/go-build"
	export CC=$(tc-getBUILD_CC)
	export GOOS="linux"
	export CC_FOR_TARGET=$(tc-getCC)
	export CXX_FOR_TARGET=$(tc-getCXX)
	use armv6 && export GOARM=6
	 cd src
	bash -x ./make.bash || die "build failed"
}

src_install() {
	dodir /usr/lib/go
	cp -R api bin doc lib pkg misc src test "${ED}"/usr/lib/go
	einstalldocs
	 if [ -f go.env ]; then
	  insinto /usr/lib/go
	  doins go.env
	fi
	 # testdata directories are not needed on the installed system
	rm -fr $(find "${ED}"/usr/lib/go -iname testdata -type d -print)
	local bin_path=bin
	local f x
	for x in ${bin_path}/*; do
	  f=${x##*/}
	  dosym ../lib/go/${bin_path}/${f} /usr/bin/${f}
	done
}


# vim: filetype=ebuild
