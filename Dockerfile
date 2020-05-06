FROM openjdk:8-jdk-slim-buster

#Dependencies
RUN apt-get update -y && apt-get install -y python3 curl git zip vim
RUN cp /usr/bin/python3 /usr/bin/python
#Maven install
ADD https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz  /opt/apache-maven-3.6.0-bin.tar.gz
RUN tar -xvf /opt/apache-maven-3.6.0-bin.tar.gz -C /opt

#Spark install
ADD https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz  /opt/spark-2.4.3-bin-hadoop2.8.tgz
RUN tar -xvf /opt/spark-2.4.3-bin-hadoop2.8.tgz -C /opt

#AWS glue scripts
WORKDIR /opt
RUN git clone -b glue-1.0 --single-branch https://github.com/akoltsov-spoton/aws-glue-libs.git

# #Env setup
ENV M2_HOME=/opt/apache-maven-3.6.0
ENV SPARK_HOME=/opt/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8
ENV PATH="${PATH}:${M2_HOME}/bin"

#Run gluepysparksubmit once to download dependent jars
# RUN echo "print('Get Dependencies')" > /tmp/maven.py
# RUN bash -l -c /opt/aws-glue-libs/bin/gluesparksubmit /tmp/maven.py

# Wacky workaround to get past issue with p4j error (credit @svajiraya - https://github.com/awslabs/aws-glue-libs/issues/25)
RUN rm -rf /opt/aws-glue-lib/jars/netty*
RUN sed -i /^mvn/s/^/#/ /opt/aws-glue-libs/bin/glue-setup.sh

# Env VAR setup
# RUN echo 'export JAVA_HOME=$(ls -d /usr/lib/jvm/*openjdk*) >> ~/.bash_profile' && sed -i -e "/enableHiveSupport()/d" $SPARK_HOME/python/pyspark/shell.py
WORKDIR /opt/aws-glue-libs/
CMD ["bash", "-l", "-c", "./bin/gluepyspark"]
#Entrypoint for submitting scripts
# ENTRYPOINT ["/opt/aws-glue-libs/bin/gluesparksubmit"]
# CMD []
