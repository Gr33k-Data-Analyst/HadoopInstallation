echo "Configuring Java environment variables in Hadoop..."
sudo -u hadoop bash -c 'cat <<EOF >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_CLASSPATH+=" $HADOOP_HOME/lib/*.jar"
EOF'
sudo -u hadoop wget https://jcenter.bintray.com/javax/activation/javax.activation-api/1.2.0/javax.activation-api-1.2.0.jar -P /usr/local/hadoop/lib/
echo "Java environment variables configured."
