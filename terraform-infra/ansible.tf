resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    ec2_public_ip = module.ec2_instance.public_ip
    ssh_key_path  = abspath(local_file.private_key.filename)
  })
  filename = "${path.module}/../ansible/inventory.ini"

  depends_on = [module.ec2_instance]
}

resource "null_resource" "wait_for_instance" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [module.ec2_instance]
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command     = "ansible-playbook -i inventory.ini deploy.yml"
    working_dir = "${path.module}/../ansible"
  }

  depends_on = [
    local_file.ansible_inventory,
    null_resource.wait_for_instance
  ]

  # Trigger re-run if inventory changes
  triggers = {
    inventory_content = local_file.ansible_inventory.content
  }
}