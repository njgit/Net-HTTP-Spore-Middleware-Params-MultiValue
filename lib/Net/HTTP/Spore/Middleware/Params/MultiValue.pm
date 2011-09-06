package Net::HTTP::Spore::Middleware::Params::MultiValue;
BEGIN {
  $Net::HTTP::Spore::Middleware::Params::Basic::VERSION = '0.04';
}
 
# ABSTRACT: Middleware for Multivalue Parameters

=head1 SYNOPSIS
 
 Enables the description of multiple values for a parameter via an array (ref).
 my $client = Net::HTTP::Spore->new;
 my $response = $client->some_remote_action( param1 => [ "value1", "value2", ... ] );

=method _unwind_params 
 
 Expects the spore.params array. If an array ref is detected "unwinds" it.

  E.g.
   spore.params = [ 'num', [1,2,3], 'letter', 'P'  ]
   becomes
   spore.params = [ 'num', 1, 'num', 2, 'num', 3, 'letter', 'P']

=head1 SEE ALSO

=for :list
* L<Net::HTTP::Spore>

=head1 ACKNOWLEDGMENTS

Based on Franck Cuny's other Net::HTTP::Spore middleware.
 
=cut  
 
use Moose;
extends 'Net::HTTP::Spore::Middleware::Params';
use List::MoreUtils qw{natatime};

sub call {
    my ( $self, $req ) = @_;
 
    return unless $self->any_params($req);

    $req->env->{'spore.params'} = $self->_unwind_params (  $req->env->{'spore.params'} );
    
}

sub _unwind_params {
    my $self = shift;
    my $params = shift;

    my ( @out, @unwound);    
    my $it = natatime 2, @$params;
    
    while( my @pairs = $it->() ) {
        
        if (  ref($pairs[1]) eq "ARRAY" ) { 
                     
           @unwound  = map { ( $pairs[0], $_ )  } @{ $pairs[1] };
           push @out, @unwound;                      
        }
        else {
          push @out, @pairs;   
        }      
    }
    return \@out; 
}
1;
__END__