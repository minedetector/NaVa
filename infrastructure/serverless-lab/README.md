Prefix that all of the resources created must have the following tags
`Name: <team_nr>-<resource_name>`
`Team: tiim_<nr>`

1. Create security credentials for yourself
    1. Go to IAM
    2. Find your teams user
    3. Use the tab `Security Credentials` under `Access keys` create an access key
        1. `Use case` is `Command Line Interface` (CLI)
2. Create a database subnet group in `RDS`
    1. Choose the NaVa subnet
    2. Choose all three AZ-s
    3. Choose all `Database` subnet groups
3. Create a Security Group for your database
    1. Go to EC2 -> Security Groups
    2. Create a security group with
        1. Inbound rule allowing MYSQL port 3306 from `10.0.0.0/16`
4. Create the RDS cluster
    1. Use the `Full configuration` option
    2. Choose a `MySQL`
    3. Use the `Sandbox` template
    4. Choose the `Single-AZ DB instance deployment` deployment option
    5. Name of the DB cluster must be unique in our Account
    6. Ensure that the `Managed in AWS Secrets Manager` is chosen under `Credentials`
    7. instance type should be `db.t3.micro`
        1. click on `Burstable classes` if it isn’t checked
    8. `Don't connect to an EC2 compute resource`
    9. Ensure that the VPC is `NaVa`
    10. Use the already created `database subnet group`
    11. Use the Security Group you created
    12. Scroll down and open `Additional configuration`
        1. Create an initial database named `wordpress`
5. After creating the RDS resource go to `Secrets Manager` to confirm that the access was created correctly
    1. Look for a resource named `rds!db-....`
6. Create parameters in `Parameter Store`
    1. `/dev/WORDPRESS_DB_HOST_<team_name>` - text
        1. Add the endpoint with the port like `<endpoint>:3306`
    2. `/dev/WORDPRESS_DB_NAME_<team_name>` - secureString
        1. Using the default KMS key because it doesn’t require any extra KMS permissions to use it
        2. The value is `wordpress`
7. ECR
    1. Create a private repo `<team_name>/wordpress`
        1. Pull the latest wordpress image
            1. `docker pull --platform linux/amd64 wordpress:latest`
        2. Inside the created repo press the `View push commands` to get the commands for tagging and pushing your image
8. Create ALB SG
    1. Ingress allow HTTP from anywhere (`0.0.0.0/0` )
9. Create a target group
    1. `ip`
    2. HTTP1
    3. health check `/wp-admin/images/wordpress-logo.svg`
10. Create a Load balancer
    1. Application Load Balancer
    2. `internet-facing`
    3. Choose the `NaVa` VPC
    4. Select at least 2 subnets, make sure that they are `public` ones
    5. Attach your Security Group
11. ECS
    1. Create the task definition to define the containers we want to use
        1. Launch type = `AWS Fargate`
        2. Add the previously created `task` and `task execution` roles
        3. Name the container `wordpress`
        4. Use the already created custom task and taskExecution IAM Roles for permissions
        5. Attach your image from ECR
        6. port mapping is `80`
        7. Attach the following ENV-s to the task definition

            With `Parameter Store` just use the `ARN` of the parameter

            With `Secrets Manager` use the `ARN` but also add a `:username::` or `:password::` at the end of the `Value`

            1. WORDPRESS_DB_HOST - Parameter Store
            2. WORDPRESS_DB_NAME - Parameter Store
            3. WORDPRESS_DB_USER - Secrets Manager
            4. WORDPRESS_DB_PASSWORD - Secrets Manager
    2. Create the `Cluster`
        1. Use Fargate only
    3. Click on the created service and in the `Service` tab choose `Create service`
        1. Choose your `task definition`
        2. Ensure the `Compute configuration` is set to `Launch type`
        3. Open up Networking
            1. Choose the `NaVa` VPC
            2. Choose `Private subnets`
            3. Choose the `ALB Security Group`
            4. Turn off `Public IP`
        4. Open up `Load Balancing`
            1. `Use load balancing`
            2. Use the created load balancer
            3. Use the created target group
