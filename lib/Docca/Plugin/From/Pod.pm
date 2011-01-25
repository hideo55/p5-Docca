package Docca::Plugin::From::Pod;
use Mouse;
use Pod::Simple::XHTML;

our $VERSION = '0.01';

has options => ( is => 'ro', isa => 'HashRef', default => sub { +{} }, )
	;

sub convert {
	my $self = shift;
	my $in   = shift;
	my $p    = Pod::Simple::XHTML->new( %{ $self->options } );
	my $out;
	$p->output_string( \$out );
	$p->html_header('');
	$p->html_footer('');
	$p->parse_string_document($in);
	return $out;
}

no Mouse;
__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Docca::Plugin::From::Pod

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 SEE ALSO

L<Pod::Simple::XHTML>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut