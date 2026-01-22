# Distributed under the terms of the GNU General Public License v2

# @ECLASS: vala.eclass
# @MAINTAINER:
# gnome@gentoo.org
# @SUPPORTED_EAPIS: 6 7
# @BLURB: Seleciona uma versão de Vala e exporta VALAC, VAPIGEN e PKG_CONFIG_PATH.
# @DESCRIPTION:
# Esta eclass ajuda projetos que esperam valac, vapigen e .pc sem sufixo de versão.
# Ela escolhe a melhor API instalada dentro do intervalo configurado e cria symlinks
# temporários para pkg-config, além de exportar VALAC, VAPIGEN e afins.

case "${EAPI:-0}" in
	6|7) ;;
	*) die "vala.eclass: EAPI=${EAPI} não suportado, precisa ser 7" ;;
esac

inherit multilib

EXPORT_FUNCTIONS src_prepare

# Mínimo e máximo de API de Vala aceitos
VALA_MIN_API_VERSION=${VALA_MIN_API_VERSION:-0.36}
VALA_MAX_API_VERSION=${VALA_MAX_API_VERSION:-0.56}

# Opcional, exemplo: VALA_USE_DEPEND="vapigen"
# vapigen vira (+) e valadoc vira (-)
# os demais são ignorados por segurança
# shellcheck disable=SC2034
: "${VALA_USE_DEPEND:=}"

_vala_use_depend() {
	local u="" vala_use
	if [[ -n ${VALA_USE_DEPEND} ]]; then
		for vala_use in ${VALA_USE_DEPEND}; do
			case ${vala_use} in
				vapigen) u="${u},${vala_use}(+)" ;;
				valadoc) u="${u},${vala_use}(-)" ;;
				*) ;;
			esac
		done
		u="[${u#,}]"
	fi
	echo -n "${u}"
}

vala_api_versions() {
	[[ ${VALA_MIN_API_VERSION} =~ ^0\.[0-9]+$ ]] || die "VALA_MIN_API_VERSION inválido: ${VALA_MIN_API_VERSION}"
	[[ ${VALA_MAX_API_VERSION} =~ ^0\.[0-9]+$ ]] || die "VALA_MAX_API_VERSION inválido: ${VALA_MAX_API_VERSION}"

	local min_minor=${VALA_MIN_API_VERSION#*.}
	local max_minor=${VALA_MAX_API_VERSION#*.}
	local minor

	for (( minor = max_minor; minor >= min_minor; minor -= 2 )); do
		echo "0.${minor}"
	done
}

vala_depend() {
	local u v
	u=$(_vala_use_depend)

	echo -n "|| ("
	for v in $(vala_api_versions); do
		echo -n " dev-lang/vala:${v}${u}"
	done
	echo " )"
}

vala_best_api_version() {
	local u v
	u=$(_vala_use_depend)

	for v in $(vala_api_versions); do
		has_version "dev-lang/vala:${v}${u}" && echo "${v}" && return 0
	done
	return 1
}

_vala_export_env() {
	local version=$1
	[[ -n ${version} ]] || die "vala.eclass: versão vazia em _vala_export_env"

	local valac_bin vapigen_bin valadoc_bin introspect_bin

	valac_bin=$(type -P "valac-${version}")
	[[ -n ${valac_bin} ]] || valac_bin=$(type -P valac)
	[[ -n ${valac_bin} ]] || die "vala.eclass: não achei valac para API ${version}"

	vapigen_bin=$(type -P "vapigen-${version}")
	[[ -n ${vapigen_bin} ]] || vapigen_bin=$(type -P vapigen)

	valadoc_bin=$(type -P "valadoc-${version}")
	[[ -n ${valadoc_bin} ]] || valadoc_bin=$(type -P valadoc)

	introspect_bin=$(type -P "vala-gen-introspect-${version}")
	[[ -n ${introspect_bin} ]] || introspect_bin=$(type -P vala-gen-introspect)

	export VALAC="${valac_bin}"
	[[ -n ${vapigen_bin} ]] && export VAPIGEN="${vapigen_bin}"
	[[ -n ${valadoc_bin} ]] && export VALADOC="${valadoc_bin}"
	[[ -n ${introspect_bin} ]] && export VALA_GEN_INTROSPECT="${introspect_bin}"

	local vapigen_makefile="${EPREFIX}/usr/share/vala/Makefile.vapigen"
	[[ -e ${vapigen_makefile} ]] && export VAPIGEN_MAKEFILE="${vapigen_makefile}"

	export VAPIGEN_VAPIDIR="${EPREFIX}/usr/share/vala/vapi"
}

_vala_setup_pkgconfig() {
	local version=$1
	local p d
	local tpc="${T}/pkgconfig"

	mkdir -p "${tpc}" || die "vala.eclass: mkdir falhou"

	for p in libvala vapigen; do
		for d in "${EPREFIX}/usr/$(get_libdir)/pkgconfig" "${EPREFIX}/usr/share/pkgconfig"; do
			if [[ -e ${d}/${p}-${version}.pc ]]; then
				ln -sf "${d}/${p}-${version}.pc" "${tpc}/${p}.pc" || die "vala.eclass: ln falhou"
				break
			fi
		done
	done

	: "${PKG_CONFIG_PATH:=${EPREFIX}/usr/$(get_libdir)/pkgconfig:${EPREFIX}/usr/share/pkgconfig}"
	export PKG_CONFIG_PATH="${tpc}:${PKG_CONFIG_PATH}"
}

# @FUNCTION: vala_setup
# @DESCRIPTION:
# Configura ambiente de Vala, usada por ebuilds modernos em src_prepare.
# Normalmente chamada assim: use vala && vala_setup
vala_setup() {
	local version
	version=$(vala_best_api_version) || die "vala.eclass: nenhuma vala instalada que satisfaça $(vala_depend)"
	_vala_export_env "${version}"
	_vala_setup_pkgconfig "${version}"
}

# @FUNCTION: vala_src_prepare
# @USAGE: [--ignore-use] [--vala-api-version 0.xx]
# @DESCRIPTION:
# Igual ao vala_setup, mas com suporte a ignorar USE e forçar versão.
vala_src_prepare() {
	local ignore_use=0 version=""

	while [[ -n $1 ]]; do
		case $1 in
			--ignore-use) ignore_use=1 ;;
			--vala-api-version)
				shift
				version=$1
				[[ -n ${version} ]] || die "vala.eclass: --vala-api-version precisa de parâmetro"
				;;
			*) ;;
		esac
		shift
	done

	if [[ ${ignore_use} -eq 0 ]]; then
		in_iuse vala && ! use vala && return 0
	fi

	if [[ -z ${version} ]]; then
		version=$(vala_best_api_version) || die "vala.eclass: nenhuma vala instalada que satisfaça $(vala_depend)"
	else
		has_version "dev-lang/vala:${version}" || die "vala.eclass: não tenho dev-lang/vala:${version} instalado"
	fi

	_vala_export_env "${version}"
	_vala_setup_pkgconfig "${version}"
}

# Fase exportada pela eclass
vala_src_prepare_phase() {
	vala_src_prepare
}

src_prepare() {
	vala_src_prepare_phase
}
