# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
CRATES="
adler2-2.0.0
ahash-0.8.11
aho-corasick-1.1.3
allocator-api2-0.2.18
anstream-0.6.14
anstyle-1.0.7
anstyle-parse-0.2.4
anstyle-query-1.1.0
anstyle-wincon-3.0.3
anyhow-1.0.89
arbitrary-1.4.1
autocfg-1.3.0
automod-1.0.14
base64-0.21.7
base64-0.22.1
bitflags-1.3.2
bitflags-2.5.0
block-buffer-0.10.4
boxcar-0.2.8
bstr-1.10.0
bumpalo-3.16.0
byteorder-1.5.0
bytes-1.9.0
bytesize-1.3.0
bzip2-0.5.2
bzip2-sys-0.1.13+1.0.8
cab-0.6.0
camino-1.1.9
cargo-config2-0.1.26
cargo-options-0.7.4
cargo-platform-0.1.8
cargo-xwin-0.18.4
cargo-zigbuild-0.20.0
cargo_metadata-0.19.0
cbindgen-0.28.0
cc-1.2.16
cfb-0.10.0
cfg-if-1.0.0
charset-0.1.5
chumsky-0.9.3
clap-4.5.7
clap_builder-4.5.7
clap_complete-4.5.5
clap_complete_command-0.6.1
clap_complete_nushell-4.5.2
clap_derive-4.5.5
clap_lex-0.7.1
cli-table-0.4.7
colorchoice-1.0.1
configparser-3.1.0
console-0.15.8
content_inspector-0.2.4
core-foundation-0.9.4
core-foundation-sys-0.8.6
cpufeatures-0.2.12
crc-3.2.1
crc-catalog-2.4.0
crc32fast-1.4.2
crossbeam-channel-0.5.15
crossbeam-deque-0.8.5
crossbeam-epoch-0.9.18
crossbeam-utils-0.8.20
crypto-common-0.1.6
data-encoding-2.6.0
deranged-0.3.11
derive_arbitrary-1.4.1
dialoguer-0.11.0
diff-0.1.13
digest-0.10.7
dirs-5.0.1
dirs-sys-0.4.1
displaydoc-0.2.5
dissimilar-1.0.9
dunce-1.0.5
dyn-clone-1.0.17
either-1.13.0
encode_unicode-0.3.6
encoding_rs-0.8.34
equivalent-1.0.1
errno-0.3.9
expect-test-1.5.0
fastrand-2.1.0
fat-macho-0.4.9
filetime-0.2.23
flate2-1.0.33
fnv-1.0.7
foreign-types-0.3.2
foreign-types-shared-0.1.1
form_urlencoded-1.2.1
fs-err-3.0.0
fs4-0.12.0
futures-0.3.30
futures-channel-0.3.31
futures-core-0.3.31
futures-executor-0.3.30
futures-io-0.3.31
futures-macro-0.3.31
futures-sink-0.3.31
futures-task-0.3.31
futures-timer-3.0.3
futures-util-0.3.31
generic-array-0.14.7
getrandom-0.2.15
glob-0.3.1
globset-0.4.15
goblin-0.9.2
hashbrown-0.14.5
hashbrown-0.15.2
heck-0.4.1
heck-0.5.0
home-0.5.9
humantime-2.1.0
humantime-serde-1.1.1
icu_collections-1.5.0
icu_locid-1.5.0
icu_locid_transform-1.5.0
icu_locid_transform_data-1.5.0
icu_normalizer-1.5.0
icu_normalizer_data-1.5.0
icu_properties-1.5.1
icu_properties_data-1.5.0
icu_provider-1.5.0
icu_provider_macros-1.5.0
idna-1.0.3
idna_adapter-1.2.0
ignore-0.4.23
indexmap-2.6.0
indicatif-0.17.9
indoc-2.0.5
is_terminal_polyfill-1.70.0
itertools-0.12.1
itertools-0.13.0
itoa-1.0.11
js-sys-0.3.73
keyring-2.3.3
lazy_static-1.4.0
lddtree-0.3.7
libc-0.2.167
libmimalloc-sys-0.1.39
libredox-0.1.3
linux-keyutils-0.2.4
linux-raw-sys-0.4.14
litemap-0.7.3
lock_api-0.4.12
lockfree-object-pool-0.1.6
log-0.4.22
lzma-sys-0.1.20
lzxd-0.2.5
mailparse-0.15.0
matchers-0.1.0
memchr-2.7.4
mimalloc-0.1.43
mime-0.3.17
mime_guess-2.0.4
minijinja-2.5.0
minimal-lexical-0.2.1
miniz_oxide-0.8.0
msi-0.8.0
multipart-0.18.0
native-tls-0.2.12
nom-7.1.3
normalize-line-endings-0.3.0
normpath-1.2.0
nu-ansi-term-0.46.0
num-conv-0.1.0
number_prefix-0.4.0
once_cell-1.20.2
openssl-0.10.72
openssl-macros-0.1.1
openssl-probe-0.1.5
openssl-sys-0.9.107
option-ext-0.2.0
os_pipe-1.2.0
overload-0.1.1
parking_lot-0.12.3
parking_lot_core-0.9.10
paste-1.0.15
path-slash-0.2.1
pep440_rs-0.7.3
pep508_rs-0.9.2
percent-encoding-2.3.1
pin-project-lite-0.2.15
pin-utils-0.1.0
pkg-config-0.3.30
plain-0.2.3
platform-info-2.0.3
portable-atomic-1.6.0
powerfmt-0.2.0
ppv-lite86-0.2.17
pretty_assertions-1.4.1
proc-macro-crate-3.1.0
proc-macro2-1.0.92
psm-0.1.21
pyproject-toml-0.13.4
python-pkginfo-0.6.5
quote-1.0.37
quoted_printable-0.5.0
rand-0.8.5
rand_chacha-0.3.1
rand_core-0.6.4
rayon-1.10.0
rayon-core-1.12.1
redox_syscall-0.4.1
redox_syscall-0.5.1
redox_users-0.4.5
regex-1.11.1
regex-automata-0.1.10
regex-automata-0.4.9
regex-syntax-0.6.29
regex-syntax-0.8.5
relative-path-1.9.3
rfc2047-decoder-1.0.6
ring-0.17.13
rstest-0.22.0
rstest_macros-0.22.0
rustc-hash-2.0.0
rustc_version-0.4.1
rustflags-0.1.6
rustix-0.38.41
rustls-0.23.19
rustls-pemfile-2.1.3
rustls-pki-types-1.10.0
rustls-webpki-0.102.8
rustversion-1.0.18
ryu-1.0.18
same-file-1.0.6
schannel-0.1.23
schemars-0.8.21
schemars_derive-0.8.21
scopeguard-1.2.0
scroll-0.12.0
scroll_derive-0.12.0
security-framework-2.11.0
security-framework-sys-2.11.0
semver-1.0.23
serde-1.0.217
serde_derive-1.0.217
serde_derive_internals-0.29.1
serde_json-1.0.135
serde_spanned-0.6.8
sha2-0.10.8
sharded-slab-0.1.7
shell-words-1.1.0
shlex-1.3.0
simd-adler32-0.3.7
similar-2.5.0
slab-0.4.9
smallvec-1.13.2
smawk-0.3.2
snapbox-0.6.16
snapbox-macros-0.3.10
socks-0.3.4
stable_deref_trait-1.2.0
stacker-0.1.15
static_assertions-1.1.0
strsim-0.11.1
subtle-2.5.0
syn-2.0.90
synstructure-0.13.1
tar-0.4.43
target-lexicon-0.13.1
tempfile-3.11.0
termcolor-1.4.1
terminal_size-0.3.0
textwrap-0.16.1
thiserror-1.0.69
thiserror-2.0.3
thiserror-impl-1.0.69
thiserror-impl-2.0.3
thread_local-1.1.8
time-0.3.36
time-core-0.1.2
time-macros-0.2.18
tinystr-0.7.6
toml-0.8.19
toml_datetime-0.6.8
toml_edit-0.21.1
toml_edit-0.22.22
tracing-0.1.41
tracing-attributes-0.1.28
tracing-core-0.1.33
tracing-log-0.2.0
tracing-serde-0.2.0
tracing-subscriber-0.3.19
trycmd-0.15.6
twox-hash-1.6.3
typenum-1.17.0
unicase-2.7.0
unicode-ident-1.0.12
unicode-linebreak-0.1.5
unicode-width-0.1.13
unicode-width-0.2.0
unicode-xid-0.2.6
unscanny-0.1.0
untrusted-0.9.0
ureq-2.11.0
url-2.5.4
urlencoding-2.1.3
utf16_iter-1.0.5
utf8_iter-1.0.4
utf8parse-0.2.2
uuid-1.8.0
valuable-0.1.0
vcpkg-0.2.15
version-ranges-0.1.1
version_check-0.9.4
versions-6.2.0
wait-timeout-0.2.0
walkdir-2.5.0
wasi-0.11.0+wasi-snapshot-preview1
wasm-bindgen-0.2.96
wasm-bindgen-backend-0.2.96
wasm-bindgen-macro-0.2.96
wasm-bindgen-macro-support-0.2.96
wasm-bindgen-shared-0.2.96
web-time-1.1.0
webpki-roots-0.26.2
which-7.0.0
wild-2.2.1
winapi-0.3.9
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.8
winapi-x86_64-pc-windows-gnu-0.4.0
windows-sys-0.48.0
windows-sys-0.52.0
windows-targets-0.48.5
windows-targets-0.52.5
windows_aarch64_gnullvm-0.48.5
windows_aarch64_gnullvm-0.52.5
windows_aarch64_msvc-0.48.5
windows_aarch64_msvc-0.52.5
windows_i686_gnu-0.48.5
windows_i686_gnu-0.52.5
windows_i686_gnullvm-0.52.5
windows_i686_msvc-0.48.5
windows_i686_msvc-0.52.5
windows_x86_64_gnu-0.48.5
windows_x86_64_gnu-0.52.5
windows_x86_64_gnullvm-0.48.5
windows_x86_64_gnullvm-0.52.5
windows_x86_64_msvc-0.48.5
windows_x86_64_msvc-0.52.5
winnow-0.5.40
winnow-0.6.20
winsafe-0.0.19
write16-1.0.0
writeable-0.5.5
xattr-1.3.1
xwin-0.6.5
xz2-0.1.7
yansi-1.0.1
yoke-0.7.4
yoke-derive-0.7.5
zerocopy-0.7.35
zerocopy-derive-0.7.35
zerofrom-0.1.4
zerofrom-derive-0.1.5
zeroize-1.8.1
zerovec-0.10.4
zerovec-derive-0.10.3
zip-2.3.0
zopfli-0.8.1
"

inherit cargo distutils-r1

DESCRIPTION="Build and publish crates with pyo3, cffi and uniffi bindings as well as rust binaries as python packages"
HOMEPAGE="https://github.com/pyo3/maturin https://pypi.org/project/maturin/"
SRC_URI="https://crates.io/api/v1/crates/adler2/2.0.0/download -> adler2-2.0.0.crate
https://crates.io/api/v1/crates/ahash/0.8.11/download -> ahash-0.8.11.crate
https://crates.io/api/v1/crates/aho-corasick/1.1.3/download -> aho-corasick-1.1.3.crate
https://crates.io/api/v1/crates/allocator-api2/0.2.18/download -> allocator-api2-0.2.18.crate
https://crates.io/api/v1/crates/anstream/0.6.14/download -> anstream-0.6.14.crate
https://crates.io/api/v1/crates/anstyle/1.0.7/download -> anstyle-1.0.7.crate
https://crates.io/api/v1/crates/anstyle-parse/0.2.4/download -> anstyle-parse-0.2.4.crate
https://crates.io/api/v1/crates/anstyle-query/1.1.0/download -> anstyle-query-1.1.0.crate
https://crates.io/api/v1/crates/anstyle-wincon/3.0.3/download -> anstyle-wincon-3.0.3.crate
https://crates.io/api/v1/crates/anyhow/1.0.89/download -> anyhow-1.0.89.crate
https://crates.io/api/v1/crates/arbitrary/1.4.1/download -> arbitrary-1.4.1.crate
https://crates.io/api/v1/crates/autocfg/1.3.0/download -> autocfg-1.3.0.crate
https://crates.io/api/v1/crates/automod/1.0.14/download -> automod-1.0.14.crate
https://crates.io/api/v1/crates/base64/0.21.7/download -> base64-0.21.7.crate
https://crates.io/api/v1/crates/base64/0.22.1/download -> base64-0.22.1.crate
https://crates.io/api/v1/crates/bitflags/1.3.2/download -> bitflags-1.3.2.crate
https://crates.io/api/v1/crates/bitflags/2.5.0/download -> bitflags-2.5.0.crate
https://crates.io/api/v1/crates/block-buffer/0.10.4/download -> block-buffer-0.10.4.crate
https://crates.io/api/v1/crates/boxcar/0.2.8/download -> boxcar-0.2.8.crate
https://crates.io/api/v1/crates/bstr/1.10.0/download -> bstr-1.10.0.crate
https://crates.io/api/v1/crates/bumpalo/3.16.0/download -> bumpalo-3.16.0.crate
https://crates.io/api/v1/crates/byteorder/1.5.0/download -> byteorder-1.5.0.crate
https://crates.io/api/v1/crates/bytes/1.9.0/download -> bytes-1.9.0.crate
https://crates.io/api/v1/crates/bytesize/1.3.0/download -> bytesize-1.3.0.crate
https://crates.io/api/v1/crates/bzip2/0.5.2/download -> bzip2-0.5.2.crate
https://crates.io/api/v1/crates/bzip2-sys/0.1.13+1.0.8/download -> bzip2-sys-0.1.13+1.0.8.crate
https://crates.io/api/v1/crates/cab/0.6.0/download -> cab-0.6.0.crate
https://crates.io/api/v1/crates/camino/1.1.9/download -> camino-1.1.9.crate
https://crates.io/api/v1/crates/cargo-config2/0.1.26/download -> cargo-config2-0.1.26.crate
https://crates.io/api/v1/crates/cargo-options/0.7.4/download -> cargo-options-0.7.4.crate
https://crates.io/api/v1/crates/cargo-platform/0.1.8/download -> cargo-platform-0.1.8.crate
https://crates.io/api/v1/crates/cargo-xwin/0.18.4/download -> cargo-xwin-0.18.4.crate
https://crates.io/api/v1/crates/cargo-zigbuild/0.20.0/download -> cargo-zigbuild-0.20.0.crate
https://crates.io/api/v1/crates/cargo_metadata/0.19.0/download -> cargo_metadata-0.19.0.crate
https://crates.io/api/v1/crates/cbindgen/0.28.0/download -> cbindgen-0.28.0.crate
https://crates.io/api/v1/crates/cc/1.2.16/download -> cc-1.2.16.crate
https://crates.io/api/v1/crates/cfb/0.10.0/download -> cfb-0.10.0.crate
https://crates.io/api/v1/crates/cfg-if/1.0.0/download -> cfg-if-1.0.0.crate
https://crates.io/api/v1/crates/charset/0.1.5/download -> charset-0.1.5.crate
https://crates.io/api/v1/crates/chumsky/0.9.3/download -> chumsky-0.9.3.crate
https://crates.io/api/v1/crates/clap/4.5.7/download -> clap-4.5.7.crate
https://crates.io/api/v1/crates/clap_builder/4.5.7/download -> clap_builder-4.5.7.crate
https://crates.io/api/v1/crates/clap_complete/4.5.5/download -> clap_complete-4.5.5.crate
https://crates.io/api/v1/crates/clap_complete_command/0.6.1/download -> clap_complete_command-0.6.1.crate
https://crates.io/api/v1/crates/clap_complete_nushell/4.5.2/download -> clap_complete_nushell-4.5.2.crate
https://crates.io/api/v1/crates/clap_derive/4.5.5/download -> clap_derive-4.5.5.crate
https://crates.io/api/v1/crates/clap_lex/0.7.1/download -> clap_lex-0.7.1.crate
https://crates.io/api/v1/crates/cli-table/0.4.7/download -> cli-table-0.4.7.crate
https://crates.io/api/v1/crates/colorchoice/1.0.1/download -> colorchoice-1.0.1.crate
https://crates.io/api/v1/crates/configparser/3.1.0/download -> configparser-3.1.0.crate
https://crates.io/api/v1/crates/console/0.15.8/download -> console-0.15.8.crate
https://crates.io/api/v1/crates/content_inspector/0.2.4/download -> content_inspector-0.2.4.crate
https://crates.io/api/v1/crates/core-foundation/0.9.4/download -> core-foundation-0.9.4.crate
https://crates.io/api/v1/crates/core-foundation-sys/0.8.6/download -> core-foundation-sys-0.8.6.crate
https://crates.io/api/v1/crates/cpufeatures/0.2.12/download -> cpufeatures-0.2.12.crate
https://crates.io/api/v1/crates/crc/3.2.1/download -> crc-3.2.1.crate
https://crates.io/api/v1/crates/crc-catalog/2.4.0/download -> crc-catalog-2.4.0.crate
https://crates.io/api/v1/crates/crc32fast/1.4.2/download -> crc32fast-1.4.2.crate
https://crates.io/api/v1/crates/crossbeam-channel/0.5.15/download -> crossbeam-channel-0.5.15.crate
https://crates.io/api/v1/crates/crossbeam-deque/0.8.5/download -> crossbeam-deque-0.8.5.crate
https://crates.io/api/v1/crates/crossbeam-epoch/0.9.18/download -> crossbeam-epoch-0.9.18.crate
https://crates.io/api/v1/crates/crossbeam-utils/0.8.20/download -> crossbeam-utils-0.8.20.crate
https://crates.io/api/v1/crates/crypto-common/0.1.6/download -> crypto-common-0.1.6.crate
https://crates.io/api/v1/crates/data-encoding/2.6.0/download -> data-encoding-2.6.0.crate
https://crates.io/api/v1/crates/deranged/0.3.11/download -> deranged-0.3.11.crate
https://crates.io/api/v1/crates/derive_arbitrary/1.4.1/download -> derive_arbitrary-1.4.1.crate
https://crates.io/api/v1/crates/dialoguer/0.11.0/download -> dialoguer-0.11.0.crate
https://crates.io/api/v1/crates/diff/0.1.13/download -> diff-0.1.13.crate
https://crates.io/api/v1/crates/digest/0.10.7/download -> digest-0.10.7.crate
https://crates.io/api/v1/crates/dirs/5.0.1/download -> dirs-5.0.1.crate
https://crates.io/api/v1/crates/dirs-sys/0.4.1/download -> dirs-sys-0.4.1.crate
https://crates.io/api/v1/crates/displaydoc/0.2.5/download -> displaydoc-0.2.5.crate
https://crates.io/api/v1/crates/dissimilar/1.0.9/download -> dissimilar-1.0.9.crate
https://crates.io/api/v1/crates/dunce/1.0.5/download -> dunce-1.0.5.crate
https://crates.io/api/v1/crates/dyn-clone/1.0.17/download -> dyn-clone-1.0.17.crate
https://crates.io/api/v1/crates/either/1.13.0/download -> either-1.13.0.crate
https://crates.io/api/v1/crates/encode_unicode/0.3.6/download -> encode_unicode-0.3.6.crate
https://crates.io/api/v1/crates/encoding_rs/0.8.34/download -> encoding_rs-0.8.34.crate
https://crates.io/api/v1/crates/equivalent/1.0.1/download -> equivalent-1.0.1.crate
https://crates.io/api/v1/crates/errno/0.3.9/download -> errno-0.3.9.crate
https://crates.io/api/v1/crates/expect-test/1.5.0/download -> expect-test-1.5.0.crate
https://crates.io/api/v1/crates/fastrand/2.1.0/download -> fastrand-2.1.0.crate
https://crates.io/api/v1/crates/fat-macho/0.4.9/download -> fat-macho-0.4.9.crate
https://crates.io/api/v1/crates/filetime/0.2.23/download -> filetime-0.2.23.crate
https://crates.io/api/v1/crates/flate2/1.0.33/download -> flate2-1.0.33.crate
https://crates.io/api/v1/crates/fnv/1.0.7/download -> fnv-1.0.7.crate
https://crates.io/api/v1/crates/foreign-types/0.3.2/download -> foreign-types-0.3.2.crate
https://crates.io/api/v1/crates/foreign-types-shared/0.1.1/download -> foreign-types-shared-0.1.1.crate
https://crates.io/api/v1/crates/form_urlencoded/1.2.1/download -> form_urlencoded-1.2.1.crate
https://crates.io/api/v1/crates/fs-err/3.0.0/download -> fs-err-3.0.0.crate
https://crates.io/api/v1/crates/fs4/0.12.0/download -> fs4-0.12.0.crate
https://crates.io/api/v1/crates/futures/0.3.30/download -> futures-0.3.30.crate
https://crates.io/api/v1/crates/futures-channel/0.3.31/download -> futures-channel-0.3.31.crate
https://crates.io/api/v1/crates/futures-core/0.3.31/download -> futures-core-0.3.31.crate
https://crates.io/api/v1/crates/futures-executor/0.3.30/download -> futures-executor-0.3.30.crate
https://crates.io/api/v1/crates/futures-io/0.3.31/download -> futures-io-0.3.31.crate
https://crates.io/api/v1/crates/futures-macro/0.3.31/download -> futures-macro-0.3.31.crate
https://crates.io/api/v1/crates/futures-sink/0.3.31/download -> futures-sink-0.3.31.crate
https://crates.io/api/v1/crates/futures-task/0.3.31/download -> futures-task-0.3.31.crate
https://crates.io/api/v1/crates/futures-timer/3.0.3/download -> futures-timer-3.0.3.crate
https://crates.io/api/v1/crates/futures-util/0.3.31/download -> futures-util-0.3.31.crate
https://crates.io/api/v1/crates/generic-array/0.14.7/download -> generic-array-0.14.7.crate
https://crates.io/api/v1/crates/getrandom/0.2.15/download -> getrandom-0.2.15.crate
https://crates.io/api/v1/crates/glob/0.3.1/download -> glob-0.3.1.crate
https://crates.io/api/v1/crates/globset/0.4.15/download -> globset-0.4.15.crate
https://crates.io/api/v1/crates/goblin/0.9.2/download -> goblin-0.9.2.crate
https://crates.io/api/v1/crates/hashbrown/0.14.5/download -> hashbrown-0.14.5.crate
https://crates.io/api/v1/crates/hashbrown/0.15.2/download -> hashbrown-0.15.2.crate
https://crates.io/api/v1/crates/heck/0.4.1/download -> heck-0.4.1.crate
https://crates.io/api/v1/crates/heck/0.5.0/download -> heck-0.5.0.crate
https://crates.io/api/v1/crates/home/0.5.9/download -> home-0.5.9.crate
https://crates.io/api/v1/crates/humantime/2.1.0/download -> humantime-2.1.0.crate
https://crates.io/api/v1/crates/humantime-serde/1.1.1/download -> humantime-serde-1.1.1.crate
https://crates.io/api/v1/crates/icu_collections/1.5.0/download -> icu_collections-1.5.0.crate
https://crates.io/api/v1/crates/icu_locid/1.5.0/download -> icu_locid-1.5.0.crate
https://crates.io/api/v1/crates/icu_locid_transform/1.5.0/download -> icu_locid_transform-1.5.0.crate
https://crates.io/api/v1/crates/icu_locid_transform_data/1.5.0/download -> icu_locid_transform_data-1.5.0.crate
https://crates.io/api/v1/crates/icu_normalizer/1.5.0/download -> icu_normalizer-1.5.0.crate
https://crates.io/api/v1/crates/icu_normalizer_data/1.5.0/download -> icu_normalizer_data-1.5.0.crate
https://crates.io/api/v1/crates/icu_properties/1.5.1/download -> icu_properties-1.5.1.crate
https://crates.io/api/v1/crates/icu_properties_data/1.5.0/download -> icu_properties_data-1.5.0.crate
https://crates.io/api/v1/crates/icu_provider/1.5.0/download -> icu_provider-1.5.0.crate
https://crates.io/api/v1/crates/icu_provider_macros/1.5.0/download -> icu_provider_macros-1.5.0.crate
https://crates.io/api/v1/crates/idna/1.0.3/download -> idna-1.0.3.crate
https://crates.io/api/v1/crates/idna_adapter/1.2.0/download -> idna_adapter-1.2.0.crate
https://crates.io/api/v1/crates/ignore/0.4.23/download -> ignore-0.4.23.crate
https://crates.io/api/v1/crates/indexmap/2.6.0/download -> indexmap-2.6.0.crate
https://crates.io/api/v1/crates/indicatif/0.17.9/download -> indicatif-0.17.9.crate
https://crates.io/api/v1/crates/indoc/2.0.5/download -> indoc-2.0.5.crate
https://crates.io/api/v1/crates/is_terminal_polyfill/1.70.0/download -> is_terminal_polyfill-1.70.0.crate
https://crates.io/api/v1/crates/itertools/0.12.1/download -> itertools-0.12.1.crate
https://crates.io/api/v1/crates/itertools/0.13.0/download -> itertools-0.13.0.crate
https://crates.io/api/v1/crates/itoa/1.0.11/download -> itoa-1.0.11.crate
https://crates.io/api/v1/crates/js-sys/0.3.73/download -> js-sys-0.3.73.crate
https://crates.io/api/v1/crates/keyring/2.3.3/download -> keyring-2.3.3.crate
https://crates.io/api/v1/crates/lazy_static/1.4.0/download -> lazy_static-1.4.0.crate
https://crates.io/api/v1/crates/lddtree/0.3.7/download -> lddtree-0.3.7.crate
https://crates.io/api/v1/crates/libc/0.2.167/download -> libc-0.2.167.crate
https://crates.io/api/v1/crates/libmimalloc-sys/0.1.39/download -> libmimalloc-sys-0.1.39.crate
https://crates.io/api/v1/crates/libredox/0.1.3/download -> libredox-0.1.3.crate
https://crates.io/api/v1/crates/linux-keyutils/0.2.4/download -> linux-keyutils-0.2.4.crate
https://crates.io/api/v1/crates/linux-raw-sys/0.4.14/download -> linux-raw-sys-0.4.14.crate
https://crates.io/api/v1/crates/litemap/0.7.3/download -> litemap-0.7.3.crate
https://crates.io/api/v1/crates/lock_api/0.4.12/download -> lock_api-0.4.12.crate
https://crates.io/api/v1/crates/lockfree-object-pool/0.1.6/download -> lockfree-object-pool-0.1.6.crate
https://crates.io/api/v1/crates/log/0.4.22/download -> log-0.4.22.crate
https://crates.io/api/v1/crates/lzma-sys/0.1.20/download -> lzma-sys-0.1.20.crate
https://crates.io/api/v1/crates/lzxd/0.2.5/download -> lzxd-0.2.5.crate
https://crates.io/api/v1/crates/mailparse/0.15.0/download -> mailparse-0.15.0.crate
https://crates.io/api/v1/crates/matchers/0.1.0/download -> matchers-0.1.0.crate
https://crates.io/api/v1/crates/memchr/2.7.4/download -> memchr-2.7.4.crate
https://crates.io/api/v1/crates/mimalloc/0.1.43/download -> mimalloc-0.1.43.crate
https://crates.io/api/v1/crates/mime/0.3.17/download -> mime-0.3.17.crate
https://crates.io/api/v1/crates/mime_guess/2.0.4/download -> mime_guess-2.0.4.crate
https://crates.io/api/v1/crates/minijinja/2.5.0/download -> minijinja-2.5.0.crate
https://crates.io/api/v1/crates/minimal-lexical/0.2.1/download -> minimal-lexical-0.2.1.crate
https://crates.io/api/v1/crates/miniz_oxide/0.8.0/download -> miniz_oxide-0.8.0.crate
https://crates.io/api/v1/crates/msi/0.8.0/download -> msi-0.8.0.crate
https://crates.io/api/v1/crates/multipart/0.18.0/download -> multipart-0.18.0.crate
https://crates.io/api/v1/crates/native-tls/0.2.12/download -> native-tls-0.2.12.crate
https://crates.io/api/v1/crates/nom/7.1.3/download -> nom-7.1.3.crate
https://crates.io/api/v1/crates/normalize-line-endings/0.3.0/download -> normalize-line-endings-0.3.0.crate
https://crates.io/api/v1/crates/normpath/1.2.0/download -> normpath-1.2.0.crate
https://crates.io/api/v1/crates/nu-ansi-term/0.46.0/download -> nu-ansi-term-0.46.0.crate
https://crates.io/api/v1/crates/num-conv/0.1.0/download -> num-conv-0.1.0.crate
https://crates.io/api/v1/crates/number_prefix/0.4.0/download -> number_prefix-0.4.0.crate
https://crates.io/api/v1/crates/once_cell/1.20.2/download -> once_cell-1.20.2.crate
https://crates.io/api/v1/crates/openssl/0.10.72/download -> openssl-0.10.72.crate
https://crates.io/api/v1/crates/openssl-macros/0.1.1/download -> openssl-macros-0.1.1.crate
https://crates.io/api/v1/crates/openssl-probe/0.1.5/download -> openssl-probe-0.1.5.crate
https://crates.io/api/v1/crates/openssl-sys/0.9.107/download -> openssl-sys-0.9.107.crate
https://crates.io/api/v1/crates/option-ext/0.2.0/download -> option-ext-0.2.0.crate
https://crates.io/api/v1/crates/os_pipe/1.2.0/download -> os_pipe-1.2.0.crate
https://crates.io/api/v1/crates/overload/0.1.1/download -> overload-0.1.1.crate
https://crates.io/api/v1/crates/parking_lot/0.12.3/download -> parking_lot-0.12.3.crate
https://crates.io/api/v1/crates/parking_lot_core/0.9.10/download -> parking_lot_core-0.9.10.crate
https://crates.io/api/v1/crates/paste/1.0.15/download -> paste-1.0.15.crate
https://crates.io/api/v1/crates/path-slash/0.2.1/download -> path-slash-0.2.1.crate
https://crates.io/api/v1/crates/pep440_rs/0.7.3/download -> pep440_rs-0.7.3.crate
https://crates.io/api/v1/crates/pep508_rs/0.9.2/download -> pep508_rs-0.9.2.crate
https://crates.io/api/v1/crates/percent-encoding/2.3.1/download -> percent-encoding-2.3.1.crate
https://crates.io/api/v1/crates/pin-project-lite/0.2.15/download -> pin-project-lite-0.2.15.crate
https://crates.io/api/v1/crates/pin-utils/0.1.0/download -> pin-utils-0.1.0.crate
https://crates.io/api/v1/crates/pkg-config/0.3.30/download -> pkg-config-0.3.30.crate
https://crates.io/api/v1/crates/plain/0.2.3/download -> plain-0.2.3.crate
https://crates.io/api/v1/crates/platform-info/2.0.3/download -> platform-info-2.0.3.crate
https://crates.io/api/v1/crates/portable-atomic/1.6.0/download -> portable-atomic-1.6.0.crate
https://crates.io/api/v1/crates/powerfmt/0.2.0/download -> powerfmt-0.2.0.crate
https://crates.io/api/v1/crates/ppv-lite86/0.2.17/download -> ppv-lite86-0.2.17.crate
https://crates.io/api/v1/crates/pretty_assertions/1.4.1/download -> pretty_assertions-1.4.1.crate
https://crates.io/api/v1/crates/proc-macro-crate/3.1.0/download -> proc-macro-crate-3.1.0.crate
https://crates.io/api/v1/crates/proc-macro2/1.0.92/download -> proc-macro2-1.0.92.crate
https://crates.io/api/v1/crates/psm/0.1.21/download -> psm-0.1.21.crate
https://crates.io/api/v1/crates/pyproject-toml/0.13.4/download -> pyproject-toml-0.13.4.crate
https://crates.io/api/v1/crates/python-pkginfo/0.6.5/download -> python-pkginfo-0.6.5.crate
https://crates.io/api/v1/crates/quote/1.0.37/download -> quote-1.0.37.crate
https://crates.io/api/v1/crates/quoted_printable/0.5.0/download -> quoted_printable-0.5.0.crate
https://crates.io/api/v1/crates/rand/0.8.5/download -> rand-0.8.5.crate
https://crates.io/api/v1/crates/rand_chacha/0.3.1/download -> rand_chacha-0.3.1.crate
https://crates.io/api/v1/crates/rand_core/0.6.4/download -> rand_core-0.6.4.crate
https://crates.io/api/v1/crates/rayon/1.10.0/download -> rayon-1.10.0.crate
https://crates.io/api/v1/crates/rayon-core/1.12.1/download -> rayon-core-1.12.1.crate
https://crates.io/api/v1/crates/redox_syscall/0.4.1/download -> redox_syscall-0.4.1.crate
https://crates.io/api/v1/crates/redox_syscall/0.5.1/download -> redox_syscall-0.5.1.crate
https://crates.io/api/v1/crates/redox_users/0.4.5/download -> redox_users-0.4.5.crate
https://crates.io/api/v1/crates/regex/1.11.1/download -> regex-1.11.1.crate
https://crates.io/api/v1/crates/regex-automata/0.1.10/download -> regex-automata-0.1.10.crate
https://crates.io/api/v1/crates/regex-automata/0.4.9/download -> regex-automata-0.4.9.crate
https://crates.io/api/v1/crates/regex-syntax/0.6.29/download -> regex-syntax-0.6.29.crate
https://crates.io/api/v1/crates/regex-syntax/0.8.5/download -> regex-syntax-0.8.5.crate
https://crates.io/api/v1/crates/relative-path/1.9.3/download -> relative-path-1.9.3.crate
https://crates.io/api/v1/crates/rfc2047-decoder/1.0.6/download -> rfc2047-decoder-1.0.6.crate
https://crates.io/api/v1/crates/ring/0.17.13/download -> ring-0.17.13.crate
https://crates.io/api/v1/crates/rstest/0.22.0/download -> rstest-0.22.0.crate
https://crates.io/api/v1/crates/rstest_macros/0.22.0/download -> rstest_macros-0.22.0.crate
https://crates.io/api/v1/crates/rustc-hash/2.0.0/download -> rustc-hash-2.0.0.crate
https://crates.io/api/v1/crates/rustc_version/0.4.1/download -> rustc_version-0.4.1.crate
https://crates.io/api/v1/crates/rustflags/0.1.6/download -> rustflags-0.1.6.crate
https://crates.io/api/v1/crates/rustix/0.38.41/download -> rustix-0.38.41.crate
https://crates.io/api/v1/crates/rustls/0.23.19/download -> rustls-0.23.19.crate
https://crates.io/api/v1/crates/rustls-pemfile/2.1.3/download -> rustls-pemfile-2.1.3.crate
https://crates.io/api/v1/crates/rustls-pki-types/1.10.0/download -> rustls-pki-types-1.10.0.crate
https://crates.io/api/v1/crates/rustls-webpki/0.102.8/download -> rustls-webpki-0.102.8.crate
https://crates.io/api/v1/crates/rustversion/1.0.18/download -> rustversion-1.0.18.crate
https://crates.io/api/v1/crates/ryu/1.0.18/download -> ryu-1.0.18.crate
https://crates.io/api/v1/crates/same-file/1.0.6/download -> same-file-1.0.6.crate
https://crates.io/api/v1/crates/schannel/0.1.23/download -> schannel-0.1.23.crate
https://crates.io/api/v1/crates/schemars/0.8.21/download -> schemars-0.8.21.crate
https://crates.io/api/v1/crates/schemars_derive/0.8.21/download -> schemars_derive-0.8.21.crate
https://crates.io/api/v1/crates/scopeguard/1.2.0/download -> scopeguard-1.2.0.crate
https://crates.io/api/v1/crates/scroll/0.12.0/download -> scroll-0.12.0.crate
https://crates.io/api/v1/crates/scroll_derive/0.12.0/download -> scroll_derive-0.12.0.crate
https://crates.io/api/v1/crates/security-framework/2.11.0/download -> security-framework-2.11.0.crate
https://crates.io/api/v1/crates/security-framework-sys/2.11.0/download -> security-framework-sys-2.11.0.crate
https://crates.io/api/v1/crates/semver/1.0.23/download -> semver-1.0.23.crate
https://crates.io/api/v1/crates/serde/1.0.217/download -> serde-1.0.217.crate
https://crates.io/api/v1/crates/serde_derive/1.0.217/download -> serde_derive-1.0.217.crate
https://crates.io/api/v1/crates/serde_derive_internals/0.29.1/download -> serde_derive_internals-0.29.1.crate
https://crates.io/api/v1/crates/serde_json/1.0.135/download -> serde_json-1.0.135.crate
https://crates.io/api/v1/crates/serde_spanned/0.6.8/download -> serde_spanned-0.6.8.crate
https://crates.io/api/v1/crates/sha2/0.10.8/download -> sha2-0.10.8.crate
https://crates.io/api/v1/crates/sharded-slab/0.1.7/download -> sharded-slab-0.1.7.crate
https://crates.io/api/v1/crates/shell-words/1.1.0/download -> shell-words-1.1.0.crate
https://crates.io/api/v1/crates/shlex/1.3.0/download -> shlex-1.3.0.crate
https://crates.io/api/v1/crates/simd-adler32/0.3.7/download -> simd-adler32-0.3.7.crate
https://crates.io/api/v1/crates/similar/2.5.0/download -> similar-2.5.0.crate
https://crates.io/api/v1/crates/slab/0.4.9/download -> slab-0.4.9.crate
https://crates.io/api/v1/crates/smallvec/1.13.2/download -> smallvec-1.13.2.crate
https://crates.io/api/v1/crates/smawk/0.3.2/download -> smawk-0.3.2.crate
https://crates.io/api/v1/crates/snapbox/0.6.16/download -> snapbox-0.6.16.crate
https://crates.io/api/v1/crates/snapbox-macros/0.3.10/download -> snapbox-macros-0.3.10.crate
https://crates.io/api/v1/crates/socks/0.3.4/download -> socks-0.3.4.crate
https://crates.io/api/v1/crates/stable_deref_trait/1.2.0/download -> stable_deref_trait-1.2.0.crate
https://crates.io/api/v1/crates/stacker/0.1.15/download -> stacker-0.1.15.crate
https://crates.io/api/v1/crates/static_assertions/1.1.0/download -> static_assertions-1.1.0.crate
https://crates.io/api/v1/crates/strsim/0.11.1/download -> strsim-0.11.1.crate
https://crates.io/api/v1/crates/subtle/2.5.0/download -> subtle-2.5.0.crate
https://crates.io/api/v1/crates/syn/2.0.90/download -> syn-2.0.90.crate
https://crates.io/api/v1/crates/synstructure/0.13.1/download -> synstructure-0.13.1.crate
https://crates.io/api/v1/crates/tar/0.4.43/download -> tar-0.4.43.crate
https://crates.io/api/v1/crates/target-lexicon/0.13.1/download -> target-lexicon-0.13.1.crate
https://crates.io/api/v1/crates/tempfile/3.11.0/download -> tempfile-3.11.0.crate
https://crates.io/api/v1/crates/termcolor/1.4.1/download -> termcolor-1.4.1.crate
https://crates.io/api/v1/crates/terminal_size/0.3.0/download -> terminal_size-0.3.0.crate
https://crates.io/api/v1/crates/textwrap/0.16.1/download -> textwrap-0.16.1.crate
https://crates.io/api/v1/crates/thiserror/1.0.69/download -> thiserror-1.0.69.crate
https://crates.io/api/v1/crates/thiserror/2.0.3/download -> thiserror-2.0.3.crate
https://crates.io/api/v1/crates/thiserror-impl/1.0.69/download -> thiserror-impl-1.0.69.crate
https://crates.io/api/v1/crates/thiserror-impl/2.0.3/download -> thiserror-impl-2.0.3.crate
https://crates.io/api/v1/crates/thread_local/1.1.8/download -> thread_local-1.1.8.crate
https://crates.io/api/v1/crates/time/0.3.36/download -> time-0.3.36.crate
https://crates.io/api/v1/crates/time-core/0.1.2/download -> time-core-0.1.2.crate
https://crates.io/api/v1/crates/time-macros/0.2.18/download -> time-macros-0.2.18.crate
https://crates.io/api/v1/crates/tinystr/0.7.6/download -> tinystr-0.7.6.crate
https://crates.io/api/v1/crates/toml/0.8.19/download -> toml-0.8.19.crate
https://crates.io/api/v1/crates/toml_datetime/0.6.8/download -> toml_datetime-0.6.8.crate
https://crates.io/api/v1/crates/toml_edit/0.21.1/download -> toml_edit-0.21.1.crate
https://crates.io/api/v1/crates/toml_edit/0.22.22/download -> toml_edit-0.22.22.crate
https://crates.io/api/v1/crates/tracing/0.1.41/download -> tracing-0.1.41.crate
https://crates.io/api/v1/crates/tracing-attributes/0.1.28/download -> tracing-attributes-0.1.28.crate
https://crates.io/api/v1/crates/tracing-core/0.1.33/download -> tracing-core-0.1.33.crate
https://crates.io/api/v1/crates/tracing-log/0.2.0/download -> tracing-log-0.2.0.crate
https://crates.io/api/v1/crates/tracing-serde/0.2.0/download -> tracing-serde-0.2.0.crate
https://crates.io/api/v1/crates/tracing-subscriber/0.3.19/download -> tracing-subscriber-0.3.19.crate
https://crates.io/api/v1/crates/trycmd/0.15.6/download -> trycmd-0.15.6.crate
https://crates.io/api/v1/crates/twox-hash/1.6.3/download -> twox-hash-1.6.3.crate
https://crates.io/api/v1/crates/typenum/1.17.0/download -> typenum-1.17.0.crate
https://crates.io/api/v1/crates/unicase/2.7.0/download -> unicase-2.7.0.crate
https://crates.io/api/v1/crates/unicode-ident/1.0.12/download -> unicode-ident-1.0.12.crate
https://crates.io/api/v1/crates/unicode-linebreak/0.1.5/download -> unicode-linebreak-0.1.5.crate
https://crates.io/api/v1/crates/unicode-width/0.1.13/download -> unicode-width-0.1.13.crate
https://crates.io/api/v1/crates/unicode-width/0.2.0/download -> unicode-width-0.2.0.crate
https://crates.io/api/v1/crates/unicode-xid/0.2.6/download -> unicode-xid-0.2.6.crate
https://crates.io/api/v1/crates/unscanny/0.1.0/download -> unscanny-0.1.0.crate
https://crates.io/api/v1/crates/untrusted/0.9.0/download -> untrusted-0.9.0.crate
https://crates.io/api/v1/crates/ureq/2.11.0/download -> ureq-2.11.0.crate
https://crates.io/api/v1/crates/url/2.5.4/download -> url-2.5.4.crate
https://crates.io/api/v1/crates/urlencoding/2.1.3/download -> urlencoding-2.1.3.crate
https://crates.io/api/v1/crates/utf16_iter/1.0.5/download -> utf16_iter-1.0.5.crate
https://crates.io/api/v1/crates/utf8_iter/1.0.4/download -> utf8_iter-1.0.4.crate
https://crates.io/api/v1/crates/utf8parse/0.2.2/download -> utf8parse-0.2.2.crate
https://crates.io/api/v1/crates/uuid/1.8.0/download -> uuid-1.8.0.crate
https://crates.io/api/v1/crates/valuable/0.1.0/download -> valuable-0.1.0.crate
https://crates.io/api/v1/crates/vcpkg/0.2.15/download -> vcpkg-0.2.15.crate
https://crates.io/api/v1/crates/version-ranges/0.1.1/download -> version-ranges-0.1.1.crate
https://crates.io/api/v1/crates/version_check/0.9.4/download -> version_check-0.9.4.crate
https://crates.io/api/v1/crates/versions/6.2.0/download -> versions-6.2.0.crate
https://crates.io/api/v1/crates/wait-timeout/0.2.0/download -> wait-timeout-0.2.0.crate
https://crates.io/api/v1/crates/walkdir/2.5.0/download -> walkdir-2.5.0.crate
https://crates.io/api/v1/crates/wasi/0.11.0+wasi-snapshot-preview1/download -> wasi-0.11.0+wasi-snapshot-preview1.crate
https://crates.io/api/v1/crates/wasm-bindgen/0.2.96/download -> wasm-bindgen-0.2.96.crate
https://crates.io/api/v1/crates/wasm-bindgen-backend/0.2.96/download -> wasm-bindgen-backend-0.2.96.crate
https://crates.io/api/v1/crates/wasm-bindgen-macro/0.2.96/download -> wasm-bindgen-macro-0.2.96.crate
https://crates.io/api/v1/crates/wasm-bindgen-macro-support/0.2.96/download -> wasm-bindgen-macro-support-0.2.96.crate
https://crates.io/api/v1/crates/wasm-bindgen-shared/0.2.96/download -> wasm-bindgen-shared-0.2.96.crate
https://crates.io/api/v1/crates/web-time/1.1.0/download -> web-time-1.1.0.crate
https://crates.io/api/v1/crates/webpki-roots/0.26.2/download -> webpki-roots-0.26.2.crate
https://crates.io/api/v1/crates/which/7.0.0/download -> which-7.0.0.crate
https://crates.io/api/v1/crates/wild/2.2.1/download -> wild-2.2.1.crate
https://crates.io/api/v1/crates/winapi/0.3.9/download -> winapi-0.3.9.crate
https://crates.io/api/v1/crates/winapi-i686-pc-windows-gnu/0.4.0/download -> winapi-i686-pc-windows-gnu-0.4.0.crate
https://crates.io/api/v1/crates/winapi-util/0.1.8/download -> winapi-util-0.1.8.crate
https://crates.io/api/v1/crates/winapi-x86_64-pc-windows-gnu/0.4.0/download -> winapi-x86_64-pc-windows-gnu-0.4.0.crate
https://crates.io/api/v1/crates/windows-sys/0.48.0/download -> windows-sys-0.48.0.crate
https://crates.io/api/v1/crates/windows-sys/0.52.0/download -> windows-sys-0.52.0.crate
https://crates.io/api/v1/crates/windows-targets/0.48.5/download -> windows-targets-0.48.5.crate
https://crates.io/api/v1/crates/windows-targets/0.52.5/download -> windows-targets-0.52.5.crate
https://crates.io/api/v1/crates/windows_aarch64_gnullvm/0.48.5/download -> windows_aarch64_gnullvm-0.48.5.crate
https://crates.io/api/v1/crates/windows_aarch64_gnullvm/0.52.5/download -> windows_aarch64_gnullvm-0.52.5.crate
https://crates.io/api/v1/crates/windows_aarch64_msvc/0.48.5/download -> windows_aarch64_msvc-0.48.5.crate
https://crates.io/api/v1/crates/windows_aarch64_msvc/0.52.5/download -> windows_aarch64_msvc-0.52.5.crate
https://crates.io/api/v1/crates/windows_i686_gnu/0.48.5/download -> windows_i686_gnu-0.48.5.crate
https://crates.io/api/v1/crates/windows_i686_gnu/0.52.5/download -> windows_i686_gnu-0.52.5.crate
https://crates.io/api/v1/crates/windows_i686_gnullvm/0.52.5/download -> windows_i686_gnullvm-0.52.5.crate
https://crates.io/api/v1/crates/windows_i686_msvc/0.48.5/download -> windows_i686_msvc-0.48.5.crate
https://crates.io/api/v1/crates/windows_i686_msvc/0.52.5/download -> windows_i686_msvc-0.52.5.crate
https://crates.io/api/v1/crates/windows_x86_64_gnu/0.48.5/download -> windows_x86_64_gnu-0.48.5.crate
https://crates.io/api/v1/crates/windows_x86_64_gnu/0.52.5/download -> windows_x86_64_gnu-0.52.5.crate
https://crates.io/api/v1/crates/windows_x86_64_gnullvm/0.48.5/download -> windows_x86_64_gnullvm-0.48.5.crate
https://crates.io/api/v1/crates/windows_x86_64_gnullvm/0.52.5/download -> windows_x86_64_gnullvm-0.52.5.crate
https://crates.io/api/v1/crates/windows_x86_64_msvc/0.48.5/download -> windows_x86_64_msvc-0.48.5.crate
https://crates.io/api/v1/crates/windows_x86_64_msvc/0.52.5/download -> windows_x86_64_msvc-0.52.5.crate
https://crates.io/api/v1/crates/winnow/0.5.40/download -> winnow-0.5.40.crate
https://crates.io/api/v1/crates/winnow/0.6.20/download -> winnow-0.6.20.crate
https://crates.io/api/v1/crates/winsafe/0.0.19/download -> winsafe-0.0.19.crate
https://crates.io/api/v1/crates/write16/1.0.0/download -> write16-1.0.0.crate
https://crates.io/api/v1/crates/writeable/0.5.5/download -> writeable-0.5.5.crate
https://crates.io/api/v1/crates/xattr/1.3.1/download -> xattr-1.3.1.crate
https://crates.io/api/v1/crates/xwin/0.6.5/download -> xwin-0.6.5.crate
https://crates.io/api/v1/crates/xz2/0.1.7/download -> xz2-0.1.7.crate
https://crates.io/api/v1/crates/yansi/1.0.1/download -> yansi-1.0.1.crate
https://crates.io/api/v1/crates/yoke/0.7.4/download -> yoke-0.7.4.crate
https://crates.io/api/v1/crates/yoke-derive/0.7.5/download -> yoke-derive-0.7.5.crate
https://crates.io/api/v1/crates/zerocopy/0.7.35/download -> zerocopy-0.7.35.crate
https://crates.io/api/v1/crates/zerocopy-derive/0.7.35/download -> zerocopy-derive-0.7.35.crate
https://crates.io/api/v1/crates/zerofrom/0.1.4/download -> zerofrom-0.1.4.crate
https://crates.io/api/v1/crates/zerofrom-derive/0.1.5/download -> zerofrom-derive-0.1.5.crate
https://crates.io/api/v1/crates/zeroize/1.8.1/download -> zeroize-1.8.1.crate
https://crates.io/api/v1/crates/zerovec/0.10.4/download -> zerovec-0.10.4.crate
https://crates.io/api/v1/crates/zerovec-derive/0.10.3/download -> zerovec-derive-0.10.3.crate
https://crates.io/api/v1/crates/zip/2.3.0/download -> zip-2.3.0.crate
https://crates.io/api/v1/crates/zopfli/0.8.1/download -> zopfli-0.8.1.crate
https://files.pythonhosted.org/packages/34/bc/c7df50a359c3a31490785c77d1ddd5fc83cc8cc07a4eddd289dbae53545a/maturin-1.8.6.tar.gz -> maturin-1.8.6.tar.gz
$(cargo_crate_uris ${CRATES})"

DEPEND="dev-python/setuptools-rust[${PYTHON_USEDEP}]"
RDEPEND="dev-python/tomli[${PYTHON_USEDEP}]"
IUSE=""
SLOT="0"
LICENSE=""
KEYWORDS="*"
S="${WORKDIR}/maturin-1.8.6"