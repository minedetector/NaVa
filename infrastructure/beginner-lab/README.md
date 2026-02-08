All created AWS resources must have the following tags attached

- The following tags need to be attached
    - `Name` = `<team_name>-<resource || custom name>`
    - `Team` = `<team_name>`
1. Create a EC2 Security group for your server
    1. Choose `NaVa` under `VPC`
    2. Inbound rules must allow `SSH` and `HTTP`
2. Create a EC2 instance
    1. Use an Amazon AMI (HVM) image
    2. Instance type has to be t3.micro.
    3. Check that `auto-assign public IP` is Enabled, that you are using the NaVa VPC and the NaVa public subnet
    4. Choose the security group created in step 1
    5. Using a bootstrap script under the `Advanced details` update the server and install httpd and creates an index.html file that displays your Uni-ID in the web page.

        ```bash
        #!/bin/bash
        yum update -y
        yum install httpd -y
        service httpd start
        chkconfig httpd on
        cd /var/www/html
        echo "<html><h1>Team Name here</h1></html>" > index.html
        ```

    6. Make sure that your website is visible, by checking the public IP address
        1. Be sure to use `http` and not `https`
3. Create an IAM Policy for the IAM role.
    1. Allow the reading, creating and tagging of S3 objects

        ```python
        "s3:PutObject",
        "s3:GetObject",
        "s3:PutObjectTagging",
        "s3:ListAllMyBuckets",
        "s3:ListBucket"
        ```

4. Create an IAM Role for the EC2 instance to get access to S3 buckets
    1. Attach the role to the instance (if stuck, google, how to add role to an ec2 instance)
    2. `Connect` to the instance and write the command
        1. `aws s3 ls`
