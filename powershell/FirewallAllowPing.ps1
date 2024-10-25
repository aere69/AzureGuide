# Modify firewall to respond to ping requests
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4

# Check domain source of authority
nslookup -type=SOA domainname.com
