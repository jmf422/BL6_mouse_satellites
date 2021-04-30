#!/bin/bash -l
#SBATCH --job-name=mouse_simprep_density2
#SBATCH --output=mouse_simprep_density2.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2000
#SBATCH --time=04:00:00
#SBATCH --partition=short
#SBATCH --account=bscb02


#sbatch mouse_simprep_density2.sh 
## this file filters the previously-made file to contain only the legit kmers (have a copy number of 10 in at least one line)
# then it calculates the repeat density in 1 Mb windows across the chromosome-level contigs.


#date
d1=$(date +%s)
echo $HOSTNAME
echo $1


#/programs/bin/labutils/mount_server cbsubscb14 /storage
/programs/bin/labutils/mount_server cbsuclarkfs1 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID


# copy over the phobos bed file we made last time

cp /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/validation/mouse.simpreps.100filter.seq.id.bed .
# bring in the filtered file including the sequences

# bring in the file with the list of legit kmer names.
cp /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/legit_kmer_names.txt .

# get only the 434 kmers and see their density 
# can't grep like this. need grep -w.

grep -w -f legit_kmer_names.txt mouse.simpreps.100filter.seq.id.bed > mouse.simpreps.100filter.seq.id.legit.bed

cp mouse.simpreps.100filter.seq.id.legit.bed /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/validation

# only include coordinates:

cat mouse.simpreps.100filter.seq.id.legit.bed | cut -f 1,2,3 > mouse.simpreps.100filter.seq.id.legit.coords.bed


# bring the bed file to intersect with

cp /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/mouse39.1Mb.bed .

# intersect the files
bedtools intersect -a mouse39.1Mb.bed -b mouse.simpreps.100filter.seq.id.legit.coords.bed -wao > mouse.intersected.bed
cat mouse.intersected.bed | awk '$5!=-1 {print $0}' > temp.bed
mv temp.bed mouse.simpreps.intersected.bed


# now process the intersected file: split it up by each contig and then add column 7
cat mouse.simpreps.intersected.bed | awk -F'\t' 'NR==1{A=$1; B=$2} {if (($1!=A) || ($1==A && $2!=B)) { print NR; A=$1; B=$2}}' > line.numbers
splitter=`cat line.numbers` 
# split the file and do for each read
csplit --digits=6 --quiet --prefix=windowsplit mouse.simpreps.intersected.bed $splitter 


for f in windowsplit*
do
	contig=`cat $f | awk 'NR==1{print $1}'` # get the contig name
	start=`cat $f | awk 'NR==1{print $2}'` # get the start position
	fin=`cat $f | awk 'NR==1{print $3}'` # get the end position
	totspan=`cat $f | cut -f 7 | awk '{total = total + $1}END{print total}'` # total bp of repeats
	
	printf "%s\t%i\t%i\t%i\n" $contig $start $fin $totspan > $f.bed.summary
done

cat *.bed.summary > mouse39.simpreps.density.bed
cat mouse39.simpreps.density.bed | awk -v OFS="\t" '{print $0, $3-$2}' | awk -v OFS="\t" '{print $0, $4/$5}' > temp.txt
mv temp.txt mouse39.simpreps.legit.100filter.density.bed


cp mouse39.simpreps.legit.100filter.density.bed /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/validation

cp /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/chr_contigs.txt .
cp /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/mouse39_contig_Chr.txt .
# now convert to chromosome coordinates
grep -f chr_contigs.txt mouse39.simpreps.legit.100filter.density.bed > mouse39.simpreps.density.100filter.legit.chronly.bed

join mouse39.simpreps.density.100filter.legit.chronly.bed mouse39_contig_Chr.txt | sed 's| |\t|g' | awk -v OFS="\t" '{print $7,$2,$3,$4,$5,$6}' > mouse39.simpreps.density.100filter.legit.chronly.toplot.bed

cp mouse39.simpreps.density.100filter.legit.chronly.toplot.bed /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/validation



cd ..
rm -r ./$SLURM_JOB_ID


#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)