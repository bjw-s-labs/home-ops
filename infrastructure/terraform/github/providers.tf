provider "github" {
  token = module.onepassword_item_github.fields.pat_terraform
}
