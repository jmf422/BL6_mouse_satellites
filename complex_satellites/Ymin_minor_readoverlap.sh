#!/bin/bash -l
#SBATCH --job-name=Ymin_minor_readoverlap
#SBATCH --output=Ymin_minor_readoverlap.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=500
#SBATCH --time=04:00:00
#SBATCH --partition=short
#SBATCH --account=bscb02


# for p in `cat mouse.fileroots`; do sbatch Ymin_minor_readoverlap.sh $p; done

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsubscb14 /storage
/programs/bin/labutils/mount_server cbsuclarkfs1 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID

cp /fs/cbsuclarkfs1/storage/jmf422/mouse_Ymin/$1_1_Ymin.trimmed.sam .


cat $1_1_Ymin.trimmed.sam | grep -v '^@' | cut -f 1 | sort -u > $1.Ymin.reads.mapped

# copy in the reads that mapped to the minor satellite.

cp /fs/cbsubscb14/storage/jmf422/mouse/redo_satellite_mapping/$1_1.trimmed.bam .


# convert to sam
samtools view $1_1.trimmed.bam | grep "Mouse_minor_satellite" | cut -f 1 | sort -u > $1.minor.reads.mapped

head $1.minor.reads.mapped
head $1.Ymin.reads.mapped


#cat $1_1.trimmed.sam | grep -v "^@" |  grep "Mouse_minor_satellite" | cut -f 1 | sort -u > $1.minor.reads.mapped

comm -12 $1.Ymin.reads.mapped $1.minor.reads.mapped > $1.Ymin.minor.reads.mapped

mv $1.Ymin.minor.reads.mapped /fs/cbsuclarkfs1/storage/jmf422/mouse_Ymin/

cd ..
rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)