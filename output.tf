output "id" {
  description = "The ID of the instance"
  value       = try(aws_instance.this.id, "")
}

output "arn" {
  description = "The ARN of the instance"
  value = try(
    aws_instance.this.arn,
    null,
  )
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable."
  value = try(
    aws_instance.this.public_ip,
    null,
  )
}

output "availability_zone" {
  description = "The availability zone of the created instance"
  value       = data.aws_availability_zones.available.names[0]
}
