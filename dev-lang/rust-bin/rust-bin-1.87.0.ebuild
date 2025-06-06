# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 prefix toolchain-funcs multilib-minimal

MY_P="rust-${PV}"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="https://www.rust-lang.org/"
SRC_URI="
		abi_x86_64? ( 
		https://static.rust-lang.org/dist/rust-1.87.0-x86_64-unknown-linux-gnu.tar.xz -> rust-1.87.0-x86_64-unknown-linux-gnu.tar.xz
	)
	arm? ( 
		https://static.rust-lang.org/dist/rust-1.87.0-arm-unknown-linux-gnueabi.tar.xz -> rust-1.87.0-arm-unknown-linux-gnueabi.tar.xz
		https://static.rust-lang.org/dist/rust-1.87.0-arm-unknown-linux-gnueabihf.tar.xz -> rust-1.87.0-arm-unknown-linux-gnueabihf.tar.xz
		https://static.rust-lang.org/dist/rust-1.87.0-armv7-unknown-linux-gnueabihf.tar.xz -> rust-1.87.0-armv7-unknown-linux-gnueabihf.tar.xz
	)
	arm64? ( 
		https://static.rust-lang.org/dist/rust-1.87.0-aarch64-unknown-linux-gnu.tar.xz -> rust-1.87.0-aarch64-unknown-linux-gnu.tar.xz
	)
	riscv64? ( 
		https://static.rust-lang.org/dist/rust-1.87.0-riscv64gc-unknown-linux-gnu.tar.xz -> rust-1.87.0-riscv64gc-unknown-linux-gnu.tar.xz
	)
	rust-src? (
		https://static.rust-lang.org/dist/rust-src-1.87.0.tar.xz -> rust-src-1.87.0.tar.xz
	)
	wasm? (
		https://static.rust-lang.org/dist/rust-std-1.87.0-wasm32-unknown-unknown.tar.xz -> rust-std-1.87.0-wasm32-unknown-unknown.tar.xz
	)
	wasm-wasi? (
		https://static.rust-lang.org/dist/rust-std-1.87.0-wasm32-wasip1.tar.xz -> rust-std-1.87.0-wasm32-wasip1.tar.xz
	)
"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="*"
IUSE="clippy cpu_flags_x86_sse2 doc prefix rustfmt rust-src wasm wasm-wasi"
RESTRICT="strip"
DEPEND="app-eselect/eselect-rust"
RDEPEND="${DEPEND}"
BDEPEND="
	prefix? ( dev-util/patchelf )
"

REQUIRED_USE="x86? ( cpu_flags_x86_sse2 )"

QA_PREBUILT="
	opt/${P}/bin/.*
	opt/${P}/lib/.*.so
	opt/${P}/libexec/.*
	opt/${P}/lib/rustlib/.*/bin/.*
	opt/${P}/lib/rustlib/.*/lib/.*
"

# A rmeta file is custom binary format that contains the metadata for the crate.
# Rmeta files do not support linking, since they do not contain compiled object files.
# So we can safely silence the warning for this QA check.
QA_EXECSTACK="opt/${P}/lib/rustlib/*/lib*.rlib:lib.rmeta"

rust_abi() {
	local CTARGET=${1:-${CHOST}}
	case ${CTARGET%%*-} in
		x86_64*) echo x86_64-unknown-linux-gnu;;
		armv6j*s*) echo arm-unknown-linux-gnueabi;;
		armv6j*h*) echo arm-unknown-linux-gnueabihf;;
		armv7a*h*) echo armv7-unknown-linux-gnueabihf;;
		aarch64*) echo aarch64-unknown-linux-gnu;;
		riscv64*) echo riscv64gc-unknown-linux-gnu;;
	esac
}

pkg_pretend() {
	if [[ "$(tc-is-softfloat)" != "no" ]] && [[ ${CHOST} == armv7* ]]; then
		die "${CHOST} is not supported by upstream Rust. You must use a hard float version."
	fi
}

src_unpack() {
	default

	mv "${WORKDIR}/${MY_P}-$(rust_abi)" "${S}" || die
		if use rust-src; then
				mv "${WORKDIR}/rust-src-1.87.0/rust-src" "${S}"/rust-src
		fi
		if use wasm; then
				mv "${WORKDIR}/rust-std-1.87.0-wasm32-unknown-unknown/rust-std-wasm32-unknown-unknown" "${S}"/rust-std-wasm32-unknown-unknown
		fi
		if use wasm-wasi; then
				mv "${WORKDIR}/rust-std-1.87.0-wasm32-wasip1/rust-std-wasm32-wasip1" "${S}"/rust-std-wasm32-wasip1
		fi
}

src_prepare() {
	default
		if use rust-src; then
				echo "rust-src" >> components
		fi
		if use wasm; then
				echo "rust-std-wasm32-unknown-unknown" >> components
		fi
		if use wasm-wasi; then
				echo "rust-std-wasm32-wasip1" >> components
		fi
}

patchelf_for_bin() {
	local filetype=$(file -b ${1})
	if [[ ${filetype} == *ELF*interpreter* ]]; then
		einfo "${1}'s interpreter changed"
		patchelf ${1} --set-interpreter ${2} || die
	elif [[ ${filetype} == *script* ]]; then
		hprefixify ${1}
	fi
}

multilib_src_install() {
	if multilib_is_native_abi; then

	# start native abi install
	pushd "${S}" >/dev/null || die
	local analysis std
	analysis="$(grep -m 1 'analysis' ./components)"
	std="$(grep -m 1 'std' ./components)"
	local components="rustc,cargo,${std}"
	use doc && components="${components},rust-docs"
	use clippy && components="${components},clippy-preview"
	use rustfmt && components="${components},rustfmt-preview"
		use rust-src && components="${components},rust-src"
		use wasm && components="${components},rust-std-wasm32-unknown-unknown"
		use wasm-wasi && components="${components},rust-std-wasm32-wasip1"

	./install.sh \
		--components="${components}" \
		--disable-verify \
		--prefix="${ED}/opt/${P}" \
		--mandir="${ED}/opt/${P}/man" \
		--disable-ldconfig \
		|| die

	if use prefix; then
		local interpreter=$(patchelf --print-interpreter ${EPREFIX}/bin/bash)
		ebegin "Changing interpreter to ${interpreter} for Gentoo prefix at ${ED}/opt/${P}/bin"
		find "${ED}/opt/${P}/bin" -type f -print0 | \
			while IFS=  read -r -d '' filename; do
				patchelf_for_bin ${filename} ${interpreter} \; || die
			done
		eend $?
	fi

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

	# musl logic can be improved a bit, but fine as is for now
	cat <<-_EOF_ > "${T}/50${P}"
	LDPATH="${EPREFIX}/usr/lib/rust/lib"
	MANPATH="${EPREFIX}/usr/lib/rust/man"
	$(use amd64 && usex elibc_musl 'CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=-crt-static"' '')
	$(use arm64 && usex elibc_musl 'CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=-crt-static"' '')
	_EOF_
	doenvd "${T}/50${P}"

	# note: eselect-rust adds EROOT to all paths below
	cat <<-_EOF_ > "${T}/provider-${P}"
	/usr/bin/cargo
	/usr/bin/rustdoc
	/usr/bin/rust-gdb
	/usr/bin/rust-gdbgui
	/usr/bin/rust-lldb
	/usr/lib/rustlib
	/usr/lib/rust/lib
	/usr/lib/rust/man
	/usr/share/doc/rust
	_EOF_

	if use clippy; then
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
	#end native abi install

	else
		local rust_target
		rust_target="$(rust_abi $(get_abi_CHOST ${v##*.}))"
		dodir "/opt/${P}/lib/rustlib"
		cp -vr "${WORKDIR}/rust-${PV}-${rust_target}/rust-std-${rust_target}/lib/rustlib/${rust_target}"\
			"${ED}/opt/${P}/lib/rustlib" || die
	fi

	# BUG: installs x86_64 binary on other arches
	rm -f "${ED}/opt/${P}/lib/rustlib/"*/bin/rust-llvm-dwp || die

	# https://github.com/rust-lang/rust/issues/125619
	# https://github.com/llvm/llvm-project/pull/93890
	# FL-12409.
	#if use arm64; then
	#	if $(tc-getNM) "${ED}/opt/${P}/lib/rustlib/aarch64-unknown-linux-gnu/lib"/libcompiler_builtins-*.rlib |& grep -q "^[[:space:]]* U __builtin_copysignq$"; then
	#		elog "Applying fix for undefined reference to __builtin_copysignq in ARM64 libcompiler_builtins-*.rlib"
	#		$(tc-getCC) ${CPPFLAGS} ${CFLAGS} -c -o "${T}/__builtin_copysignq.o" -x c - <<<"_Float128 __builtin_copysignq(_Float128 x,_Float128 y){return __builtin_copysignf128(x, y);}" || die
	#		$(tc-getAR) r "${ED}/opt/${P}/lib/rustlib/aarch64-unknown-linux-gnu/lib"/libcompiler_builtins-*.rlib "${T}/__builtin_copysignq.o" || die
	#	else
	#		eerror "ARM64 libcompiler_builtins-*.rlib no longer contains undefined reference to __builtin_copysignq"
	#		eerror "Workaround code in ebuild should be deleted"
	#		die "ARM64 libcompiler_builtins-*.rlib no longer contains undefined reference to __builtin_copysignq"
	#	fi
	#fi
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