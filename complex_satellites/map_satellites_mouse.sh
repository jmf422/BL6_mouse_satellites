#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N map_satellites_mouse
#$ -cwd
#$ -l h_vmem=12G


# for p in `cat mouse.fileroots`; do map_satellites_mouse $p; done

#date
d1=$(date +%s)

echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsubscb14 /storage
/programs/bin/labutils/mount_server cbsufsrv5 /data1



mkdir -p /workdir/$USER/$JOB_ID
cd /workdir/$USER/$JOB_ID

# cp in the satellites file.
cp $HOME/Heterochromatin_scripts/mouse_satellites.final.fasta .

# copy over the reads

cp /fs/cbsufsrv5/data1/mouse_MA/30x/trimmed_data/$1_1.trimmed.fq.gz .

gunzip *trimmed.fq.gz


#index the genome <input fasta file> <prefix for index>
/programs/bowtie2-2.2.8/bowtie2-build mouse_satellites.final.fasta mouse_satellites


#map to the genome
/programs/bowtie2-2.2.8/bowtie2 -x mouse_satellites -U $1_1.trimmed.fq -S $1_1.trimmed.sam

echo "mapped to genome: got sam file"

mv *sam /fs/cbsubscb14/storage/jmf422/mouse/redo_satellite_mapping


cd ..
rm -r ./$JOB_ID
#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)