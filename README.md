# pfSense RDS Multigateway Config
Setting up a metro stretched pfsense for rds or a website

Fill the CSV form with desired configuration then run the powershell script for changing the config file.

When you are setting up the pfsense firewall choose interfaces in order > WAN, LAN, OPT1

The password for the firewall would be 1GaS$h3Ez5 after restore.

If you know how I can do this directly on firewall with ssh instead of using backup and restore config file please let me know, otherwise I'm thinking of maybe using ansible if supported!

PS:The firewall would have an IPSEC tunnel setup (disabled) for you ready so you could tunnel to the customer if needed.
