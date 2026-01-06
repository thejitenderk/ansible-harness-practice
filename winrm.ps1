# Enable WinRM
winrm quickconfig -force

# Allow basic authentication
winrm set winrm/config/service/auth '@{Basic="true"}'

# Allow unencrypted traffic (Ansible ke liye required)
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# Increase memory limits
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'

# Open firewall for WinRM HTTP (5985)
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985

# Set service startup
Set-Service WinRM -StartupType Automatic
Restart-Service WinRM
