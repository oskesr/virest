package PipeConfig::VirEst;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf');

sub default_options
{
    my ($self) = @_;

    return {

        # Database and AMI
        'pipeline_name'        => 'vir_est',
        'ami_id'               => '',
        
        'reffna' => "s3://osk-virest-eag8/input/ref_ns3_1a.fna",
        'calcentropy' => "s3://osk-virest-eag8/input/calcEntropy.pl",
        'csvpath' => "/output/entropy.csv",
	'bucketname' => "osk-virest-eag8",
	'sfffolder' => "rawseqs",

        # Leave these
        'ensembl_cvs_root_dir' => $ENV{'ENSEMBL_SRC'},
        'pipeline_db' => {
            -host   => 'localhost',
            -port   => 3306,
            -user   => $ENV{'EHIVE_USER'},
            -pass   => $ENV{'EHIVE_PASS'},
            -dbname => $self->o('pipeline_name'),
        },
    };
}

sub resource_classes
{
     my ($self) = @_;

     my $ami = $self->o('ami_id');
     if (my $g = $ENV{'EC2_EHIVE_WORKER_SECURITY_GROUP'}) {
         $ami .= " -g $g";
     }
     if (my $r = $ENV{'EC2_EHIVE_IAM_ROLE'}) {
         $ami .= " -p $r";
     }

     return {
        0 => { -desc => "t1.micro",   EC2 => "$ami -t t1.micro"},
        1 => { -desc => "m1.small",   EC2 => "$ami -t m1.small"},
     };
}

sub pipeline_create_commands
{
    my ($self) = @_;
    return [
        @{ $self->SUPER::pipeline_create_commands },
    ];
}

sub pipeline_analyses
{
    my ($self) = @_;
    my $reffna = $self->o('reffna');
    my $calcentropy = $self->o('calcentropy');
    my $csvpath = $self->o('csvpath');
    my $bucketname = $self->o('bucketname');
    my $sfffolder = $self->o('sfffolder');

    return [

        {
             -logic_name => 'initnewrun',
             -module     => 'Runnable::InitNewRun',
             -hive_capacity => -1,
             -parameters => {
             },
             -input_ids => [ { 'bucketname' => $bucketname, 'sfffolder' => $sfffolder } ],
             -flow_into => { 1 => ['listsff', 'finentropy'], },
             -rc_id => 0
        },

        {
             -logic_name => 'listsff',
             -module     => 'Runnable::ListSff',
             -hive_capacity => -1,
             -parameters => {
             },
             -wait_for => [ 'initnewrun' ],
             -flow_into => { 1 => ['extractsff'], },
             -rc_id => 0
        },
	
	{
             -logic_name => 'extractsff',
             -module     => 'Runnable::ExtractSff',
             -hive_capacity => -1,
	     -parameters => {
	     },
	     -wait_for => [ 'listsff' ],
	     -flow_into => { 1 => ['cutadapt'], },
             -rc_id => 0
        },
        
        {
             -logic_name => 'cutadapt',
             -module     => 'Runnable::CutAdapt',
             -hive_capacity => -1,
             -parameters => {
             },
	     -wait_for => [ 'extractsff' ],
             -flow_into => { 1 => ['bwalign'], },
             -rc_id => 0
        },
        
        {
             -logic_name => 'bwalign',
             -module     => 'Runnable::BwAlign',
             -hive_capacity => -1,
             -parameters => {
		    'reffna' => $reffna
             },
             -wait_for => [ 'cutadapt' ],
             -flow_into => { 1 => ['samtools'], },
             -rc_id => 0
        },
        
        {
             -logic_name => 'samtools',
             -module     => 'Runnable::SamTools',
             -hive_capacity => -1,
             -parameters => {
                    'reffna' => $reffna
             },
             -wait_for => [ 'bwalign' ],
             -flow_into => { 1 => ['getentropy'], },
             -rc_id => 0
        },

        {
             -logic_name => 'getentropy',
             -module     => 'Runnable::GetEntropy',
             -hive_capacity => -1,
             -parameters => {
                    'calcentropy' => $calcentropy
             },
             -wait_for => [ 'samtools' ],
             #-flow_into => { 1 => [ 'allentropy' ],},
             -rc_id => 0
        },

        {
             -logic_name => 'finentropy',
             -module     => 'Runnable::FinEntropy',
             -hive_capacity => -1,
             -parameters => {
                    'csvpath' => $csvpath
             },
             -wait_for => [ 'getentropy' ],
             #-flow_into => { 1 => [ '' ],},
             -rc_id => 0
        },

    ];
}

1;

