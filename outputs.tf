output "public_ips" {
    value = {
        for instance in azurerm_linux_virtual_machine.vm:
        instance.id => instance.public_ip_address
    }
}

output "private_ips" {
    value = {
        for instance in azurerm_linux_virtual_machine.vm:
        instance.id => instance.private_ip_address
    }
}