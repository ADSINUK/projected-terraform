### Outputs
output "arn" {
  description = "Kinesis Firehose delivery stream ARN"
  value       = aws_kinesis_firehose_delivery_stream.delivery-stream.arn
}

# vim:filetype=terraform ts=2 sw=2 et:
