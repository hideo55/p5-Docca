package Docca::Plugin::To::Image;
use Mouse;
use Mouse::Util::TypeConstraints;
use utf8;
use Encode;
use IPC::Run qw(run);
use File::Which;

our $VERSION = '0.01';

subtype 'Command' => as => 'Str' => where { -X $_[0] };

no Mouse::Util::TypeConstraints;
has bin_name => (
	is      => 'ro',
	isa     => 'Command',
	default => sub { which('wkhtmltoimage') },
);

sub convert {
	my $self   = shift;
	my ($in, $params) = @_;
	
	$params ||= {};

	my @cmd = ( $self->bin_name );
	while ( my ( $key, $value ) = each %$params ) {
		push @cmd, length($key) > 1 ? qq{--$key} : qq{-$key};
		push @cmd, $value if $value;
	}

	push @cmd, "-", "-";

	if ( Encode::is_utf8($in) ) {
		$in = Encode::encode_utf8($in);
	}
	
	my ( $out, $err );
	run \@cmd, \$in, \$out, \$err;
	die "Can't convert to Image because $err" if $err !~ /^Loading page/;

	return $out;
}

__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Docca::Plugin::To::Image

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
