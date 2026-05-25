output "namespace_name" {
  description = "The name of the created namespace"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "namespace_uid" {
  description = "The UID of the namespace"
  value       = kubernetes_namespace.this.metadata[0].uid
}

output "namespace_labels" {
  description = "Labels applied to the namespace"
  value       = kubernetes_namespace.this.metadata[0].labels
}
