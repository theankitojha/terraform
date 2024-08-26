resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/my-app${local.environment_suffix}"
  retention_in_days = 14
}


# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "high-memory-alarm${local.environment_suffix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  alarm_actions = [aws_sns_topic.alerts.arn]
}


resource "aws_cloudwatch_metric_alarm" "service_health_check_failed" {
  alarm_name          = "service-health-check-failed${local.environment_suffix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnhealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  alarm_actions = [aws_sns_topic.alerts.arn]
}


resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu-alarm${local.environment_suffix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  alarm_actions = [aws_sns_topic.alerts.arn]
}


resource "aws_sns_topic" "alerts" {
  name = "ecs-alerts${local.environment_suffix}"
}

resource "aws_sns_topic_subscription" "alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "theankitojha@gmail.com"
}


# Dashboard

resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "ecs-dashboard${local.environment_suffix}"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          title = "CPU Utilization"
          region = "us-west-2"  # Add the region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name],
          ]
          period = 300
          stat = "Average"
        }
      },
      {
        type = "metric",
        x    = 0,
        y    = 6,
        width = 12,
        height = 6,
        properties = {
          title = "Memory Utilization"
          region = "us-west-2"  # Add the region
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.main.name],
          ]
          period = 300
          stat = "Average"
        }
      },
      {
        type = "metric",
        x    = 0,
        y    = 12,
        width = 12,
        height = 6,
        properties = {
          title = "ALB Unhealthy Host Count"
          region = "us-west-2"  # Add the region
          metrics = [
            ["AWS/ApplicationELB", "UnhealthyHostCount", "TargetGroup", aws_lb_target_group.app.arn_suffix],
          ]
          period = 300
          stat = "Sum"
        }
      }
    ]
  })
}

