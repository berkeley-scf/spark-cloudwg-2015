# pledge
# ssh paciorek@hpc.brc.berkeley.edu
# see ~/staff/projects/spark-savio/run.sh

srun -A ac_scsguest -p savio  -N 4 -t 30:0 --pty bash

module load java spark
source /global/home/groups/allhands/bin/spark_helper.sh

spark-start

pyspark --master $SPARK_URL --executor-memory 32G

### IMPORTANT: run spark-stop at end 

# now in Python...
# lines = sc.textFile('/global/scratch/paciorek/airline/')
# ...
# lines.saveAsTextFile('/global/scratch/paciorek/airline_result')

spark-stop
