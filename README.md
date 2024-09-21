
# Node.Js application deployment on AWS 
## Tool Used 
- Jenkins
- AWS Codedeploy
- AWS EC2
- GitHub

This Guide will walk you through step by step process of creating a jenkins file to deploying the application on AWS EC2.

## Project Architecture
![Architecture Diagram](./CICD.png)


### 1. Clone the repository

```
git clone https://github.com/NaitikSinghal/Nodejs-Jenkins
```
### 2. Launch an EC2 instance in AWS console

- Install Jenkins in this instance, you will need to download jdk as well.
```
  sudo apt update
  sudo apt install openjdk-17-jre
```
Verify Java is installed
``` java -version```

Install Jenkins now, 
```
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```


**Note: ** By default, Jenkins will not be accessible to the external world due to the inbound traffic restriction by AWS. Open port 8080 in the inbound traffic rules as show below.

- EC2 > Instances > Click on <Instance-ID>
- In the bottom tabs -> Click on Security
- Security groups
- Add inbound traffic rules as shown in the image (you can just allow TCP 8080 as well, in my case, I allowed `All traffic`).

### Login to Jenkins using the below URL:

http://<ec2-instance-public-ip-address>:8080    [You can get the ec2-instance-public-ip-address from your AWS EC2 console page]

Note: If you are not interested in allowing `All Traffic` to your EC2 instance
      1. Delete the inbound traffic rule for your instance
      2. Edit the inbound traffic rule to only allow custom TCP port `8080`
  
After you login to Jenkins, 
      - Run the command to copy the Jenkins Admin Password - `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
      - Enter the Administrator password

- Go to Jenkins-manager and Downloads Nodejs and AWS Codedeploy plugins.
  
- Create a new pipeline project and configure it with you github repository link
  
- You need to pass the Webhook from here to the Github repo for Commit-push changes triggers.
1. In GitHub, go to your repository settings → Webhooks → Add webhook.
2. Set the Payload URL to http://<your-jenkins-server-url>/github-webhook/.
3. Choose application/json as the content type.
   
- Create and attach an IAM role as EC2SesssionManager and also with FullS3access from your AWS Console.

### 3. Create an S3 bucket 

1. Go to yout AWS console -> S3 service -> Create bucket
2. Attatch an IAM role with Fulls3Access Policy.
3. We need to pass this S3 bucket name to jenkins pipeline as code deploy will use this to upload the artifacts.

### 4. Create an AMI with CodeDeploy agent installed in it.

1. Launch another EC2 instance, Login to your server and start executing the following commands.
   
  ``` sudo apt update```

  ``` sudo apt install ruby-full ```

  ``` sudo apt install wget```

  ```cd /home/ubuntu```

 Enter the following command:

  ```wget https://bucket-name.s3.region-identifier.amazonaws.com/latest/install```
  
 bucket-name is the name of the Amazon S3 bucket that contains the CodeDeploy Resource Kit files for your region, and region-identifier is the identifier for your region.
 For example:
 https://aws-codedeploy-us-east-2.s3.us-east-

 ```chmod +x ./install```
 
 ```sudo ./install auto```
 
To check that the service is running

- Enter the following command:
```systemctl status codedeploy-agent```

2. Now as we have successfully installed codedeploy agent, our next step is to create an AMI of this instance.

   - Go to the Actions -> Image and Templates -> name the image -> Create Image.

### 5. Now using this AMI create a Launch Template. 

1. Go to resources -> Launch Template -> name "nodejs-application" -> select the AMI we just created for codedeploy agent.
2. Attatch "Ec2sessionManager IAM role" -> Launch Template.

### 6. Create AutoScaling Group 

1. Go to resource -> AutoScaling Gropu -> name "nodejs-application" -> select the launch template we just created above.
2. In the desired capacity select Min and Max desired capacity according to the need.( I have used 1 capacity only) 
3. Click on create Autoscaling group.

### 7. Create a Deployment Group in AWS Code Deploy

1. Go to resources -> Code Deploy -> name the application "nodejs-applicatoin" and select the compute group as "EC2/On-Prem"
   Now in this application, create a deployment group.
2. create deployment group -> name "nodejs-application-DG" ,
   now before moving forward we need to attach on service-role here, so create an IAM role for CodeDeploy resource
3. Copy the ARN code and paste it in the deployment group, Service role.
4. deployment type -> In Place -> select the autoscaling group we created above.
5. Deployment settings -> OneAtATime.
6. click -> create deployment group.

### Build the jenkins pipeline.
if any error is coming just check at which stage and try to solve the issue . 
