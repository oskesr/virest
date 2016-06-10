#!/user/bin/env perl
use strict;
use warnings;
use autodie;
use File::Basename; 

my ($vcf)= @ARGV;

my $samplename=$vcf;
$samplename=~s/\.vcf$//;
$samplename=basename($samplename);

my $entropyfile=$vcf;
$entropyfile=~s/.vcf/.ent/;

my $entropy= 0;
my $lines= 0;

open(F1, "$vcf") || die " Unable to load $vcf.\n";
while(<F1>){
if ($lines > '1'){
#warn($_);
}
$lines++;	
} # end while
close(F1);

open my $fh,'>',$entropyfile;

$entropy=$lines;
print $fh "$samplename,$entropy\n";
