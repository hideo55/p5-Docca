package Docca;
use Mouse;
use Mouse::Util::TypeConstraints;
use Text::Xslate;

our $VERSION = '0.01';

subtype 'FromPlugins' => as 'HashRef[CodeRef]';
coerce 'FromPlugins' => from 'HashRef' => via {
	my $config = shift;
	my %plugins;
	for my $p ( keys %$config ) {
		my $class = 'Docca::Plugin::From::' . $p;
		Mouse::Util::load_class($class)
			unless Mouse::Util::is_class_loaded($class);
		my $obj = $class->new( $config->{$p} );
		if ( $class->can('convert') ) {
			$plugins{$p} = sub {
				my ( $text, $params ) = @_;
				$obj->convert( $text, $params );
			};
		}
		else {
			die qq{The $class is not implemented 'convert' method};
		}
	}
	return \%plugins;
};

subtype 'ToPlugins' => as 'HashRef[CodeRef]';
coerce 'ToPlugins' => from 'HashRef' => via {
	my $config = shift;
	my %plugins;
	for my $p ( keys %$config ) {
		my $class = 'Docca::Plugin::To::' . $p;
		Mouse::Util::load_class($class)
			unless Mouse::Util::is_class_loaded($class);
		my $obj = $class->new( $config->{$p} );
		if ( $class->can('convert') ) {
			$plugins{$p} = sub {
				my ( $text, $params ) = @_;
				$obj->convert( $text, $params );
			};
		}
		else {
			die qq{The $class is not implemented 'convert' method};
		}
	}
	return \%plugins;
};

subtype 'Text::Xslate' => as 'Object';
coerce 'Text::Xslate'  => from 'HashRef' =>
	via { Text::Xslate->new( %{ $_[0] } ) };

no Mouse::Util::TypeConstraints;

has from_plugins => (
	init_arg => 'from',
	is       => "ro",
	isa      => 'FromPlugins',
	required => 1,
	coerce   => 1,
);

has to_plugins => (
	init_arg => 'to',
	is       => 'ro',
	isa      => 'ToPlugins',
	required => 1,
	coerce   => 1,
);

has tx => (
	is      => 'ro',
	isa     => 'Text::Xslate',
	coerce  => 1,
	default => sub { Text::Xslate->new() }
);

sub convert {
	my $self = shift;
	my %args = @_;
	my ( $source, $template, $options )
		= map { $args{$_} } qw(source template options);

	$source   || die "You must supply parameter 'source'";
	$template || die "You must supply parameter 'template'";

	$options ||= {};

	delete $options->{$_} for qw(docca source template);

	return Docca::Converter->new(
		docca    => $self,
		source   => $source,
		template => $template,
		%$options
	);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

package Docca::Converter;
use Mouse;

has docca => ( is => 'ro', isa => 'Docca', required => 1, );
has source   => ( is => 'rw', required => 1 );
has template => ( is => 'ro', isa      => 'Str|ScalarRef' );
has template_vars =>
	( is => 'ro', isa => 'HashRef', default => sub { +{} }, );
has html => ( is => 'rw', predicate => 'has_html', );

sub from {
	my $self = shift;
	my ( $format, $options ) = @_;

	$format || die "You must supply plugin name as first argment";

	my $docca = $self->docca;

	if ( my $formatter = $docca->from_plugins->{$format} ) {
		my $html_body = $formatter->( $self->source, $options );
		my %vars = (
			%{ $self->template_vars },
			body => Text::Xslate::mark_raw($html_body)
		);
		my $template = $self->template;
		$self->html(
			ref $template
			? $docca->tx->render_string( $$template, \%vars )
			: $docca->tx->render( $template, \%vars )
		);
	}
	else {
		die "Invalid plugin name.";
	}

	return $self;
}

sub to {
	my $self = shift;
	my ( $format, $options ) = @_;

	die qq{You must call '\$obj->from()' before calling this method}
		unless $self->has_html;

	$format || die "You must supply plugin name as first argment";

	if ( my $formatter = $self->docca->to_plugins->{$format} ) {
		return $formatter->( $self->html, $options );
	}
	else {
		die "Invalid plugin name";
	}
}

no Mouse;
__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Docca - Document Convert API.

=head1 SYNOPSIS

  use Docca;
  
  my $docca = Docca->new(
      tx => { path => [qw(.)], cache => 1 },
      from => {
    	  Xatena => { converter => { hatena_compatible => 1 } },
    	  Markdown => { converter => { tab_width => 4 } },
      },
      to => {
          PDF => {},
          Image => {},
      },    
  );
  
  oepn my $fh, '<', $ARGV[0] || die $!;
  my $in_data = do{ local $/;<$fh> };
  close $fh;
  
  my $pdf = $docca->convert( source => $in_data, templte => 'default.tx' )
	->from('Xatena')
	->to('PDF',{ encoding => 'utf-8' });

=head1 DESCRIPTION

Docca convert formatted documents to other formatted document.

=head1 METHODS

=head2 B< new(%params) >

Create new Docca instance with options,

Options are:

=over 4

=item C< tx => \%options >

Specifies template engine's options.See L<Text::Xslate>

=item C< from => \%plugins >
Specifies 'Docca::Plugin::From::*' plugins and plugin's options.

example:
{
	PLUGIN_NAME => \%PLUGIN_OPTIONS,
	...
}

=item C< to => \%plugins >

Specifies 'Docca::Plugin::To::*' plugins and plugin's options.

example:
{
	PLUGIN_NAME => \%PLUGIN_OPTIONS,
	...
}

=back

=head2 B< convert(%params) >

Create new Docca::Converter's instance.

Parameters are:

=over

=item C< source => $string >

Specifies convert target string.

=item C< template => $file or \$string >

Specifies template file name.

If $template is scalar reference, $template is handled as reference to the template string.

=item C< options => \%options >

Specifies othoer options. e.g.'template_vars'.

=back

=head1 Docca::Converter's METHODS

=head2 B< from($plugin,\%$options) >

Specifies 'Docca::Plugin::From::*' plugin name and options.

=head2 B< to($plugin,\%options) >

Specifies 'Docca::Plugin::To::*' plugin name and options.

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 SEE ALSO

L<Text::Xslate>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
