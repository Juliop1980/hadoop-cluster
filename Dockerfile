FROM ubuntu:14.04

WORKDIR /root

# instalar openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-7-jdk wget

# instalar hadoop 3.2.0
RUN wget https://github.com/Juliop1980/compilar-hadoop/releases/download/v1.0/hadoop-2.7.2.tar.gz && \
    tar -xzvf hadoop-2.7.2.tar.gz && \
    mv hadoop-2.7.2 /usr/local/hadoop && \
    rm hadoop-2.7.2.tar.gz && \
    wget https://www-us.apache.org/dist/pig/pig-0.17.0/pig-0.17.0.tar.gz && \
    wget https://www-us.apache.org/dist/pig/pig-0.17.0/pig-0.17.0-src.tar.gz && \
    tar -xzvf pig-0.17.0.tar.gz && \
    tar -xzvf pig-0.17.0-src.tar.gz && \
    mv pig-0.17.0 /usr/local/pig && \
    mv pig-0.17.0-src /usr/local/pig && \
    rm pig-0.17.0.tar.gz && \
    rm pig-0.17.0-src.tar.gz

# configurar variable de ambiente de java
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/pig/bin
ENV PIG_HOME=/usr/local/pig
ENV PIG_CLASSPATH = $HADOOP_HOME/conf

# configurar ssh sin key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# formatear nodo maestro
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]