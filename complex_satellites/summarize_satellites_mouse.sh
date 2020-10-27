#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N summarize_satellites_mouse
#$ -cwd
#$ -l h_vmem=12G


# for p in `cat mouse.fileroots`; do qsub summarize_satellites_mouse.sh $p; done

#date
d1=$(date +%s)

echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsubscb14 /storage



mkdir -p /workdir/$USER/$JOB_ID
cd /workdir/$USER/$JOB_ID

# cp in the sam file

cp /fs/cbsubscb14/storage/jmf422/mouse/redo_satellite_mapping/$1_1.trimmed.sam .

# for each satellite, count how many reads mapped:

major_sat=`cat $1_1.trimmed.sam | grep -v "^@SQ" |  grep "Mouse_major_satellite" | cut -f 1 | sort -u | wc -l`
minor_sat=`cat $1_1.trimmed.sam | grep -v "^@SQ" |  grep "Mouse_minor_satellite" | cut -f 1 | sort -u | wc -l`

 
printf "%s\t%s\t%f\t%s\t%f\n" $1 "major" $major_sat "minor" $minor_sat  > $1.sat.mapping 

cp *sat.mapping /fs/cbsubscb14/storage/jmf422/mouse/redo_satellite_mapping

cd ..
rm -r ./$JOB_ID
#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)