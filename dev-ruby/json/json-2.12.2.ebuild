# Distributed under the terms of the GNU General Public License v2

EAPI=7

USE_RUBY="ruby27 ruby30 ruby31 ruby32"
RUBY_FAKEGEM_EXTRADOC="CHANGES.md README.md"
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"
RUBY_FAKEGEM_EXTENSIONS=(ext/json/ext/parser/extconf.rb ext/json/ext/generator/extconf.rb)

inherit ruby-fakegem

DESCRIPTION="A JSON implementation as a Ruby extension"
HOMEPAGE="https://github.com/ruby/json"
SRC_URI="https://github.com/ruby/json/tarball/a29cb77d5234c504f34e326ed6eb826997ffdd05 -> json-2.12.2-a29cb77.tar.gz"

KEYWORDS="*"
LICENSE="Ruby"
SLOT="2"
IUSE=""

RDEPEND="${RDEPEND}"
DEPEND="${DEPEND}
	dev-util/ragel"

ruby_add_bdepend "dev-ruby/rake
	doc? ( dev-ruby/rdoc )
	test? ( dev-ruby/test-unit:2 )"

post_src_unpack() {
	if [ ! -d "${S}/all/${P}" ] ; then
		mv "${WORKDIR}"/all/ruby-json-* "${S}"/all/"${P}" || die
	fi
}

all_ruby_prepare() {
	# Avoid building the extension twice!
	# And use rdoc instead of sdoc which we don't have packaged
	# And don't call git to list files. We're using the pregenerated spec anyway.
	sed -i \
		-e '/task :test/ s|:compile,||' \
		-e 's| => :clean||' \
		-e 's|sdoc|rdoc|' \
		-e 's|`git ls-files`|""|' \
		Rakefile || die "rakefile fix failed"

	# Remove hardcoded and broken -O setting.
	sed -i -e '/^  \(if\|unless\)/,/^  end/ s:^:#:' \
		-e '/^unless/,/^end/ s:^:#:' ext/json/ext/*/extconf.rb || die

	# Avoid setting gem since it will not be available yet when installing
	sed -i -e '/gem/ s:^:#:' test/json/test_helper.rb || die
}

#each_ruby_compile() {
#	for ext in parser generator ; do
#		cp ext/json/ext/${ext}/${ext}$(get_modname) ext/json/ext/ || die
#	done
#}

each_ruby_install() {
	each_fakegem_install

	#ruby_fakegem_newins ext/json/ext/generator$(get_modname) lib/json/ext/generator$(get_modname)
	#ruby_fakegem_newins ext/json/ext/parser$(get_modname) lib/json/ext/parser$(get_modname)
}
