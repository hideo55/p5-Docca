use strict;
use Test::More tests => 1;
use Docca;
my $docca = Docca->new(
	from => { URL => { furl => { timout => 10 } }, },
	to   => { HTML => {}, },
	tx => { path => [qw/./], cache => 0 },
);

my $template = '<: $body :>';

my $url = 'http://google.co.jp';

my $res
	= $docca->convert( source => $url, template => \$template )->from('URL')
	->to('HTML');

ok $res;
