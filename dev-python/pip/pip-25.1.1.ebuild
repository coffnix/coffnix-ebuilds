# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_SETUPTOOLS="rdepend"
inherit bash-completion-r1 distutils-r1

DESCRIPTION="The PyPA recommended tool for installing Python packages."
HOMEPAGE="None https://pypi.org/project/pip/"
SRC_URI="https://files.pythonhosted.org/packages/59/de/241caa0ca606f2ec5fe0c1f4261b0465df78d786a38da693864a116c37f4/pip-25.1.1.tar.gz -> pip-25.1.1.tar.gz"

DEPEND=""
IUSE="vanilla"
RESTRICT="test"
SLOT="0"
LICENSE="MIT"
KEYWORDS="*"
S="${WORKDIR}/pip-25.1.1"

python_prepare_all() {
	if ! use vanilla; then
		# Running pip without --target, --prefix, --root, or --user will result
		# in packages being installed systemwide. This has a tendency to break
		# python-exec if setuptools gets installed or upgraded.
		sed -e 's|options.upgrade_strategy|options.upgrade_strategy\n\n        if not options.use_user_site and not options.target_dir and not options.root_path and not options.prefix_path:\n            raise CommandError("(Gentoo) Please run pip with the --user option to avoid breaking python-exec")\n|' \
			-i src/pip/_internal/commands/install.py || die
	fi
	distutils-r1_python_prepare_all
}
python_install_all() {
	# Prevent dbus auto-launch
	# https://bugs.gentoo.org/692178
	export DBUS_SESSION_BUS_ADDRESS="disabled:"
	local DOCS=( AUTHORS.txt docs/html/**/*.rst )
	distutils-r1_python_install_all
	if [ "$PN" == "pip" ]; then
		COMPLETION="${T}"/completion.tmp
		# 'pip completion' command embeds full $0 into completion script, which confuses
		# 'complete' and causes QA warning when running as "${PYTHON} -m pip".
		# This trick sets correct $0 while still calling just installed pip.
		local pipcmd='import sys; sys.argv[0] = "pip"; __file__ = ""; from pip._internal.cli.main import main; sys.exit(main())'
		${EPYTHON} -c "${pipcmd}" completion --bash > "${COMPLETION}" || die
		newbashcomp "${COMPLETION}" ${PN}
		${EPYTHON} -c "${pipcmd}" completion --zsh > "${COMPLETION}" || die
		insinto /usr/share/zsh/site-functions
		newins "${COMPLETION}" _pip
	fi
}
