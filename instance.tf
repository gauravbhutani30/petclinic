resource "aws_instance" "petclinicapp" {
  ami           = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.WebApp.id}"]
  key_name = "${var.key_name}"
  tags {
        Name = "My Petclinic App"
  }
  user_data= <<EOF
#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

#Install Jdk 
sudo yum install -y java-1.8.0-openjdk-devel

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.amzn2.0.1.x86_64/
export PATH=$PATH:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.amzn2.0.1.x86_64/bin/

mkdir -p /home/ec2-user/installations

cd /home/ec2-user/installations

#Downlaod and configure elasticsearch 
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.2-linux-x86_64.tar.gz

tar -xzf elasticsearch-7.5.2-linux-x86_64.tar.gz

 
#Downlaod and configure kibana
curl -O https://artifacts.elastic.co/downloads/kibana/kibana-7.5.2-linux-x86_64.tar.gz

tar -xzf kibana-7.5.2-linux-x86_64.tar.gz

 
#Install Jenkins
sudo yum -y update
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install -y jenkins

#Run Jenkins
sudo service jenkins start

#Install Manen
sudo yum install -y maven

#Install Git
sudo yum install -y git
EOF
}
resource "aws_instance" "database" {
  ami           = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id = "${aws_subnet.PrivateAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.MySQLDB.id}"]
  key_name = "${var.key_name}"
  tags {
        Name = "sql database for petclinic"
  }
  user_data = <<EOF
  #!/bin/bash
  sleep 180
  yum update -y
  yum install -y mysql55-server
  service mysqld start
  /usr/bin/mysqladmin -u root password 'secret'
  mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
  mysql -u root -psecret -e 'CREATE TABLE Animals (ID int(11) NOT NULL AUTO_INCREMENT, NAME varchar(45) DEFAULT NULL, ADDRESS varchar(255) DEFAULT NULL, PRIMARY KEY (ID));' test
  mysql -u root -psecret -e "INSERT INTO Animals (NAME, ADDRESS) values ('DOG', 'German Sheferd') ;" test
EOF
}
