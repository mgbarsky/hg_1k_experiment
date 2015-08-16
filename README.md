# hg_1k_experiment

This is a supplementary code for the k-mer counting experiment on a very large input: 
232 sets of raw DNA reads from 1000 genomes project of total size of about 15TB. 
Counting of k-mers is performed using <a href="https://github.com/mgbarsky/streamcount">streamcount</a>. 

The resulting counts of a pre-selected set of k-mers are used for the alignment-free 
inference of human population structure. 
The experiment consists of three parts:
<ol>
<li>Control: population structure using original alignment-based methods. 
Detailed protocol for this part is in file 
<a href="https://github.com/mgbarsky/hg_1k_experiment/blob/master/ORIGINAL_SNPS_EXPERIMENT.md">ORIGINAL_SNPS_EXPERIMENT.md</a></li>
<li>Substring-based method: 
population structure using differences in k-mer counts. 
Detailed protocol for this part is in file 
<a href="https://github.com/mgbarsky/hg_1k_experiment/blob/master/KMER_COUNTING_EXPERIMENT.md">KMER_COUNTING_EXPERIMENT.md</a></li>
<li>Browser-based tool for visualizing human population structure, available at <a href="http://projects.oicr.on.ca/visualizing-human-populations/>OICR web site</a>.
The description of data experiment for this part is in file
<a href="https://github.com/mgbarsky/hg_1k_experiment/blob/master/WEB_VISUALIZATION_EXPERIMENT.md">WEB_VISUALIZATION_EXPERIMENT.md</a></li> 
</li>
</ol>
