# Distributed under the terms of the GNU General Public License v2

EAPI=7

USE_RUBY="ruby27 ruby30 ruby31 ruby32"
RUBY_FAKEGEM_BINWRAP=""
RUBY_FAKEGEM_EXTRADOC="README.md doc/reline/face.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="The compatible library with the API of Ruby's stdlib 'readline', GNU Readline and Editline by pure Ruby implementation."
HOMEPAGE="https://github.com/ruby/reline"
SRC_URI="https://github.com/ruby/reline/tarball/0a6090340f6f9a9b3e6b21edc92373a1d2f8922f -> reline-0.6.1-0a60903.tar.gz"

LICENSE="BSD-3"
KEYWORDS="*"
SLOT="0"
IUSE="test"

ruby_add_bdepend "test? ( dev-ruby/test-unit )"
ruby_add_rdepend "dev-ruby/io-console"

post_src_unpack() {
	if [ ! -d "${S}/all/${P}" ] ; then
	        mv "${WORKDIR}"/all/ruby-reline-* "${S}"/all/"${P}" || die
	fi
}

all_ruby_prepare() {
	sed -e "s:_relative ':'./:" \
		-i ${RUBY_FAKEGEM_GEMSPEC} || die
}

each_ruby_test() {
	${RUBY} -Ilib:.:test/reline -rhelper -e 'Dir["test/**/test_*.rb"].each{|f| require f}' || die
}