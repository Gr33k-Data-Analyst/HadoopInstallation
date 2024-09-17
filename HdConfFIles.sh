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
  <property>
        <name>yarn.app.mapreduce.am.resource.mb</name>
        <value>512</value>
  </property>
  
  <property>
          <name>mapreduce.map.memory.mb</name>
          <value>256</value>
  </property>
  
  <property>
          <name>mapreduce.reduce.memory.mb</name>
          <value>256</value>
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
  <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>1536</value>
  </property>

  <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>1536</value>
  </property>

  <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>128</value>
  </property>

  <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
  </property>
</configuration>
EOF'

echo "Configuration files edited."
