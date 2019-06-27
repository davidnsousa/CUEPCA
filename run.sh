cd ..
experiments='E1 E2 E3 E4 E5 E6RR1 E6RR2 E6RR3'
echo start $(date '+%d/%m/%Y %H:%M:%S') >> CUEPCA/log
for exp in $experiments
do
bash netlogo-headless.sh \
--model CUEPCA/CUEPCA.nlogo \
--experiment $exp \
--table CUEPCA/$exp.csv
echo $exp $(date '+%d/%m/%Y %H:%M:%S') >> CUEPCA/log
done
