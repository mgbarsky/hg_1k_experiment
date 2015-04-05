#! /usr/bin/perl
# Here we are converting a snp matrix from the ped file for a set of samples
# We will read each line of the ped file
#sample line in ped file table - delimiter - space
#0-class label, 1-sample key, 2-father id, 3-mother id, 4-sex, 5-affected, from 6 each 2 represent biallelic snip: 1 1, 1 2, or 2 2. If zero - missing value 

use strict;
use Getopt::Long;

my $pedFile = "";
GetOptions("ped=s" => \$pedFile);

#collect program arguments
if($pedFile eq "" )
{
    print "Error: a ped file name must be provided: --ped FILE NAME \n";   
    exit 1;
}

#open output file for writing a matrix
open WRITER, '>', $pedFile.".matrix.csv" or die "error trying to open output file: $!";


print "Processing file $pedFile into a matrix. \n";


my $lineID =0;

#open input file to find number of rows
open my $reader, $pedFile or die "error trying to open ped file for reading: $!";

while(my $line = <$reader>)
{
	if(length ($line) > 6)
    {	   
        $lineID ++;	
    }
}
my $totalSamples=$lineID;
close $reader;

$lineID=0;
#now convert to comma-separated matrix
open my $reader, $pedFile or die "error trying to open ped file for reading: $!";
my $validSnips=0;
while(my $line = <$reader>)
{
	chomp $line;  
    if(length ($line) > 6)
    { 
	    #split content of a space-separated line into an array: @lineArray 
	    my @lineArray = split(' ',$line);	    	
	
        my $classLabel = $lineArray[0];
        my $sampleKey = $lineArray[1];

        my $out_line = $classLabel.','.$sampleKey;
        
        for (my $i=6, my $k=0; $i<$#lineArray ; $i=$i+2, $k++) #see if there is a missing value - at least 1 is zero
	    {            
            my $firstVal = int ($lineArray[$i]);
            my $secondVal = int ($lineArray[$i+1]);
            my $matrixEntry = getMatrixEntry($firstVal,$secondVal);
            if($lineID ==0)
            {
                $validSnips++;
            }
            $out_line = $out_line.','.$matrixEntry;
           
        }
        print WRITER $out_line."\n";
        $lineID++;

        print "Processed sample $lineID \n";	
    }
}

close $reader;

print STDERR "Total valid variants $validSnips and $totalSamples samples. \n";

	
#we consider an alternative allele as 1 or 2 - simplified 0-1 model 1-alt allele is present
sub getMatrixEntry
{
	my ($first, $second) = @_;
	
	if($first == $second)
	{
		if($first == 2) #both 2 
		{
			return 2;
		}
		else #both 1
		{
			return 0;
		}
	}
	return 1;
}


