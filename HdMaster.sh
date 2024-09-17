#!/bin/bash

# Step 1: Install Java
echo "Installing Java..."
sudo apt update
sudo apt install default-jdk default-jre -y
echo "Java installed."
java -version

# Step 2: Create a user for Hadoop and configure SSH
echo "Creating Hadoop user and configuring SSH..."
sudo adduser hadoop --gecos "Hadoop User,,," --disabled-password
echo "hadoop:password" | sudo chpasswd
sudo usermod -aG sudo hadoop
sudo apt install openssh-server openssh-client -y
sudo -u hadoop ssh-keygen -t rsa -N "" -f /home/hadoop/.ssh/id_rsa
sudo -u hadoop cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
sudo chmod 640 /home/hadoop/.ssh/authorized_keys
echo "SSH configuration completed."

# Step 3: Download and install Apache Hadoop
echo "Downloading and installing Hadoop..."
sudo -u hadoop wget https://downloads.apache.org/hadoop/common/stable/hadoop-3.3.4.tar.gz -P /home/hadoop/
sudo -u hadoop tar -xvzf /home/hadoop/hadoop-3.3.4.tar.gz -C /home/hadoop/
sudo mv /home/hadoop/hadoop-3.3.4 /usr/local/hadoop
sudo mkdir /usr/local/hadoop/logs
sudo chown -R hadoop:hadoop /usr/local/hadoop
echo "Hadoop installed."

# Step 4: Configure Hadoop environment variables
echo "Configuring Hadoop environment variables..."
sudo -u hadoop bash -c 'cat <<EOF >> /home/hadoop/.bashrc
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
EOF'
sudo -u hadoop source /home/hadoop/.bashrc
echo "Hadoop environment variables configured."

# Step 5: Configure Java environment variables in Hadoop
echo "Configuring Java environment variables in Hadoop..."
sudo -u hadoop bash -c 'cat <<EOF >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_CLASSPATH+=" $HADOOP_HOME/lib/*.jar"
EOF'
sudo -u hadoop wget https://jcenter.bintray.com/javax/activation/javax.activation-api/1.2.0/javax.activation-api-1.2.0.jar -P /usr/local/hadoop/lib/
echo "Java environment variables configured."

# Step 6: Edit configuration files
echo "Editing configuration files..."

# core-site.xml
sudo -u hadoop bash -c 'cat <<EOF > $HADOOP_HOME/etc/hadoop/core-site.xml
<configuration>
  <property>
    <name>fs.default.name</name>
    <value>hdfs://0.0.0.0:9000</value>
    <description>The default file system URI</description>
  </property>
</configuration>
EOF'

# hdfs-site.xml
sudo -u hadoop mkdir -p /home/hadoop/hdfs/{namenode,datanode}
sudo chown -R hadoop:hadoop /home/hadoop/hdfs
sudo -u hadoop bash -c 'cat <<EOF > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.name.dir</name>
    <value>file:///home/hadoop/hdfs/namenode</value>
  </property>
  <property>
    <name>dfs.data.dir</name>
    <value>file:///home/hadoop/hdfs/datanode</value>
  </property>
</configuration>
EOF'

# mapred-site.xml
sudo -u hadoop bash -c 'cat <<EOF > $HADOOP_HOME/etc/hadoop/mapred-site.xml
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
</configuration>
EOF'

# yarn-site.xml
sudo -u hadoop bash -c 'cat <<EOF > $HADOOP_HOME/etc/hadoop/yarn-site.xml
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
EOF'

echo "Configuration files edited."

# Step 7: Format the HDFS NameNode
echo "Formatting HDFS NameNode..."
sudo -u hadoop hdfs namenode -format
echo "HDFS NameNode formatted."

# Step 8: Start the Hadoop cluster
echo "Starting the Hadoop cluster..."
sudo -u hadoop start-dfs.sh
sudo -u hadoop start-yarn.sh
echo "Hadoop cluster started."

# Step 9: Verify services
echo "Verifying services..."
sudo -u hadoop jps

echo "Installation and configuration of Hadoop completed."
