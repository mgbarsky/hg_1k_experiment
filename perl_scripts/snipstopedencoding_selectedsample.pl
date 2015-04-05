#! /usr/bin/perl
# Here we are going to create an input for FRAPPE program from selected SNPS in a sampled VCF file
# We will read each line of the filtered input table (in file ALL_QUALITY_SNIPS.csv_sample.csv): 
# here each column represents a sample: 0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/1
# we have original sample keys (column headers from vcf now rows in file ALL.chr5.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf_SAMPLE_KEYS.csv)
# we have a selection of 30 keys in file FILE_NAMES_30.txt
# we have class labels for these samples in FILE_LABELS_30.csv
# we are going to read each line
# select only 30 columns of interest (according to file_names (or file_labels30))
# see if at least 3 samples have non-zero entry (meaning differ from ref genome)
# convert this line into ped format
# record corresponding line number for further reference

use strict;
use Getopt::Long;

my $snipTableFile = "";
my $originalColumnsFile ="";
my $sampleKeyLabelsFile = "";

GetOptions("snips=s" => \$snipTableFile,
		"columns=s" => \$originalColumnsFile,
        "labels=s" => \$sampleKeyLabelsFile);

#collect program arguments
if($snipTableFile eq "" or  $originalColumnsFile eq "" or $sampleKeyLabelsFile eq "")
{
    print "Error: a table of snips file, the column names file, and the selected sample-labels files  must be provided: --snips FILE NAME --columns FILE NAME --labels FILE NAME\n";   
    exit 1;
}

#open output file for writing - ped encoding
open WRITER, '>', $snipTableFile."SELECTED.ped" or die "error trying to open output file: $!";

#open output file for writing selected line numbers
open my $lineNumberFileWriter, '>', $sampleKeyLabelsFile.".selected_lines.txt" or die "error trying to open output file: $!";

my %labelBySample;

#position in this array corresponds to a column index, value represents sample name
my @sampleKeys;


#read class labels and put them into a dictionary labelBySample
 my $totalSelectedSamples = 0;
open my $reader, $sampleKeyLabelsFile or die "error trying to open dictionary file for reading sample labels: $!";
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


#read sample keys to know the actual key for each column in a snips table

open my $reader, $originalColumnsFile or die "error trying to open file for reading sample keys: $!";
while (my $line = <$reader>)
{
   	chomp $line;
	push (@sampleKeys, $line);
	
}
close $reader;
#now each column is mapped to a key - they are in the same order as in array sampleKeys

my $totalSamples = $#sampleKeys+1;
print "Processing file $snipTableFile with $totalSamples samples from which I want to select only $totalSelectedSamples.\n";

# initialize an array to hold lines to be written to the output file
#6 first columns of ped format. Delimiter - space
#   0 - Family ID - $labelBySample{$key}
#   1 - Sample ID - $key 
#    Paternal ID - 0 unknown
#    Maternal ID - 0 unlnown
#    Sex (1=male; 2=female; other=unknown) 0 - unlnown
#    Affection (0=unknown; 1=unaffected; 2=affected) 0 unknown
 #   Genotypes (space or tab separated, 2 for each marker. 0=missing) - 1 1 if ref char, 2 2 - if both alt chars, 1 2 otherwise
my @pedLines;

for (my $i=0; $i<$totalSamples ; $i++)
{
    my $sampleKey = $sampleKeys[$i];
	if (exists $labelBySample{$sampleKey})
	{
    	my $sampleType = $labelBySample{$sampleKey};    	
    
    	my $lineHeader = $sampleType.' '.$sampleKey.' 0 0 0 0';
		#print $lineHeader;
		push (@pedLines, $lineHeader);
    }    
}

#open input file for reading
open my $reader, $snipTableFile or die "error trying to open file for reading snips: $!";

#sample line in snips table
# # 0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/1  
# sample line in the original snips table
# 0-chr, 1-position, 2-ref char, 3-alt char, 4-percentage of variance, from 5 -for each sample in sampleKeys - 0-ref char, 1-alt char 
#20,15045215,G,C,0.57285,0/0,0/1,0/0,1/1,0/1,0/0,0/0,1/1,0/1,1/1,0/1,1/1


my $lineID =0;

my $selectedLineNumbers ="";

#we are going to select only snip lines where 10% of samples differ from ref genome
my $minThreshold = int (0.1 * $totalSelectedSamples);
print "At least $minThreshold should differ from the reference genome \n";

my $selectedSnipsCount =0;
while(my $line = <$reader>)
{
	chomp $line;   
	#split content of a comma-separated line into an array: @line 
	my @lineArray = split(',',$line);

   	my $rowSamples = $#lineArray+1  ;
	if($rowSamples != $totalSamples)
	{
		print "There should be $totalSamples columns, but there are actually $rowSamples columns in line $lineID .\n";
		exit (1);
	}
	
	#first we are going to count in how many samples this snip is different from 0 - different from ref genome
	my $totalVariantsInRow =0;
	for (my $i=0; $i<=$#lineArray ; $i++)
	{
		#retrieve sample key for this column
		my $sampleKey = $sampleKeys[$i];

		#we are interested only in a handful of samples
		if (exists $labelBySample{$sampleKey})
		{
			if(length ($lineArray[$i]) == 3) 
		    {		        
		        #we need to get chars at positions 0 and 2 of this entry
				my $c1 = substr( $lineArray[$i], 0 , 1 );
				my $c2 = substr( $lineArray[$i], 2 , 1 );

				my $allele1 = int ($c1);
				my $allele2 = int ($c2);

				if($allele1 > 0 or $allele2 > 0)
				{
					$totalVariantsInRow++;
				}
		    }        	
		}    
	}

	if ($totalVariantsInRow >= $minThreshold)
	{
		$selectedSnipsCount++;
		my $pedLineIndex =0;

		for (my $i=0; $i<=$#lineArray ; $i++)
		{
			#retrieve sample key for this column
			my $sampleKey = $sampleKeys[$i];

			#we are interested only in a handful of samples
			if (exists $labelBySample{$sampleKey})
			{
				my $pedEncodingForSample;
				if(length ($lineArray[$i]) != 3) #invalid entry not of form 0/0, 0/1 or 1/1 - missing value
				{
				    $pedEncodingForSample=' 0 0';
				    print "Unexpected value for snp ".$lineArray[$i]."\n";
				    exit(1); 
				}
				else
				{
				    #we need to get chars at positions 0 and 2 of this entry
					my $c1 = substr( $lineArray[$i], 0 , 1 );
					my $c2 = substr( $lineArray[$i], 2 , 1 );

					my $allele1 = int ($c1);
					my $allele2 = int ($c2);

					if($allele1 >1 or $allele2 >1)
					{
						print "Unexpected value for snp alleles ".$allele1." and ".$allele2."\n";
				        exit(1); 
					}
				    else
				    {
				        $pedEncodingForSample = getAlleleEncoding ($allele1,$allele2);
				    }
				}
		    	$pedLines[$pedLineIndex] = $pedLines[$pedLineIndex].$pedEncodingForSample;   
				$pedLineIndex++; 
			}    
		}
		#print "Line $lineID added \n";

		$selectedLineNumbers = $selectedLineNumbers.$lineID."\n";
	}	
		
	$lineID++;		
}

print STDERR "Total valid variants $selectedSnipsCount and $totalSelectedSamples samples. \n";

#write ped lines to a file
for ( my $sampleID=0; $sampleID<$totalSelectedSamples ; $sampleID++)
{		
       print WRITER $pedLines[$sampleID]."\n";        
}

#write selected line numbers to a file
print $lineNumberFileWriter $selectedLineNumbers;	

sub getAlleleEncoding
{
	my ($first, $second) = @_;
	
	if($first == $second)
	{
		if($first == 0) #both zero
		{
			return ' 1 1';
		}
		else
		{
			return ' 2 2';
		}
	}
	return ' 1 2';
}


