package Acme::Siteswap;
use strict;
use warnings;

=head1 NAME

Acme::Siteswap - Provide information about Juggling Siteswap patterns

=head1 SYNOPSIS

  use Acme::Siteswap;
  my $siteswap = Acme::Siteswap->new(
      pattern => '53142',
      balls => 3,
  );
  print "Awesome!\n" unless $siteswap->valid;

=cut

our $VERSION = '0.01';

=head1 FUNCTIONS

=head2 new

Create a new Acme::Siteswap object.

Options:

=over 4

=item pattern

Mandatory.  The siteswap pattern.  Should be a series of throws.

=item balls

Mandatory.  The number of balls in the pattern.

=back

=cut

sub new {
    my $class = shift;
    my $self = { @_ };
    die "A siteswap pattern is required!" unless defined $self->{pattern};
    die "The number of balls is required!" unless defined $self->{balls};
    bless $self, $class;
    return $self;
}

=head2 valid

Determines if the specified pattern is valid.

=cut

sub valid {
    my $self = shift;
    my $pattern = $self->{pattern};

    my @throws;
    eval { @throws = _pattern_to_throws($pattern) };
    if ($@) {
        $self->{error} = $@;
        return 0;
    }

    # Check that the numbers / throws == # of balls
    my $total = 0;
    for my $t (@throws) {
        $total += $t;
    }

    my $avg = $total / @throws;
    unless ($avg == $self->{balls}) {
        $self->{error} = "sum of throws / # of throws does not equal # of balls!";
        return 0;
    }

    # check for throws landing at the same time
    @throws = (@throws, @throws);
    my @land_in;
    for my $i (0 .. $#throws) {
        my %landed_now;
        for my $j (0 .. $i) {
            $land_in[$j]--;
            $landed_now{$j}++ if $land_in[$j] == 0;
        }
        if (keys %landed_now > 1) {
            $self->{error} = "Multiple throws would land at the same time.";
            $self->{error} .= " (throws " 
                . join(", ", map { $_ + 1 } sort keys %landed_now) . ")";
            return 0;
        }
        $land_in[$i] = $throws[$i];
    }
    return 1;
}

=head2 error

Returns an error message or empty string.

=cut

sub error { $_[0]->{error} || '' }

sub _pattern_to_throws {
    my $pattern = shift;
    if ($pattern =~ m/^\d+$/) {
        return split //, $pattern;
    }
    else {
        die "unable to parse pattern: $pattern";
    }
}

=head1 AUTHOR

Luke Closs, C<< <cpan at 5thplane dut com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-acme-siteswap at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Acme-Siteswap>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT

Copyright 2007 Luke Closs, all rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
