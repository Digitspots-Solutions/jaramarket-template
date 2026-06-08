resource "aws_codepipeline" "main" {
  count    = length(var.microservices)
  name     = "${var.project_name}-${var.microservices[count.index]}-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.repository_id
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.main[count.index].name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        ApplicationName                = aws_codedeploy_app.main[count.index].name
        DeploymentGroupName            = aws_codedeploy_deployment_group.main[count.index].deployment_group_name
        TaskDefinitionTemplateArtifact = "build_output"
        AppSpecTemplateArtifact        = "build_output"
      }
    }
  }
}

resource "aws_codebuild_project" "main" {
  count         = length(var.microservices)
  name          = "${var.project_name}-${var.microservices[count.index]}-build"
  service_role  = var.codebuild_role_arn
  
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type = "CODEPIPELINE"
  }
}

resource "aws_codedeploy_app" "main" {
  count            = length(var.microservices)
  compute_platform = "ECS"
  name             = "${var.project_name}-${var.microservices[count.index]}-deploy"
}

resource "aws_codedeploy_deployment_group" "main" {
  count                  = length(var.microservices)
  app_name               = aws_codedeploy_app.main[count.index].name
  deployment_group_name  = "${var.project_name}-${var.microservices[count.index]}-dg"
  service_role_arn       = var.codedeploy_role_arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.services[count.index].name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.https.arn]
      }
      target_group {
        name = aws_lb_target_group.services[count.index].name
      }
      target_group {
        name = aws_lb_target_group.services_bluegreen[count.index].name
      }
    }
  }
}

resource "aws_lb_target_group" "services_bluegreen" {
  count       = length(var.microservices)
  name        = "${var.project_name}-${var.microservices[count.index]}-bg-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}
