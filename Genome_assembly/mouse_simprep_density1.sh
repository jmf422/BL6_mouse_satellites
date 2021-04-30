#!/bin/bash -l
#SBATCH --job-name=mouse_simprep_density1
#SBATCH --output=mouse_simprep_density1.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2000
#SBATCH --time=01:00:00
#SBATCH --partition=short
#SBATCH --account=bscb02


#sbatch mouse_simprep_density1.sh 
# this script processes the phobos out file to get a tab-delimited bed file of repeats in arrays >= 100 bp
# the bed file includes the coordinates of the repeat arrays, the repeat consensus of each array, and the average percent identity of each array.


#date
d1=$(date +%s)
echo $HOSTNAME
echo $1


#/programs/bin/labutils/mount_server cbsubscb14 /storage
/programs/bin/labutils/mount_server cbsuclarkfs1 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID


# copy over the phobos file. It needs to be formatted into a bed file.
cp /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/mouse39.phobos .

# split the file so we can format it in a bed format

# remove the comment lines
cat mouse39.phobos | grep -v '^#' > temp.txt
mv temp.txt mouse39.phobos

csplit --digits=4 --quiet --prefix=allphobos mouse39.phobos "/>/" "{*}"
rm allphobos0000


ls | grep allphobos > phobfiles.txt

files=`cat phobfiles.txt`

# for each contig, makes a bed file of where the repeats are
for f in $files
do
# get the contig name
	contig=`cat $f | grep '^>' | cut -f 1 -d " " | cut -f 2 -d ">"`
# now remove the first 3 lines
	sed -e '1,3d' < $f > temp.txt # remove first 3 lines
# get all the starts
	cat temp.txt | cut -f 1 -d "|" | tr -s " " | cut -f 3 -d " " > $f.starts.txt
# get all the ends
	cat temp.txt | cut -f 1 -d "|" | tr -s " " | cut -f 5 -d " " > $f.ends.txt
	# get all the repeat sequences
	cat temp.txt | cut -f 6 -d "|" | tr -s " " | cut -f 3 -d " " > $f.reps.txt 
	# get all the perc identity
	cat temp.txt | cut -f 5 -d "|" | tr -s " " | cut -f 2 -d " " > $f.id.txt
	
# print them together
	times=`wc -l $f.starts.txt | cut -f 1 -d " "`
	for i in `seq $times`
	do
		echo $contig >> $f.contig.txt
	done
	paste $f.contig.txt $f.starts.txt $f.ends.txt $f.reps.txt $f.id.txt > $f.bed
done

rm *.contig.txt
rm *starts.txt
rm *ends.txt
rm *.reps.txt
rm *.id.txt

# combine all these files
cat *.bed > mouse.simpreps.seq.bed # at this stage, remove things that are less than 100 bp
cat mouse.simpreps.seq.bed | awk -v OFS="\t" '{print $1,$2,$3,$4,$5,$3-$2}' | awk -v OFS="\t" '$6>=100 {print $1,$2,$3,$4,$5}' > mouse.simpreps.100filter.seq.id.bed

cp mouse.simpreps.100filter.seq.id.bed /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/validation



cd ..
rm -r ./$SLURM_JOB_ID


#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)