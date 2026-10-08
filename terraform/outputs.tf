output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_instance_id" {
  value = aws_instance.jenkins.id
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}
