# Create EC2 Instances in Public Subnets
resource "aws_instance" "webserver" {
  count                  = length(var.public_subnet_cidr_blocks)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  key_name               = var.key_name
  user_data              = base64encode(templatefile("userdata.sh", {}))

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
