# Distributed under the terms of the GNU General Public License v2

EAPI=7

USE_RUBY="ruby27 ruby30 ruby31 ruby32"
RUBY_FAKEGEM_EXTRADOC="CHANGELOG.md README.md"
RUBY_FAKEGEM_BINDIR="exe"
RUBY_FAKEGEM_EXTRAINSTALL="core schema sig stdlib"
RUBY_FAKEGEM_EXTENSIONS=(ext/rbs_extension/extconf.rb)
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="Type Signature for Ruby"
HOMEPAGE="https://github.com/ruby/rbs"
SRC_URI="https://github.com/ruby/rbs/tarball/8c362dc1712a4a92c48ff8e7160ca81407b91f59 -> rbs-3.9.4-8c362dc.tar.gz"

KEYWORDS="*"
LICENSE="|| ( Ruby-BSD BSD-2 )"
SLOT="0"
IUSE="test"

ruby_add_bdepend "test? ( dev-ruby/bundler dev-ruby/rdoc dev-ruby/test-unit )"

post_src_unpack() {
	if [ ! -d "${S}/all/${P}" ] ; then
		mv "${WORKDIR}"/all/ruby-rbs-* "${S}"/all/"${P}" || die
	fi
}

all_ruby_prepare() {
	sed -i -e 's/git ls-files -z/find * -print0/' ${RUBY_FAKEGEM_GEMSPEC} || die

	# We compile the extension directly
	sed -i -e '/extensiontask/I s:^:#:' Rakefile || die

	# Avoid JSON schema validation tests due to a large dependency stack
	# that would be needed.
	rm -f test/rbs/schema_test.rb || die

	# Avoid setup tests since they require a lot of development dependencies.
	rm -f test/rbs/test/runtime_test_test.rb || die

	# Avoid tests requiring a network connection
	rm -f test/rbs/collection/installer_test.rb test/rbs/collection/collections_test.rb test/rbs/collection/config_test.rb || die
	sed -i -e '/def test_collection_/aomit "Requires network"' test/rbs/cli_test.rb || die
	sed -i -e '/def test_loading_from_rbs_collection/aomit "Requires network"' test/rbs/environment_loader_test.rb || die

	sed -i -e '/def test_paths/aomit "Different paths in Gentoo test environment"' test/rbs/cli_test.rb || die
}