resource  "kubernetes_storage_class_v1" "efs_sc" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  # parameters = {
  #   provisioning_mode = "efs-ap"
  #   directory_perms = "700"
  #   file_system_id = aws_efs_file_system.noaa.id
  # }
}

resource "kubernetes_persistent_volume_v1" "noaa" {
  metadata {
    name = "noaa-hydro-data"
  }
  spec {
    access_modes = ["ReadWriteOnce", "ReadOnlyMany"]
    storage_class_name = "efs-sc"
    capacity = {
      storage = "512Gi"
    }
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = aws_efs_file_system.noaa.id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "noaa" {
  metadata {
    name = "noaa-hydro-data"
    namespace = "daskhub"
  }
  spec {
    access_modes = ["ReadWriteOnce", "ReadOnlyMany"]
    storage_class_name = "efs-sc"
    resources {
      requests = {
        storage = "512Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.noaa.metadata.0.name
  }
}
