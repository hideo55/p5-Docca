package Docca::Plugin::From::URL;
use Mouse;
use Furl;
use Mouse::Util::TypeConstraints;

our $VERSION = '0.01';

class_type 'Furl';
coerce 'Furl' => from 'HashRef' =>
	via { Furl->new( %{ $_[0] } ) };

no Mouse::Util::TypeConstraints;

has furl => ( is => 'ro', isa => 'Furl', coerce => 1, required => 1 );

sub convert {
	my $self = shift;
	my $url  = shift;
	my $res  = $self->furl->get($url);
	return $res->body;
}

no Mouse;
__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Docca::Plugin::From::URL

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 SEE ALSO

L<Furl>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut