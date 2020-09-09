output "public_ips" {
    value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "private_ips" {
    value = azurerm_linux_virtual_machine.vm.private_ip_address
}