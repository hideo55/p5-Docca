use strict;
use Test::More tests => 1;
use Docca;
use Data::Section::Simple;

my $docca = Docca->new(
	from => { Pod => {}, },
	to   => { HTML => {}, },
	tx   => {
		path  => [ Data::Section::Simple->new->get_data_section ],
		cache => 0
	},
);

my $in = <<"__POD__";
=pod

=head1 NAME

Foo

=head1 METHODS

=over 4

=item * foo

=item * bar

=item * baz

=back

=cut
__POD__

my $res
	= $docca->convert( source => $in, template => 'default.tx' )->from('Pod')
	->to('HTML');

ok $res;

__DATA__
@@ default.tx
<html>
<head>
<style type="text/css">
.str { color: #080; }
.kwd { color: #008; }
.com { color: #800; }
.typ { color: #606; }
.lit { color: #066; }
.pun { color: #660; }
.pln { color: #000; }
.tag { color: #008; }
.atn { color: #606; }
.atv { color: #080; }
.dec { color: #606; }
pre.prettyprint { padding: 2px; border: 1px solid #888; }
</style>
</head>
<body>
<: $body :>
</body>
</html>
