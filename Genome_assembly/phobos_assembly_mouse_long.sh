#!/bin/bash -l
#SBATCH --job-name=phobos_assembly_mouse_long
#SBATCH --output=phobos_assembly_mouse_long.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=80000
#SBATCH --time=7-00:00:00
#SBATCH --partition=long7,long30
#SBATCH --account=bscb02


#sbatch phobos_assembly_mouse_long.sh

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1


#/programs/bin/labutils/mount_server cbsubscb14 /storage
/programs/bin/labutils/mount_server cbsuclarkfs1 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID


cp /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats/mouse39.fa.gz .

gunzip mouse39.fa.gz

# now, run the program.

$HOME/Programs/bin/phobos_64_libstdc++6 mouse39.fa mouse39.phobos -U 20 --outputFormat 0 --printRepeatSeqMode 0 --reportUnit 2


mv mouse39.phobos /fs/cbsuclarkfs1/storage/jmf422/mouse_assembly_microsats


cd ..

rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)