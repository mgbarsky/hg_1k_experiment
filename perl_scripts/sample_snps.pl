#! /usr/bin/perl
# Here we are going to sample N rows from the VCF file
# We will read each $skip line of the original file and we will leave only 0/1, 0/0 or 1/1 for each sample

use strict;
use Getopt::Long;

my $snipTableFile = "";

my $skip = "";
GetOptions("snips=s" => \$snipTableFile,
		"skip=s" => \$skip);

#collect program arguments
if($snipTableFile eq "" or  $skip eq "")
{
    print "Error: a table of snips file and the skip parameter are required: --snips FILE NAME --skip NUMBER OF LINES\n";   
    exit 1;
}

#open output file for writing - ped encoding
open WRITER, '>', $snipTableFile."_sample.csv" or die "error trying to open output file: $!";

print "Extracting sample rows from file $snipTableFile skipping $skip rows. \n";

#open input file for reading
open my $reader, $snipTableFile or die "error trying to open file for reading HQ snips: $!";

#sample line in snips table
#0-chr, 1-position, 2-ref char, 3-alt char, 4-percentage of variance, from 5 -for each sample in sampleKeys - 0-ref char, 1-alt char 
#10,66326,A,G,0.05,0|0:0.000:-0.00,-2.37,-5.00,0|0:0.000:-0.05,-1.01 	


my $lineID =0;
my $totalSNPs = 0;
my $totalSamples =0;

while (<$reader>){
    $lineID = $.;
    next if ($lineID % $skip >0);
    
    chomp;
    my @lineArray = split ',';
    # process line
    $totalSNPs++;
    #each line looks like this
        #10,60969,C,A,0.07,0|1:1.150:-2.47,-0.43,-0.21,0|0:0.000:-0.14,-0.55,-3.27,0|0:0.150:-0.48,-0.48,-0.48,
        
    if($totalSNPs == 1)
    {
        $totalSamples=($#lineArray-5+1)/3;
    }
    for (my $i=5, my $sampleID=0; $i<=$#lineArray ; $i+=3,$sampleID++)
    {
	    my @valueArray = split(':',$lineArray[$i]);
        my $snp = $valueArray[0];
        my $simpleEncodingForSample;
        if(length ($snp) != 3) #invalid entry not of form 0/0, 0/1 or 1/1 - missing value
        {
            print "Encoding which is not expected : ".$snp."\n";
            #print default encoding
            $simpleEncodingForSample = "0/0"; #reference allele 
        }
        else
        {
            #we need to get chars at positions 0 and 2 of this entry
	        my $c1 = substr( $snp, 0 , 1 );
	        my $c2 = substr( $snp, 2 , 1 );

	        my $allele1 = int ($c1);

            if($allele1 >1)
	        {
                print "Allele which is not expected : ".$snp."\n";
		        $allele1 = "0"; #not alternative allele we are looking for
	        }
	        my $allele2 = int ($c2);

            if($allele2 >1)
	        {
                print "Allele which is not expected : ".$snp."\n";
		        $allele1 = "0"; #not alternative allele we are looking for
	        }
	        $simpleEncodingForSample = $allele1.'/'.$allele2;
        }
        if($i == 5) #first simplified snp
        {
            print WRITER $simpleEncodingForSample;  
        }
        else
        {
            print WRITER ','.$simpleEncodingForSample; 
        }     
    }
    print WRITER "\n";
    print "Line $. complete \n";

}



print STDERR "Total variants collected: $totalSNPs and $totalSamples samples. \n";




