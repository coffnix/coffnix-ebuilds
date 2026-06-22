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
amd64? ( https://static.rust-lang.org/dist/rust-${PV}-x86_64-unknown-linux-gnu.tar.xz -> ${P}-x86_64-unknown-linux-gnu.tar.xz )
x86? ( https://static.rust-lang.org/dist/rust-${PV}-i686-unknown-linux-gnu.tar.xz -> ${P}-i686-unknown-linux-gnu.tar.xz )
arm? ( https://static.rust-lang.org/dist/rust-${PV}-armv7-unknown-linux-gnueabihf.tar.xz -> ${P}-armv7-unknown-linux-gnueabihf.tar.xz )
arm64? ( https://static.rust-lang.org/dist/rust-${PV}-aarch64-unknown-linux-gnu.tar.xz -> ${P}-aarch64-unknown-linux-gnu.tar.xz )
riscv64? ( https://static.rust-lang.org/dist/rust-${PV}-riscv64gc-unknown-linux-gnu.tar.xz -> ${P}-riscv64gc-unknown-linux-gnu.tar.xz )
rust-src? ( https://static.rust-lang.org/dist/rust-src-${PV}.tar.xz -> ${P}-rust-src.tar.xz )
wasm? ( https://static.rust-lang.org/dist/rust-std-${PV}-wasm32-unknown-unknown.tar.xz -> ${P}-wasm32-unknown-unknown.tar.xz )
wasm-wasip1? ( https://static.rust-lang.org/dist/rust-std-${PV}-wasm32-wasip1.tar.xz -> ${P}-wasm32-wasip1.tar.xz )
wasm-wasip1-threads? ( https://static.rust-lang.org/dist/rust-std-${PV}-wasm32-wasip1-threads.tar.xz -> ${P}-wasm32-wasip1-threads.tar.xz )
wasm-wasip2? ( https://static.rust-lang.org/dist/rust-std-${PV}-wasm32-wasip2.tar.xz -> ${P}-wasm32-wasip2.tar.xz )
"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="*"

IUSE="
clippy
doc
rustfmt
rust-analyzer
amd64
arm
arm64
riscv64
rust-src
wasm
wasm-wasip1
wasm-wasip1-threads
wasm-wasip2
"

RESTRICT="strip"

RDEPEND="
	app-eselect/eselect-rust
"

DEPEND="${RDEPEND}"

rust_abi() {
	local CTARGET=${1:-${CHOST}}

	case ${CTARGET} in
		i?86-*)
			echo i686-unknown-linux-gnu
			;;
		x86_64-*)
			echo x86_64-unknown-linux-gnu
			;;
		armv7a-unknown-linux-gnueabihf|armv7*-*-linux-gnueabihf)
			echo armv7-unknown-linux-gnueabihf
			;;
		arm*-*-linux-gnueabihf)
			echo armv7-unknown-linux-gnueabihf
			;;
		aarch64-*)
			echo aarch64-unknown-linux-gnu
			;;
		riscv64-*)
			echo riscv64gc-unknown-linux-gnu
			;;
		*)
			die "Unsupported target: ${CTARGET}"
			;;
	esac
}

src_unpack() {
	default

	mv "${WORKDIR}/rust-${PV}-$(rust_abi)" "${S}" || die

	if use rust-src ; then
		mv "${WORKDIR}/rust-src-${PV}/rust-src" "${S}/rust-src" || die
	fi

	if use wasm ; then
		mv "${WORKDIR}/rust-std-${PV}-wasm32-unknown-unknown/rust-std-wasm32-unknown-unknown" "${S}/rust-std-wasm32-unknown-unknown" || die
	fi

	if use wasm-wasip1 ; then
		mv "${WORKDIR}/rust-std-${PV}-wasm32-wasip1/rust-std-wasm32-wasip1" "${S}/rust-std-wasm32-wasip1" || die
	fi

	if use wasm-wasip1-threads ; then
		mv "${WORKDIR}/rust-std-${PV}-wasm32-wasip1-threads/rust-std-wasm32-wasip1-threads" "${S}/rust-std-wasm32-wasip1-threads" || die
	fi

	if use wasm-wasip2 ; then
		mv "${WORKDIR}/rust-std-${PV}-wasm32-wasip2/rust-std-wasm32-wasip2" "${S}/rust-std-wasm32-wasip2" || die
	fi
}

src_prepare() {
	default

	use rust-src && echo "rust-src" >> components
	use wasm && echo "rust-std-wasm32-unknown-unknown" >> components
	use wasm-wasip1 && echo "rust-std-wasm32-wasip1" >> components
	use wasm-wasip1-threads && echo "rust-std-wasm32-wasip1-threads" >> components
	use wasm-wasip2 && echo "rust-std-wasm32-wasip2" >> components
}

src_install() {
	pushd "${S}" >/dev/null || die

	local std
	std="$(grep -m 1 '^rust-std-' ./components)" || die "rust std component not found"

	local components=( "rustc" "cargo" "${std}" )

	use doc && components+=( "rust-docs" )
	use clippy && components+=( "clippy-preview" )
	use rustfmt && components+=( "rustfmt-preview" )
	use rust-src && components+=( "rust-src" )
	use wasm && components+=( "rust-std-wasm32-unknown-unknown" )
	use wasm-wasip1 && components+=( "rust-std-wasm32-wasip1" )
	use wasm-wasip1-threads && components+=( "rust-std-wasm32-wasip1-threads" )
	use wasm-wasip2 && components+=( "rust-std-wasm32-wasip2" )

	if use rust-analyzer ; then
		local analysis
		analysis="$(grep 'analysis' ./components)" || die "analysis not found in components"
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
		local ver_i="${i}-bin-${PV}"
		ln -v "${ED}/opt/${P}/bin/${i}" "${ED}/opt/${P}/bin/${ver_i}" || die
		dosym "../../opt/${P}/bin/${ver_i}" "/usr/bin/${ver_i}"
	done

	dosym "../../../opt/${P}/lib" "/usr/lib/rust/lib-bin-${PV}"
	dosym "../../../opt/${P}/man" "/usr/lib/rust/man-bin-${PV}"
	dosym "../../opt/${P}/lib/rustlib" "/usr/lib/rustlib-bin-${PV}"
	dosym "../../../opt/${P}/share/doc/rust" "/usr/share/doc/${P}"

	newenvd "${FILESDIR}/50rust-bin.envd" "50${P}"

	cp "${FILESDIR}/provider-rust-bin" "${T}/provider-${P}" || die

	if use clippy ; then
		echo /usr/bin/clippy-driver >> "${T}/provider-${P}"
		echo /usr/bin/cargo-clippy >> "${T}/provider-${P}"
	fi

	if use rustfmt ; then
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

	if has_version app-editors/emacs ; then
		elog "install app-emacs/rust-mode to get emacs support for rust."
	fi

	if has_version app-editors/gvim || has_version app-editors/vim ; then
		elog "install app-vim/rust-vim to get vim support for rust."
	fi
}

pkg_postrm() {
	eselect rust cleanup || die
}

# vim: filetype=ebuild
