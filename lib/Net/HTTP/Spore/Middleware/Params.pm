use strict;
use warnings;
package Net::HTTP::Spore::Middleware::Params;


BEGIN {
  $Net::HTTP::Spore::Middleware::Params::VERSION = '0.04';
}
 
# ABSTRACT: base class for Param middlewares


=head1 ACKNOWLEDGMENTS

Based on Franck Cuny's other Net::HTTP::Spore middleware.

=cut
 
use Moose;
extends 'Net::HTTP::Spore::Middleware';
 
sub any_params { $_[1]->env->{'spore.params'} }
 
sub call { die "should be implemented" }
 
1;
 
 
__END__

1;
