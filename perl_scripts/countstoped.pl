#! /usr/bin/perl
# Here we are going to create an input for FRAPPE/ADMIXURE program from SNP pair counts
# We will read each line of the input table: col 0: sample id, col 1: class label, 
# [col2 -end] - counts pairs, first - of the ref gen k-mer, second - of the alternative k-mer

#Referring alleles from counts
# ref >0, alt > 0  - 1 2
# ref >0, alt =0   - 1 1
#ref =0, alt >0    - 2 2
# ref=0, alt =0 - 0 0 (undefined)

# we will remove every count > 30
#we will remove all which are undefined
# we will remove all which have all 1 1 (at least 3 should be different from ref gen)

use strict;
use Getopt::Long;

my $snipTableFile = "";
my $minThreshold = 3;
GetOptions("table=s" => \$snipTableFile, "min=s" => \$minThreshold);

#collect program arguments
if($snipTableFile eq "" )
{
    print "Error: a table of snip pair counts file  must be provided: --table FILE NAME \n";   
    exit 1;
}

if ($minThreshold eq "")
{
	$minThreshold = 3;
}
#open output file for writing temp ped encoding
open WRITER, '>', $snipTableFile."TEMP.ped" or die "error trying to open output file: $!";

my %noVarianceColumns;
my %undefinedColumns;
my %someUndefined;

print "Processing file $snipTableFile.\n";
#we are going to select only snip lines where 10% of samples differ from ref genome

#print "At least $minThreshold should differ from the reference genome \n";

#open input file for reading
open my $reader, $snipTableFile or die "error trying to open file for reading snip counts: $!";

#sample line in counts table (comma-delimited)
# # NA11830	EUR	0	7	4	0	1	1	0	2	3	0	0	0	0	0	0

my $lineID =0;
my @altSamplesCount;
my @missingCounts;  
while(my $line = <$reader>)
{

	chomp $line;   
	#split content of a comma-separated line into an array: @line 
	my @lineArray = split(',',$line);

	if ($lineID == 0) #initialize per snip count array
	{
		for (my $k=2; $k <= $#lineArray; $k=$k+2)
		{
			push (@altSamplesCount, 0);
			push (@missingCounts, 0);
		}
	}
   	
	
	my $totalVariantsInRow =0;
	my $pedLine = $lineArray[0].' '.$lineArray[1].' 0 0 0 0';
	for (my $i=2; $i<=$#lineArray ; $i+=2)
	{
		
		my $c1 = int ($lineArray[$i]);
		my $c2 = int ($lineArray[$i+1]);

		if ($c1 > 0 and $c2 > 0) #heterozygote of type ref/alt
		{
			$pedLine = $pedLine." 1 2";
			#that differs from ref gen and we add 1 to the count of alt alleles
			$altSamplesCount[($i -2)/2] ++;
		}

		if ($c1 > 0 and $c2 == 0) #homozygote of type reference
		{
			$pedLine = $pedLine." 1 1";
		}
		
		if ($c1 == 0 and $c2 > 0) #homozygote of type alt
		{
			$pedLine = $pedLine." 2 2";
			#that differs from ref gen and we add 1 to the count of alt alleles
			$altSamplesCount[($i -2)/2] ++;			
		}
		
		if ($c1 == 0 and $c2 == 0) #homozygote of type reference
		{
			$pedLine = $pedLine." 0 0";
			$someUndefined {($i -2)/2}  = 1;
			$missingCounts[($i -2)/2] ++;
		}
		$totalVariantsInRow++;
				
	}
	print "Pre-processed sample ".$lineArray[0]." with $totalVariantsInRow original variants\n";
	print WRITER $pedLine."\n";
	$lineID++;
}

close WRITER;
close $reader;


for (my $i=0; $i<=$#altSamplesCount ; $i++)
{
	if ($altSamplesCount[$i] < $minThreshold)
	{
		$noVarianceColumns{$i} = 1;
	}

	if ($missingCounts [$i] == $lineID)
	{
		$undefinedColumns{$i} = 1;
	}
}

#now read temp ped file, and leave only columns which are not recorded in %undefinedColumns or in %noVarianceColumns

open my $reader, $snipTableFile."TEMP.ped" or die "error trying to open temp file for reading: $!";

#open output file for writing final ped encoding
open WRITER, '>', $snipTableFile.".ped" or die "error trying to open final output file: $!";

while(my $line = <$reader>)
{
	chomp $line;   
	#split content of a comma-separated line into an array: @line 
	my @lineArray = split(' ',$line);

	#first 6 elements are for header   	
	my $pedLine = $lineArray[0].' '.$lineArray[1].' 0 0 0 0';
	
	my $totalValidVariantsInRow =0;
	
	for (my $i=6; $i<=$#lineArray ; $i+=2)
	{
		if (  not exists $undefinedColumns{($i -6)/2}  )
		{
			my $c1 = $lineArray[$i];
			my $c2 = $lineArray[$i+1];

			$pedLine = $pedLine.' '.$c1.' '.$c2;
			
			$totalValidVariantsInRow ++;
		}				
	}
	print "Finished sample ".$lineArray[0]." with $totalValidVariantsInRow valid variants\n";
	print WRITER $pedLine."\n";
}

close WRITER;
close $reader;
