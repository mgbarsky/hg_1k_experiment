#! /usr/bin/perl
# Here we are going to extract quality snips only from HG VCF files: for example (ALL.chr10.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf)
# We will read each line of the input table:
#delimiter is \t
#first we need to skip comments lines that start from ##
#second we need to extract sample labels from line starting with # - starting from column 9

#we will leave the following in each non-commented line
#CHROM POS REF ALT and starting from column 9 - 0/0, 0/1 etc
#we leave only rows where AF mle in column INFO - (set of ;-separated key-value pairs) - is greater than the threshold parameter
 #col 0: chromosome, col 1: position in chromosome, col3 - base in ref genome, col4 - alternate base, col6-filter(PASS), col7-info, [col9 -end] - nucleotide bases, 0/1

use strict;
use Getopt::Long;

my $vcfFile = "";
my $thresholdPercents = "";
my $outputFolder="";

GetOptions("vcf=s" => \$vcfFile,
		"t=s" => \$thresholdPercents,"outputdir=s" => \$outputFolder);

#collect program arguments
if($vcfFile eq "" )
{
    print "Error: a vcf file  must be provided: --vcf FILE NAME \n";   
    exit 1;
}

my $threshold=0;
if($thresholdPercents ne "")
{
    $threshold=$thresholdPercents/100.00;
}

#our $maxDebugLines = 15;
#our $printedLines = 0;


#open output file for writing - filtered vcf
open WRITER, '>', $outputFolder.'/'.$vcfFile."_QUALITY_SNIPS.csv" or die "error trying to open output file: $!";
open LABELWRITER, '>', $outputFolder.'/'.$vcfFile."_SAMPLE_KEYS.csv" or die "error trying to open output file: $!";

#determine which line contains the header and the next one starts the data rows
my $lineCounter=0;
my $found=0;

open my $reader, $vcfFile or die "error trying to open input file for reading: $!";
while ((my $line = <$reader>) and !$found)
{
    my $first2 =  substr $line, 0, 2;
    if($first2 ne "##")
    {
        $found=1;
    }
    else
    {
        $lineCounter++;
    }
}
close($reader);

my $headerLine=$lineCounter;
print "Data header is on line $headerLine \n";


my @sampleKeys;
my $totalSamples;
my $validSnips=0;

open my $reader, $vcfFile or die "error trying to open input file for reading: $!";

$lineCounter=0;
while (my $line = <$reader>)
{
   	chomp $line;	
    if($lineCounter == $headerLine)
    {
        #read labels from a header line
        my @headers = split ("\t", $line);
        for(my $i=9; $i<=$#headers; $i++)
        {
            push (@sampleKeys, $headers[$i]);	
        }
        $totalSamples=$#sampleKeys+1;
        print "Total samples =$totalSamples \n";       
    }   

   
    if($lineCounter > $headerLine)
    {
        #split data row
        my @columns = split ("\t", $line);
        
        my $validRow=1;

        #1. see that AFmle in col 7 is >= threshold
        my $info = $columns[7];
        my @infoArray = split(';',$info);

        my $freq =0;
        my $variantType="";
        for(my $k=0; $k<= $#infoArray; $k++)
        {
            my @pair = split('=',$infoArray[$k]);
            if(uc $pair[0] eq 'AF')
            {
                $freq=$pair[1];
            } 
            if(uc $pair[0] eq 'VT')
            {
                $variantType=uc $pair[1];
            } 
        }
        
        if($variantType ne 'SNP')
        {
            $validRow=0;
        }
        if($freq < $threshold or $freq>1.0 -$threshold  )
        {
            $validRow=0;
        }

        #2. see if ALT column (col4) has length 1 - interested only in biallelic snips - and is valid letter, as well valid letter for col3 -REF
        if($validRow and (length($columns[3])>1 or length($columns[4])>1 or !validBases($columns[3],$columns[4]) ))
        {
            $validRow=0;
        }
        #3. see if quality column (col5) ==100
        if($validRow and $columns[5] <98)
        {
            $validRow=0;
        }
        
        if($validRow) #we are going to add a new line in the output file
        {
            #output col 0: chromosome, col 1: position in chromosome, col3 - base in ref genome, col4 - alternate base,
            my $out_line = $columns[0].','.$columns[1].','.$columns[3].','.$columns[4].','.$freq;
            for(my $i=9; $i<=$#columns; $i++)
            {
               $out_line=$out_line.','.$columns[$i];	
            }
            #write to output
            
            print WRITER $out_line."\n";
            $validSnips++;
        }
    }    
	
    $lineCounter++;	
}

print "Total $validSnips variants with frequency >= $threshold \n";

#print labels to a separate file
for(my $i=0; $i<=$#sampleKeys; $i++)
{
   # print $sampleKeys[$i]."\n";
    print LABELWRITER $sampleKeys[$i]."\n";	
}

sub validBases
{
	my ($ref,$alt ) = @_;
	
	if(($ref eq 'A' or $ref eq 'C' or $ref eq 'G' or $ref eq 'T') and ($alt eq 'A' or $alt eq 'C' or $alt eq 'G' or $alt eq 'T')) 
	{
		return 1;
	}
	else
	{
		return 0;
	}
}







