
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "norwayeast"
  tags = {
    "env"     = "test"
    "cost_pr" = "ba108"
  }
}
