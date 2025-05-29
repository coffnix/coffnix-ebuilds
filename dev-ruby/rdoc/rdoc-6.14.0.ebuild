# Distributed under the terms of the GNU General Public License v2

EAPI=7

USE_RUBY="ruby27 ruby30 ruby31 ruby32"
RUBY_FAKEGEM_RECIPE_DOC=""
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="History.rdoc README.rdoc RI.md TODO.rdoc"
RUBY_FAKEGEM_BINWRAP=""
RUBY_FAKEGEM_BINDIR="exe"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="RDoc produces HTML and online documentation for Ruby projects."
HOMEPAGE="https://github.com/ruby/rdoc"
SRC_URI="https://github.com/ruby/rdoc/tarball/9684f8537018aa99cb718417bf7ab3443b121d41 -> rdoc-6.14.0-9684f85.tar.gz"

KEYWORDS="*"
LICENSE="Ruby MIT"
SLOT="0"
IUSE="doc"

RDEPEND+=">=app-eselect/eselect-ruby-20220313"

ruby_add_rdepend "
	>=dev-ruby/psych-4.0.0
"

ruby_add_bdepend "
	>=dev-ruby/kpeg-1.1.0-r1
	>=dev-ruby/racc-1.5.2
	dev-ruby/rake
	test? (
		dev-ruby/bundler
		>=dev-ruby/minitest-5.8:5
	)"

post_src_unpack() {
	if [ ! -d "${S}/all/${P}" ] ; then
		mv "${WORKDIR}"/all/ruby-rdoc-* "${S}"/all/"${P}" || die
	fi
}

all_ruby_prepare() {
	# Avoid unneeded dependency on bundler, bug 603696
	sed -i -e '/bundler/ s:^:#:' \
		-e 's/Bundler::GemHelper.gemspec.full_name/"rdoc"/' \
		-e '/rubocop\/rake/ s:^:#:' \
		-e '/RuboCop/,/end/ s:^:#:' Rakefile || die

	# Skip rubygems tests since the rubygems test case code is no longer installed by rubygems.
	sed -i -e '/^task/ s/, :rubygems_test//' Rakefile || die

	sed -i -e 's:_relative ": "./:' ${RUBY_FAKEGEM_GEMSPEC} || die
}

all_ruby_compile() {
	all_fakegem_compile

	if use doc ; then
		ruby -Ilib -S exe/rdoc || die
		rm -f doc/js/*.gz || die
	fi
}

each_ruby_compile() {
	${RUBY} -S rake generate || die
}

all_ruby_install() {
	all_fakegem_install

	for bin in rdoc ri; do
		ruby_fakegem_binwrapper $bin /usr/bin/$bin-2

		for version in $(ruby_get_use_implementations); do
			version=`echo ${version} | cut -c 5-`
			if use ruby_targets_ruby${version}; then
				ruby_fakegem_binwrapper $bin /usr/bin/${bin}${version}
				sed -i -e "1s/env ruby/ruby${version}/" \
					"${ED}/usr/bin/${bin}${version}" || die
			fi
		done
	done
}

pkg_postinst() {
	if [[ ! -n $(readlink "${ROOT}"/usr/bin/rdoc) ]] ; then
		eselect ruby set $(eselect --brief --colour=no ruby show | head -n1)
	fi
}