#!/bin/bash -l
#SBATCH --job-name=summarize_Ymin_mouse
#SBATCH --output=summarize_Ymin_mouse.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2000
#SBATCH --time=00:15:00
#SBATCH --partition=short
#SBATCH --account=bscb02


# for p in `cat mouse.fileroots`; do summarize_Ymin_mouse.sh $p; done

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1


#/programs/bin/labutils/mount_server cbsufsrv5 /data1
#/programs/bin/labutils/mount_server cbsubscb14 /storage
/programs/bin/labutils/mount_server cbsuclarkfs1 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID

cp /fs/cbsuclarkfs1/storage/jmf422/mouse_Ymin/$1_1_Ymin.trimmed.sam .


cat $1_1_Ymin.trimmed.sam | grep -v '^@' | wc -l > $1.Ymin.reads.mapped


mv $1.Ymin.reads.mapped /fs/cbsuclarkfs1/storage/jmf422/mouse_Ymin


rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)

 