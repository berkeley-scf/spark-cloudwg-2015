### WARNING: this first bit of code is bash code that is set up to run on BCE

export SPARK_VERSION=1.5.1
export CLUSTER_SIZE=12  # number of slave nodes
export mycluster=sparkvm-paciorek # need unique name relative to other users

# get Spark tarbal from http://spark.apache.org/downloads.html:
cd /tmp
wget http://www.apache.org/dyn/closer.lua/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}.tgz
# I unzipped the Spark tarball to /usr/lib/spark via sudo on BCE
cd /usr/lib
sudo mv /tmp/spark-${SPARK_VERSION}.tgz .; tar -xvzf /tmp/spark-${SPARK_VERSION}.tgz
cd /usr/lib/spark/ec2

# set Amazon secret keys (manually or in my case by querying them elsewhere)
#AWS_ACCESS_KEY_ID=blah
AWS_ACCESS_KEY_ID=$(grep -i "^AWS_ACCESS_KEY_ID" ~/stat243-fall-2015-credentials.boto | cut -d' ' -f3)
#AWS_SECRET_ACCESS_KEY=blahhhh
AWS_SECRET_ACCESS_KEY=$(grep -i "^AWS_SECRET_ACCESS_KEY" ~/stat243-fall-2015-credentials.boto | cut -d' ' -f3)

### DO NOT HARD CODE YOUR AMAZON SECRET KEY INFORMATION INTO ANY PUBLIC FILE, INCLUDING A GITHUB REPO !!!!! ###

# start cluster
./spark-ec2 -k chris_paciorek@yahoo.com:stat243-fall-2015 -i ~/.ssh/stat243-fall-2015-ssh_key.pem  \
 --region=us-west-2 -s ${CLUSTER_SIZE} -v ${SPARK_VERSION} launch ${mycluster}

# login to cluster
# as root
./spark-ec2 -k chris_paciorek@yahoo.com:stat243-fall-2015 -i ~/.ssh/stat243-fall-2015-ssh_key.pem --region=us-west-2 login ${mycluster}
# or you can ssh in directly if you know the URL
# ssh -i ~/.ssh/stat243-fall-2015-ssh_key.pem root@ec2-54-71-204-234.us-west-2.compute.amazonaws.com


# you can check your nodes via the EC2 management console

# to logon to one of the slaves, look at /root/ephemeral-hdfs/conf/slaves
# and ssh to that address
# ssh `head -n 1 /root/ephemeral-hdfs/conf/slaves`

# We can view system status through a web browser interface

# on master node of the EC2 cluster, do:
MASTER_IP=`cat /root/ephemeral-hdfs/conf/masters`
echo ${MASTER_IP}
# Point a browser on your own machine to the result of the next command
# you'll see info about the "Spark Master", i.e., the cluster overall
echo "http://${MASTER_IP}:8080/"
# Point a browser on your own machine to the result of the next command
# you'll see info about the "Spark Stages", i.e., the status of Spark tasks
echo "http://${MASTER_IP}:4040/"
# Point a browser on your own machine to the result of the next command
# you'll see info about the HDFS"
echo "http://${MASTER_IP}:50070/"

# when you are done and want to shutdown the cluster:
#  IMPORTANT to avoid extra charges!!!
./spark-ec2 --region=us-west-2 --delete-groups destroy ${mycluster}

## @knitr spark-hdfs


export PATH=$PATH:/root/ephemeral-hdfs/bin/

hadoop fs -mkdir /data
hadoop fs -mkdir /data/airline

df -h
mkdir /mnt/airline
cd /mnt/airline

wget http://www.stat.berkeley.edu/share/paciorek/1987-2008.csvs.tgz
tar -xvzf 1987-2008.csvs.tgz
# or individual files, e.g., data for 1987
# wget http://www.stat.berkeley.edu/share/paciorek/1987.csv.bz2

hadoop fs -copyFromLocal /mnt/airline/*bz2 /data/airline

# check files on the HDFS, e.g.:
hadoop fs -ls /data/airline

# get numpy installed
# there is a glitch in the EC2 setup that Spark provides -- numpy is not installed on the version of Python that Spark uses (Python 2.7). To install numpy on both the master and worker nodes, do the following as root on the master node.
yum install -y python27-pip python27-devel
pip-2.7 install 'numpy==1.9.2'  # 1.10.1 has an issue with a warning in median()
/root/spark-ec2/copy-dir /usr/local/lib64/python2.7/site-packages/numpy

# pyspark is in /root/spark/bin
export PATH=${PATH}:/root/spark/bin

screen -x -RR

# start Spark's Python interface as interactive session
pyspark

