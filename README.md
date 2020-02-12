# petclinic

Steps to run the application:

Prequiste: Terraform should be installed on you local machine

1) Initilaze the current directory: terraform init
2) Create a plan and save it on local: terraform plan
3) Apply the plan: terraform apply

"terraform apply" will do the following:
- Spin up an EC2 instance of type t2.micro in us-east-1 region
- Install and configure Java
- Install and run Jenkins
- Install Git
- Install Maven
- Install, configure and run Elasticsearch, Logstash and Kibana

4) Access the Jenkins console, download the plugins and configure the Git, Maven and Java under Manage Jenkins > Global Tool Configuration
5) Create a new Jenkins job and configure the following:
- Under Source Code Management, select Git and pass the repository URL "https://github.com/spring-projects/spring-petclinic.git"
- Under Build, select "Invoke top level Maven targets", select your maven in Maven Version and pass the command "clean install"
- Under Build, select "Execute shell" and pass the command "java -jar spring-petclinic-2.2.0.BUILD-SNAPSHOT.jar" > /home/ec2-user/spring-petclinic-master/target/petclinic.log
6) All the logs will be streamed through logstash > elasticsearch > kibana
7) A real time Kibana Dashboard can be created via Kibana Console(kibana_dashboard.docx attached).

Jenkins steps can be further automated by writing Jenkinsfile. 
