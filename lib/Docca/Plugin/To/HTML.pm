package Docca::Plugin::To::HTML;
use Mouse;

our $VERSION = '0.01';

sub convert {
	return $_[1];
}

__PACKAGE__->meta->make_immutable;
__END__


=head1 NAME

Docca::Plugin::To::HTML

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
