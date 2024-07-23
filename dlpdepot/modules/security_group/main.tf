resource "aws_security_group" "sg" {
  vpc_id = var.vpc_id
  name   = var.name
  ingress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = "tcp"
    cidr_blocks = var.sg_source
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
