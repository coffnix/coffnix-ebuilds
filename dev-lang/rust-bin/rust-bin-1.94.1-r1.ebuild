# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QA_EXECSTACK="opt/${P}/lib/rustlib/*/lib*.rlib:lib.rmeta"
QA_PREBUILT="
opt/${P}/bin/.*
opt/${P}/lib/.*.so
opt/${P}/libexec/.*
opt/${P}/lib/rustlib/.*/bin/.*
opt/${P}/lib/rustlib/.*/lib/.*
"

inherit bash-completion-r1 toolchain-funcs

DESCRIPTION="Empowering everyone to build reliable and efficient software."
HOMEPAGE="https://www.rust-lang.org"
SRC_URI="
amd64? ( https://static.rust-lang.org/dist/rust-1.94.1-x86_64-unknown-linux-gnu.tar.xz -> rust-bin-1.94.1-x86_64-unknown-linux-gnu.tar.xz )
x86? ( https://static.rust-lang.org/dist/rust-1.94.1-i686-unknown-linux-gnu.tar.xz -> rust-bin-1.94.1-i686-unknown-linux-gnu.tar.xz )
arm? ( https://static.rust-lang.org/dist/rust-1.94.1-arm-unknown-linux-gnueabi.tar.xz -> rust-bin-1.94.1-arm-unknown-linux-gnueabi.tar.xz )
arm? ( https://static.rust-lang.org/dist/rust-1.94.1-arm-unknown-linux-gnueabihf.tar.xz -> rust-bin-1.94.1-arm-unknown-linux-gnueabihf.tar.xz )
arm? ( https://static.rust-lang.org/dist/rust-1.94.1-armv7-unknown-linux-gnueabihf.tar.xz -> rust-bin-1.94.1-armv7-unknown-linux-gnueabihf.tar.xz )
arm64? ( https://static.rust-lang.org/dist/rust-1.94.1-aarch64-unknown-linux-gnu.tar.xz -> rust-bin-1.94.1-aarch64-unknown-linux-gnu.tar.xz )
riscv64? ( https://static.rust-lang.org/dist/rust-1.94.1-riscv64gc-unknown-linux-gnu.tar.xz -> rust-bin-1.94.1-riscv64gc-unknown-linux-gnu.tar.xz )
wasm? ( https://static.rust-lang.org/dist/rust-std-1.94.1-wasm32-unknown-unknown.tar.xz -> rust-bin-1.94.1-wasm32-unknown-unknown.tar.xz )
wasm-wasip1? ( https://static.rust-lang.org/dist/rust-std-1.94.1-wasm32-wasip1.tar.xz -> rust-bin-1.94.1-wasm32-wasip1.tar.xz )
wasm-wasip1-threads? ( https://static.rust-lang.org/dist/rust-std-1.94.1-wasm32-wasip1-threads.tar.xz -> rust-bin-1.94.1-wasm32-wasip1-threads.tar.xz )
wasm-wasip2? ( https://static.rust-lang.org/dist/rust-std-1.94.1-wasm32-wasip2.tar.xz -> rust-bin-1.94.1-wasm32-wasip2.tar.xz )"
LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="*"
IUSE="clippy doc rustfmt rust-analyzer
amd64 arm arm64 riscv64
rust-src
wasm
wasm-wasip1
wasm-wasip1-threads
wasm-wasip2
"
RESTRICT="strip"
RDEPEND="app-eselect/eselect-rust
	
"
DEPEND="${RDEPEND}
"
rust_abi() {
	local CTARGET=${1:-${CHOST}}
	case ${CTARGET%%-*} in
	  i?86) echo i686-unknown-linux-gnu;;
	  x86_64*) echo x86_64-unknown-linux-gnu;;
	  armv6j*s*) echo arm-unknown-linux-gnueabi;;
	  armv6j*h*) echo arm-unknown-linux-gnueabihf;;
	  armv7a*h*) echo armv7-unknown-linux-gnueabihf;;
	  aarch64*) echo aarch64-unknown-linux-gnu;;
	  riscv64*) echo riscv64gc-unknown-linux-gnu;;
	esac
}
src_unpack() {
	default
	mv "${WORKDIR}/rust-1.94.1-$(rust_abi)" "${S}" || die
	if use rust-src ; then
	  mv "${WORKDIR}/rust-src-1.94.1/rust-src" "${S}"/rust-src
	fi
	if use wasm ; then
	  mv "${WORKDIR}/rust-std-1.94.1-wasm32-unknown-unknown/rust-std-wasm32-unknown-unknown" "${S}"/rust-std-wasm32-unknown-unknown
	fi
	if use wasm-wasip1 ; then
	  mv "${WORKDIR}/rust-std-1.94.1-wasm32-wasip1/rust-std-wasm32-wasip1" "${S}"/rust-std-wasm32-wasip1
	fi
	if use wasm-wasip1-threads ; then
	  mv "${WORKDIR}/rust-std-1.94.1-wasm32-wasip1-threads/rust-std-wasm32-wasip1-threads" "${S}"/rust-std-wasm32-wasip1-threads
	fi
	if use wasm-wasip2 ; then
	  mv "${WORKDIR}/rust-std-1.94.1-wasm32-wasip2/rust-std-wasm32-wasip2" "${S}"/rust-std-wasm32-wasip2
	fi
}
src_prepare() {
	default
	if use rust-src ; then
	  echo "rust-src" >> components
	fi
	if use wasm ; then
	  echo "rust-std-wasm32-unknown-unknown" >> components
	fi
	if use wasm-wasip1 ; then
	  echo "rust-std-wasm32-wasip1" >> components
	fi
	if use wasm-wasip1-threads ; then
	  echo "rust-std-wasm32-wasip1-threads" >> components
	fi
	if use wasm-wasip2 ; then
	  echo "rust-std-wasm32-wasip2" >> components
	fi
}
src_install() {
	pushd "${S}" >/dev/null || die
	local std="$(grep -m 1 'std' ./components)"
	local components=( "rustc" "cargo" "${std}" )
	use doc && components+=( "rust-docs" )
	use clippy && components+=( "clippy-preview" )
	use rustfmt && components+=( "rustfmt-preview" )
	use rust-src && components="${components},rust-src"
	if use rust-src ; then
	  components+=( "rust-src" )
	fi
	if use wasm ; then
	  components+=( "rust-std-wasm32-unknown-unknown" )
	fi
	if use wasm-wasip1 ; then
	  components+=( "rust-std-wasm32-wasip1" )
	fi
	if use wasm-wasip1-threads ; then
	  components+=( "rust-std-wasm32-wasip1-threads" )
	fi
	if use wasm-wasip2 ; then
	  components+=( "rust-std-wasm32-wasip2" )
	fi
	 if use rust-analyzer; then
	  local analysis="$(grep 'analysis' ./components || die "analysis not found in components")"
	  components+=( "rust-analyzer-preview" "${analysis}" )
	fi
	./install.sh \
	  --components="$(IFS=,; echo "${components[*]}")" \
	  --disable-verify \
	  --prefix="${ED}/opt/${P}" \
	  --mandir="${ED}/opt/${P}/man" \
	  --disable-ldconfig \
	  || die
	 local symlinks=(
	  cargo
	  rustc
	  rustdoc
	  rust-gdb
	  rust-gdbgui
	  rust-lldb
	)
	 use clippy && symlinks+=( clippy-driver cargo-clippy )
	use rustfmt && symlinks+=( rustfmt cargo-fmt )
	 einfo "installing eselect-rust symlinks and paths"
	local i
	for i in "${symlinks[@]}"; do
	  # we need realpath on /usr/bin/* symlink return version-appended binary path.
	  # so /usr/bin/rustc should point to /opt/rust-bin-<ver>/bin/rustc-<ver>
	  local ver_i="${i}-bin-${PV}"
	  ln -v "${ED}/opt/${P}/bin/${i}" "${ED}/opt/${P}/bin/${ver_i}" || die
	  dosym "../../opt/${P}/bin/${ver_i}" "/usr/bin/${ver_i}"
	done
	# symlinks to switch components to active rust in eselect
	dosym "../../../opt/${P}/lib" "/usr/lib/rust/lib-bin-${PV}"
	dosym "../../../opt/${P}/man" "/usr/lib/rust/man-bin-${PV}"
	dosym "../../opt/${P}/lib/rustlib" "/usr/lib/rustlib-bin-${PV}"
	dosym "../../../opt/${P}/share/doc/rust" "/usr/share/doc/${P}"
	 newenvd "${FILESDIR}"/50rust-bin.envd "50${P}"
	 cp "${FILESDIR}"/provider-rust-bin "${T}/provider-${P}"
	 if use clippy ; then
	  echo /usr/bin/clippy-driver >> "${T}/provider-${P}"
	  echo /usr/bin/cargo-clippy >> "${T}/provider-${P}"
	fi
	if use rustfmt; then
	  echo /usr/bin/rustfmt >> "${T}/provider-${P}"
	  echo /usr/bin/cargo-fmt >> "${T}/provider-${P}"
	fi
	 insinto /etc/env.d/rust
	doins "${T}/provider-${P}"
	popd >/dev/null || die
	 rm -f "${ED}/opt/${P}/lib/rustlib/"*/bin/rust-llvm-dwp || die
}
pkg_postinst() {
	eselect rust update || die
	elog "Rust installs a helper script for calling GDB now,"
	elog "for your convenience it is installed under /usr/bin/rust-gdb-bin-${PV}."
	if has_version app-editors/emacs; then
	  elog "install app-emacs/rust-mode to get emacs support for rust."
	fi
	if has_version app-editors/gvim || has_version app-editors/vim; then
	  elog "install app-vim/rust-vim to get vim support for rust."
	fi
}
pkg_postrm() {
	eselect rust cleanup || die
}


# vim: filetype=ebuild
