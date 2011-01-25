package Docca::Plugin::From::Markdown;
use Mouse;
use Mouse::Util::TypeConstraints;
use Text::MultiMarkdown;

our $VERSION = '0.01';

class_type 'Text::MultiMarkdown';
coerce 'Text::MultiMarkdown' =>
	from 'HashRef' => via { Text::MultiMarkdown->new(%{ $_[0] }) };

no Mouse::Util::TypeConstraints;

has converter =>
  ( is => 'ro', isa => 'Text::MultiMarkdown', coerce => 1, required => 1, )
  ;

sub convert {
	my $self = shift;
	return $self->converter->markdown(shift);
}

no Mouse;
__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Docca::Plugin::From::Markdown

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 SEE ALSO

L<Text::MultiMarkdown>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut