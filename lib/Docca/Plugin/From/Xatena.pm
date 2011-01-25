package Docca::Plugin::From::Xatena;
use Mouse;
use Mouse::Util::TypeConstraints;
use Text::Xatena;

our $VERSION = '0.01';

class_type 'Text::Xatena';
coerce 'Text::Xatena' => from 'HashRef' =>
  via { Text::Xatena->new( %{ $_[0] } ) };

no Mouse::Util::TypeConstraints;

has converter => ( is => 'ro', isa => 'Text::Xatena', coerce => 1, required => 1 );

sub convert {
	my $self = shift;
	my $text = shift;
	return $self->converter->format($text);
}

no Mouse;
__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Docca::Plugin::From::Xatena

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 SEE ALSO

L<Text::Xatena>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut