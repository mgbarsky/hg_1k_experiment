# hg_1k_experiment

This is a supplementary code for the k-mer counting experiment on a very large input: 232 sets of raw DNA reads from 1000 genomes project. Counting of k-mers is performed using <a href="https://github.com/mgbarsky/streamcount">streamcount</a>. 

The resulting counts of a pre-selected set of k-mers are used for alignment-free inference of human population structure. 
The experiment consists of two parts:
<ol>
<li>Control: population structure using original alignment-based methods. Detailed protocol for this part is in file <a href=""></a></li>
<li>Substring-based method: population structure using differences in k-mer counts. Detailed protocol for this part is in file <a href=""></a></li>
</ol>
