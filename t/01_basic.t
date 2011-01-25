use strict;
use Test::More;
use Test::Fatal;
use Docca;
use Data::Section::Simple;

{

	#Mock plugins
	package Docca::Plugin::From::Foo;
	use Mouse;

	sub convert {
		return uc( $_[1] );
	}

	package Docca::Plugin::To::Bar;
	use Mouse;

	sub convert {
		my $data = $_[1];
		$data =~ s{</body>}{BAR</body>};
		return $data;
	}

	#Bad plugins
	package Docca::Plugin::From::Baz;
	use Mouse;

	package Docca::Plugin::To::Qux;
	use Mouse;
}

like exception {
	Docca->new( from => { NotExists => {} }, to => { PDF => {}, }, );
},
	qr/^Could not load class \(Docca::Plugin::From::NotExists\)/;

like exception {
	Docca->new(
		from => { Foo       => { converter => {} } },
		to   => { NotExists => {}, },
	);
}, qr/^Could not load class \(Docca::Plugin::To::NotExists\)/;

like exception {
	Docca->new( from => { Baz => {} }, to => { Bar => {}, }, );
}, qr/^The Docca::Plugin::From::Baz is not implemented 'convert' method/;

like exception {
	Docca->new( from => { Foo => {} }, to => { Qux => {}, }, );
}, qr/^The Docca::Plugin::To::Qux is not implemented 'convert' method/;

my $docca = Docca->new(
	from => { Foo => {} },
	to   => { Bar => {} },
	tx   => {
		path  => [ Data::Section::Simple->new->get_data_section ],
		cache => 0
	},
);

isa_ok $docca, 'Docca';

like exception {
	$docca->convert();
}, qr/^You must supply parameter 'source'/;

like exception {
	$docca->convert( source => 'foo' );
}, qr/^You must supply parameter 'template'/;

my $converter = $docca->convert( source => 'foo', template => 'default.tx' );

isa_ok $converter, 'Docca::Converter';

like exception {
	$converter->to('Bar');
}, qr/^You must call '\$obj->from\(\)' before calling this method/;

like exception {
	$converter->from();
}, qr/^You must supply plugin name as first argment/;

like exception {
	$converter->from('Baz');
}, qr/^Invalid plugin name/;

like exception {
	$converter->from('Foo')->to();
}, qr/^You must supply plugin name as first argment/;

like exception {
	$converter->from('Foo')->to('Quxx');
}, qr/^Invalid plugin name/;
my $res = $converter->from('Foo')->to('Bar');

like $res, qr/<body>FOOBAR<\/body>/;

my $template
	= q{<html><head></head><body><: $head :><: $body :></body></html>};

$res = $converter = $docca->convert(
	source   => 'foo',
	template => \$template,
	options  => { template_vars => { head => 'foo' } }
)->from('Foo')->to('Bar');

is $res, '<html><head></head><body>fooFOOBAR</body></html>';

done_testing;
__DATA__
@@ default.tx
<html>
<head></head>
<body><: $body :></body>
</html>
