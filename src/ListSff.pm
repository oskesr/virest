#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=pod 

=head1 NAME

Runnable::ListSff;

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This object is used as a place holder in the hive system.
It does nothing, but is needed so that a Worker can grab
a job, pass the input through to output, and create the
next layer of jobs in the system.

=cut

=head1 CONTACT

=cut

=head1 APPENDIX

The rest of the documentation details each of the object methods. 
Internal methods are usually preceded with a _

=cut

package Runnable::ListSff;

use strict;

use Bio::EnsEMBL::Hive::Process;
use Bio::EnsEMBL::Hive::Utils::S3Utils;
#use File::Temp;

our @ISA = qw(Bio::EnsEMBL::Hive::Process);

##############################################################
#
# override inherited fetch_input, run, write_output methods
# so that nothing is done
#
##############################################################

sub fetch_input {
    my $self = shift;

    $self->get_params( $self->parameters );

    return 1;
}

sub run {

    my ($self) = @_;
    #my $message = $self->{'message'};
    my $s3_utils = Bio::EnsEMBL::Hive::Utils::S3Utils->new;

    my $id = $self->param('timestamp'); 
    chomp $id;
    my $sffsourcepath = $self->param('sffsourcepath');

    my @files = @{$s3_utils->s3ls("$sffsourcepath/")};
    shift @files;
    foreach (@files) {
    $self->dataflow_output_id({ sff => $_, timestampid => $id }, 1);
    }
    #print $message;
    print join(";",@files);
    return 1;
}

# copy output files
sub write_output
{
    my $self = shift;

    return 1;
}

sub get_params {
    my $self         = shift;
    my $param_string = shift;

    return unless ($param_string);
    print( " parsing parameter string : ", $param_string, "\n" )
      if ( $self->debug );

    my $params = eval($param_string);
    return unless ($params);

    if ( $self->debug && ref($params) eq 'HASH' ) {
        foreach my $key ( keys %$params ) {
            print( "  $key : ", $params->{$key}, "\n" );
        }
    }
    if ( ref($params) eq 'HASH' ) {
        foreach my $key ( keys %$params ) {
            $self->{$key} = $params->{$key};
        }
    }
}

1;
