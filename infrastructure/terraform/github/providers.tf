provider "github" {
  token = data.sops_file.github_secrets.data["github_access_token"]
}
