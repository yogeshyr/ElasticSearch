data "template_file" "ESsetup" {
  template = file("templates/ESsetup.tpl")
}

resource "aws_key_pair" "mykey" {
  key_name = "mykey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "ElasticSearch-1" {
  ami = lookup(var.AMIS, var.AWS_REGION)
  instance_type = "t2.micro"
  key_name = aws_key_pair.mykey.key_name
  security_groups = [ aws_security_group.ElasticSearch_SG.name ]
  user_data = data.template_file.ESsetup.rendered
  tags = {
    "Name" = "ElasticSearch-1"
  }

}