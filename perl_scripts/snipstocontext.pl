#! /usr/bin/perl
# Collect variants parsed from a VCF file and a context from a given reference genome
# Assumes that the positions in a vcf file are sorted for each chromosome
use strict;
use Getopt::Long;
use Bio::Perl;

my $vcfFile = "";
my $refFile = "";

my $contextLength = 0;
my $jumps = 0;

my $outputFolder="";

GetOptions("vcf=s" => \$vcfFile,
           "ref=s" => \$refFile,
	   "context=s" => \$contextLength,
	    "jump=s" => \$jumps, "outputdir=s" => \$outputFolder );

#collect program arguments
if($vcfFile eq "" || $refFile eq "")
{
    print "Error: a vcf file and reference file must be provided\n";
    usage();
    exit 1;
}


if($contextLength eq "" || $contextLength == 0)
{
	$contextLength=201; #default - 100 characters from each side
}

if($jumps eq "" || $jumps == 0)
{
	$jumps=300; #default - based on contextLength - we take only each $jumps-th position of the snip
}

if($jumps <= $contextLength){$jumps = $contextLength+10};



#open input file for reading
open(VCF, $vcfFile) || die("Cannot read '$vcfFile'");

my $flank = int ($contextLength/2);
print 'Processing file '.$vcfFile.' for context of length '.$contextLength.' around polymorphic sites. Jumping '.$jumps. ' positions'."\n";
print 'Flanking '.$flank. ' positions'."\n";

#open reference file
my $refFileHandler = Bio::SeqIO->new(-file => $refFile, '-format' => 'Fasta');

my $fasta_seq;   #variable of type fasta sequence - from bio-perl
my $ref_seq; #string of actual sequence

#open output file for writing context lines
open my $seqWriter, '>', $outputFolder.'/'."$vcfFile"."_SNP_CONTEXT_LINES.txt" or die "error trying to open output file: $!";


my $totalVariants = 0;
my $prevPosition = 0;

my $lineID=0;
while(my $line = <VCF>)
{
    chomp;   
 	#split content of a comma-separated line into an array: @lineArray 
    #20,15001880,A,G,0.349962,0/1,0/1,0/1,0/0,0/1,0/1,.,0/1,0/0,0/1
	my @lineArray = split(',',$line);	 
	my $chromosome = int $lineArray [0];
	
	
    #find a sequence for current chromosome
    if($lineID == 0)
    {
        my $chromosomeFound =0;
        while(my $sequence = $refFileHandler->next_seq() and !$chromosomeFound)
        {
            if($sequence->display_id == $chromosome)
            {
                $ref_seq = $sequence->seq; #string of actual sequence
                my $seqLength=length ($ref_seq);
                print "Reference sequence has length $seqLength \n";
                $chromosomeFound=1;
            }
        }

        if(!$chromosomeFound)
        {
            print "Chromosome $chromosome not found in fasta file $refFile \n";
            exit 1;
        }
    }

    
	my $currPosition = $lineArray [1];
    #print "currPosition=$currPosition prevPosition=$prevPosition\n";
	my $refchar = $lineArray [2];
	my $altchar = $lineArray [3];

	my $valid = 1;

	
	if($valid and ($currPosition - $prevPosition) <= $jumps  )
	{
		$valid =0;
	}

	
	if($valid)
	{
		my $base_pos = $currPosition - 1; #this is a ref base position in reference genome	
		my $rchar = uc substr($ref_seq, $base_pos, 1); #this is char extracted from this position
	
		#character in reference has to match ref char from vcf file
		if($rchar ne $refchar)
		{
			print STDERR "Warning: ref string ".$rchar." does not match expected: " . $refchar . " at position $currPosition \n";		
			print STDERR "6-base context: " . substr($ref_seq, $base_pos-3, 6) . "\n";
			#exit(1);
			$valid=0;
		}
		else
		{			
			#add a line with a reference char and surrounded by $flank bases extracted from the reference genome
			my $context = uc substr($ref_seq, $base_pos - $flank, 2*$flank+1);  #to be sure that we are replacing the right nucleotide
            #print "$context of length ".length ($context)."\n";
			if(length ($context) >= $contextLength) #we managed to extract context with the required length
			{					
				my $out_seq = $context.','.$flank.','.$refchar.','.$flank.','.$altchar."\n";
			
				print $seqWriter $out_seq;
				$totalVariants++;
			}	
			$prevPosition = $currPosition;		
		}
	}
	

    $lineID++;	    	 
}


print STDERR "Total variants collected from $lineID lines of the VCF file: $totalVariants\n";

sub usage
{
    print "snipstocontext.pl - generate a new sequence by applying variants to a reference\n";
    print "Usage: snipstocontext_updated.pl --vcf VCFFILE --ref REFFOLDER [--context CONTEXTLENGTH] [--jump MINLENGTHBETWEENSNPS] [--numlines NUMBER]\n";
    print "\n";
    print "Options:\n";
    print "               --vcf=FILE read variants from FILE\n";
    print "               --ref=file containing reference genome \n";
}


