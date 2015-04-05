#! /usr/bin/perl
# Here we are going to extract quality snips only from HG VCF files: for example (ALL.chr10.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf)
# We will read each line of the input table:
#delimiter is \t
#first we need to skip comments lines that start from ##
#second we need to extract sample labels from line starting with # - starting from column 9

#we will leave the following in each non-commented line
#CHROM POS REF ALT and starting from column 9 - 0/0, 0/1 etc
#we leave only rows where AFmle in column INFO - (set of ;-separated key-value pairs) - is greater than the threshold parameter
 #col 0: chromosome, col 1: position in chromosome, col3 - base in ref genome, col4 - alternate base, col6-filter(PASS), col7-info, [col9 -end] - nucleotide bases, 0/1

use strict;
use Getopt::Long;

my $vcfFile = "";
my $threshold = "";
my $selectedSamplesFile="";
my $samplekeysFile;
my $skip=1;
GetOptions("vcf=s" => \$vcfFile,
		"t=s" => \$threshold,
		"samples=s" => \$samplekeysFile,
		"selection=s" => \$selectedSamplesFile, 
		"skip=s" => \$skip );

#collect program arguments
if($vcfFile eq "" )
{
    print "Error: a vcf file  must be provided: --vcf FILE NAME --t threshold --samples FILE NAME --selection FILE NAME\n";   
    exit 1;
}


my $totalSamples = 0;
#read sample keys file and put them into an array
my @samplekeys;
open my $reader, $samplekeysFile or die "error trying to open dictionary file for reading all sample keys: $!";
while (my $line = <$reader>)
{
   	chomp $line;
	push (@samplekeys, $line); 
	$totalSamples++;
}
close $reader;

#read class labels and put them into a dictionary labelBySample
my %labelBySample;
my $totalSelectedSamples = 0;
open my $reader, $selectedSamplesFile or die "error trying to open dictionary file for reading sample labels: $!";
while (my $line = <$reader>)
{
   	chomp $line;
	my @lineArray = split (',', $line);

	my $key = $lineArray[0]; #original seq key
	my $val = $lineArray[1]; #class label
	
#print $key.' '.$val;
	$labelBySample{$key}=$val;
	$totalSelectedSamples++;
}
close $reader;

print "Total $totalSamples samples, we are interested only in  $totalSelectedSamples out of them\n";

my @titleArray = split (/\./, $vcfFile);

print "processing file $vcfFile Output file: ".$titleArray[0].'.'.$titleArray[1]."_SELECTED_30.csv \n";

#open output file for writing - filtered vcf
open WRITER, '>', $titleArray[0].'.'.$titleArray[1]."_SELECTED_30.csv" or die "error trying to open output file: $!";

#determine which line contains the header and the next one starts the data rows
my $lineCounter=0;

open my $reader, $vcfFile or die "error trying to open input file for reading: $!";

my $validSnips=0;
my $addedSnips = 0;
while (my $line = <$reader>)
{
   	chomp $line;
#10,60969,C,A,0.07,0|1:1.150:-2.47,-0.43,-0.21,0|0:0.000:-0.14,-0.55	
    my @lineArray = split (',', $line);
	
	my $outputLine = $lineArray[0].','.$lineArray[1].','.$lineArray[2].','.$lineArray[3];
	
	#now go through all samples and determine if the variants occur in at least $threshold samples
	my $freq =0;
	my $valid = 1;
	for(my $k=5; $k<= $#lineArray and $valid; $k+=3)
	{
        #split data row
        my @columns = split (/:/, $lineArray[$k]);
		

		my $first = substr $columns[0], 0, 1;
		my $second = substr $columns[0], 2, 1;

		
		if ($first >1 or $second >1)
		{
			$valid =0;
		}
		
		if ($valid)
		{
        	my $key = $samplekeys[$k-5];
			if (exists $labelBySample{$key})
			{
				if ($first > 0 or $second > 0)
				{
					$freq++;
				}
			}        
        }  
    }    
	
	if ($valid and $freq >= $threshold)
	{
		$validSnips++;
		if ($validSnips % $skip == 0)
		{
			#print "added snip $addedSnips from line $lineCounter\n";
			print WRITER $outputLine."\n";
			$addedSnips++;
		}
	}
    $lineCounter++;	
}

print "Added Total $addedSnips variants with frequency >= $threshold in selected samples \n";





