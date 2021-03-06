#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=pod 

=head1 NAME

Runnable::BwAlign;

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

package Runnable::BwAlign;

use strict;

use Bio::EnsEMBL::Hive::Process;
use Bio::EnsEMBL::Hive::Utils::S3Utils;
use File::Temp;

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
    
    my $trimfastq = $self->param('trimfastq');
    my $reffna = $self->{'reffna'};
    
    my $aln=$trimfastq;
    $aln=~s/_tr.fq/.sam/;
    $aln=~s/trimfastq/bwaalign/;

    my $localtrimfastq=$s3_utils->s3get($trimfastq);
    my $localreffna=$s3_utils->s3get($reffna);    
    my $localaln=File::Temp->new;

    system( "bwa index $localreffna" ) && die qq(error BwaIndex failed);      
    system( "bwa mem $localreffna $localtrimfastq > $localaln") && die qq(error BwaAlign failed);
    
    $s3_utils->s3put($localaln,$aln);   
    $self->dataflow_output_id({ aln => $aln }, 1);
    #print $message;
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
