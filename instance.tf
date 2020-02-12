provider "aws" {
  region     = "us-east-1"
  access_key = "xxxxxxxxxxxx"
  secret_key = "xxxxxxxxxxxx"
}

resource "aws_instance" "my-ec2" {
  ami = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "myec2key"

user_data= <<EOF
#!/bin/bash -xe

#Log the userData
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

#Install Java
sudo yum install -y java-1.8.0-openjdk-devel

#Set JAVA_HOME and PATH
export JAVA_HOME=/usr/lib/java/java-1.8.0-openjdk-1.8.0.222.b10-0.amzn.0.1.x86_64/
export PATH=$PATH:/usr/lib/java/java-1.8.0-openjdk-1.8.0.222.b10-0.amzn.0.1.x86_64/bin/

#Install Manen
sudo yum install -y maven

#Install Git
sudo yum install -y git

#create a new directory for installing the softwares
mkdir -p /home/ec2-user/installations
cd /home/ec2-user/installations

#Install and Start Jenkins
sudo yum -y update
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install -y jenkins
sudo service jenkins start


#Set required properties for Elasticsearch
echo 262144 > /proc/sys/vm/max_map_count

echo "@ec2-user      hard nofile 1048576" >> /etc/security/limits.conf
echo "@ec2-user      soft nofile 65536" >> /etc/security/limits.conf

echo "@ec2-user      hard nproc 15215" >> /etc/security/limits.conf
echo "@ec2-user      soft nproc 4096" >> /etc/security/limits.conf

#Download, configure and run elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.2-linux-x86_64.tar.gz
tar -xzf elasticsearch-7.5.2-linux-x86_64.tar.gz
echo "cluster.name: petclinic_cluster" >> /home/ec2-user/installations/elasticsearch-7.5.2/config/elasticsearch.yml
echo "node.name: node-1" >> /home/ec2-user/installations/elasticsearch-7.5.2/config/elasticsearch.yml
echo "network.host: 0.0.0.0" >> /home/ec2-user/installations/elasticsearch-7.5.2/config/elasticsearch.yml
echo "discovery.seed_hosts: ["node-1"]" >> /home/ec2-user/installations/elasticsearch-7.5.2/config/elasticsearch.yml
echo "cluster.initial_master_nodes: ["node-1"]" >> /home/ec2-user/installations/elasticsearch-7.5.2/config/elasticsearch.yml

nohup /home/ec2-user/installations/elasticsearch-7.5.2/bin/elasticsearch &

#Download, configure and run Logstash
wget https://artifacts.elastic.co/downloads/logstash/logstash-7.5.2.tar.gz
tar -xzf logstash-7.5.2.tar.gz

echo "" > /home/ec2-user/installations/logstash-7.5.2/config/logstash-sample.conf
wget ftp://test.myserver.net/logstash-sample.conf
cp logstash-sample.conf /home/ec2-user/installations/logstash-7.5.2/config/

nohup /home/ec2-user/installations/logstash-7.5.2/bin/logstash -f /home/ec2-user/installations/logstash-7.5.2/config/logstash-sample.conf


#Download, configure and run Kibana
curl -O https://artifacts.elastic.co/downloads/kibana/kibana-7.5.2-linux-x86_64.tar.gz
tar -xzf kibana-7.5.2-linux-x86_64.tar.gz

echo "server.name: "myserver"" >> /home/ec2-user/installations/kibana-7.5.2-linux-x86_64/config/kibana.yml
echo "elasticsearch.hosts: ["http://0.0.0.0:9200"]" >> /home/ec2-user/installations/kibana-7.5.2-linux-x86_64/config/kibana.yml

nohup ./home/ec2-user/installations/kibana-7.5.2-linux-x86_64/bin/kibana &

rm -f /home/ec2-user/installations/elasticsearch-7.5.2-linux-x86_64.tar.gz
rm -f /home/ec2-user/installations/logstash-7.5.2.tar.gz
rm -f /home/ec2-user/installations/kibana-7.5.2-linux-x86_64.tar.gz
EOF
}
