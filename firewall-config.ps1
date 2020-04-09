############################ Script by SIAVASHYOUSEFI.com ##############################################
###Get all the files from my github and place them in drive C:\Temp\ Folder and run then in sequence.###
########################################################################################################

Set-ExecutionPolicy Unrestricted -Scope Process -Force

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$values = @{}
Import-Csv  $dir\firewall-config-values.csv |
    ForEach-Object { $values.add($_.Name, $_.Value) }

[xml]$fwcfg = Get-Content $dir\pfsense-config.xml

$fwhostname = $values.customerid + "-FW-01"
$primarywandescr = $values.primarywanlocation + "_WAN"
$primarywangateway = $values.primarywanlocation + "_GW"
$secondarywandescr = $values.secondarywanlocation + "_WAN"
$secondarywangateway = $values.secondarywanlocation + "_GW"
$primarywanipaddr = $values.primarywanip.Substring(0, $values.primarywanip.IndexOf("/"))
$primarywansubnet = $values.primarywanip.Substring($values.primarywanip.IndexOf("/")+1)
$secondarywanipaddr = $values.secondarywanip.Substring(0, $values.secondarywanip.IndexOf("/"))
$secondarywansubnet = $values.secondarywanip.Substring($values.secondarywanip.IndexOf("/")+1)
$lanipaddr = $values.lanip.Substring(0, $values.lanip.IndexOf("/"))
$lansubnet = $values.lanip.Substring($values.lanip.IndexOf("/")+1)
$mspalias = $values.mspid
$primarywanrdsnatdscr = "Redirect to RDweb Gateway (" + $values.primarywanlocation + ")"
$secondarywanrdsnatdscr = "Redirect to RDweb Gateway (" + $values.secondarywanlocation + ")"
$primarywanfwnatdscr = "Access to firewall (" + $values.primarywanlocation + ")"
$secondarywanfwnatdscr = "Access to firewall (" + $values.secondarywanlocation + ")"
$primarywanpingdscr = "$mspalias" + "_Ping (" + $values.primarywanlocation + ")"
$secondarywanpingdscr = "$mspalias" + "_Ping (" + $values.secondarywanlocation + ")"
$primarywansnmpdscr = "$mspalias" + "_SNMP (" + $values.primarywanlocation + ")"
$secondarywansnmpdscr = "$mspalias" + "_SNMP (" + $values.secondarywanlocation + ")"
$gatewaygroup = $values.customerid + "_GW"
$gatewaygroupprimarywan = $primarywangateway + "|1|address"
$gatewaygroupsecondarywan = $secondarywangateway + "|2|address"

$logfile = ($dir) + "\Firewall-Config.log"

New-Item $logfile -ItemType file -Force

Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $logfile = ($dir) + "\Firewall-Config.log"
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
        Write-Output $Line
    }
    Else {
        Write-Output $Line
    }
}

$configflag = 0
Clear-Variable *config -Scope Global

Write-Log INFO "Running the script"

if ($fwcfg.pfsense.system.hostname -eq $fwhostname) {
    Write-Host "Hostname is already configured"  -ForegroundColor Green
} else {
    Write-Host "Hostname will change to $fwhostname"  -ForegroundColor Red
    $hostnameconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.system.timezone -eq $values.timezone) {
    Write-Host "Timezone is already configured"  -ForegroundColor Green
} else {
    Write-Host "Timezone will change to $($values.timezone)"  -ForegroundColor Red
    $timezoneconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.wan.if -eq $values.primarywaninterface) {
    Write-Host "Primary WAN interface is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN interface will change to $($values.primarywaninterface)"  -ForegroundColor Red
    $primarywaninterfaceconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.wan.descr.'#cdata-section' -eq $primarywandescr) {
    Write-Host "Primary WAN Description is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN Description will change to $primarywandescr"  -ForegroundColor Red
    $primarywandescrconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.wan.ipaddr -eq $primarywanipaddr) {
    Write-Host "Primary WAN IP address is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN IP address will change to $primarywanipaddr"  -ForegroundColor Red
    $primarywanipaddrconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.wan.subnet -eq $primarywansubnet) {
    Write-Host "Primary WAN subnet is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN subnet will change to $primarywansubnet"  -ForegroundColor Red
    $primarywansubnetconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.wan.gateway -eq $primarywangateway) {
    Write-Host "Primary WAN gateway is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN gateway will change to $primarywangateway"  -ForegroundColor Red
    $primarywangatewayconfig = 1
    $configflag = 1n
}

if ($fwcfg.pfsense.interfaces.lan.if -eq $values.laninterface) {
    Write-Host "Primary WAN interface is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN interface will change to $($values.laninterface)"  -ForegroundColor Red
    $laninterfaceconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.lan.ipaddr -eq $lanipaddr) {
    Write-Host "Primary WAN IP address is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN IP address will change to $lanipaddr"  -ForegroundColor Red
    $lanipaddrconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.lan.subnet -eq $lansubnet) {
    Write-Host "Primary WAN subnet is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN subnet will change to $lansubnet"  -ForegroundColor Red
    $lansubnetconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.opt1.if -eq $values.secondarywaninterface) {
    Write-Host "Secondary WAN interface is already configured"  -ForegroundColor Green
} else {
    Write-Host "Secondary WAN interface will change to $($values.secondarywaninterface)"  -ForegroundColor Red
    $secondarywaninterfaceconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.opt1.descr.'#cdata-section' -eq $secondarywandescr) {
    Write-Host "Secondary WAN Description is already configured"  -ForegroundColor Green
} else {
    Write-Host "Secondary WAN Description will change to $secondarywandescr"  -ForegroundColor Red
    $secondarywandescrconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.opt1.ipaddr -eq $secondarywanipaddr) {
    Write-Host "Secondary WAN IP address is already configured"  -ForegroundColor Green
} else {
    Write-Host "Secondary WAN IP address will change to $secondarywanipaddr"  -ForegroundColor Red
    $secondarywanipaddrconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.opt1.subnet -eq $secondarywansubnet) {
    Write-Host "Secondary WAN subnet is already configured"  -ForegroundColor Green
} else {
    Write-Host "Secondary WAN subnet will change to $secondarywansubnet"  -ForegroundColor Red
    $secondarywansubnetconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.interfaces.opt1.gateway -eq $secondarywangateway) {
    Write-Host "Secondary WAN gateway is already configured"  -ForegroundColor Green
} else {
    Write-Host "Secondary WAN gateway will change to $secondarywangateway"  -ForegroundColor Red
    $secondarywangatewayconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.snmpd.rocommunity -eq $values.snmp) {
    Write-Host "SNMP is already configured"  -ForegroundColor Green
} else {
    Write-Host "SNMP will change to $($values.snmp)"  -ForegroundColor Red
    $snmpconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan"}).target -eq $values.rdsgateway) {
    Write-Host "RDS Gateway NAT target for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "RDS Gateway NAT target for primary WAN will change to $($values.rdsgateway)"  -ForegroundColor Red
    $primarywanrdsnatdstconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan"}).descr.'#cdata-section' -eq $primarywanrdsnatdscr) {
    Write-Host "RDS Gateway NAT description for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "RDS Gateway NAT description for primary WAN will change to $primarywanrdsnatdscr"  -ForegroundColor Red
    $primarywanrdsnatdscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1"}).target -eq $values.rdsgateway) {
    Write-Host "RDS Gateway NAT target for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "RDS Gateway NAT target for secondary WAN will change to $($values.rdsgateway)"  -ForegroundColor Red
    $secondarywanrdsnatdstconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1"}).descr.'#cdata-section' -eq $secondarywanrdsnatdscr) {
    Write-Host "RDS Gateway NAT description for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "RDS Gateway NAT description for secondary WAN will change to $secondarywanrdsnatdscr"  -ForegroundColor Red
    $secondarywanrdsnatdscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "wan"}).target -eq $lanipaddr) {
    Write-Host "Firewall access NAT target for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access NAT target for primary WAN will change to $lanipaddr"  -ForegroundColor Red
    $primarywanfwnatdstconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "wan"}).descr.'#cdata-section' -eq $primarywanfwnatdscr) {
    Write-Host "Firewall access NAT description for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access NAT description for primary WAN will change to $primarywanfwnatdscr"  -ForegroundColor Red
    $primarywanfwnatdscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "wan"}).source.address -eq $mspalias) {
    Write-Host "Firewall access NAT source for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access NAT source for primary WAN will change to $mspalias"  -ForegroundColor Red
    $primarywanfwnatsrcconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "opt1"}).target -eq $lanipaddr) {
    Write-Host "Firewall access NAT target for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access NAT target for secondary WAN will change to $lanipaddr"  -ForegroundColor Red
    $secondarywanfwnatdstconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "opt1"}).descr.'#cdata-section' -eq $secondarywanfwnatdscr) {
    Write-Host "Firewall access NAT description for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access NAT description for secondary WAN will change to $secondarywanfwnatdscr"  -ForegroundColor Red
    $secondarywanfwnatdscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "opt1"}).source.address -eq $mspalias) {
    Write-Host "Firewall access NAT source for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access NAT source for secondary WAN will change to $mspalias"  -ForegroundColor Red
    $secondarywanfwnatsrcconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf7756dd7fb6.68085449"}).destination.address -eq $values.rdsgateway) {
    Write-Host "RDS gateway access rule for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "RDS gateway access rule for primary WAN will change to $($values.rdsgateway)"  -ForegroundColor Red
    $primarywanrdsruledstconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf7756dd7fb6.68085449"}).descr.'#cdata-section' -eq $primarywanrdsnatdscr) {
    Write-Host "RDS gateway access rule description for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "RDS gateway access rule description for primary WAN will change to $primarywanrdsnatdscr"  -ForegroundColor Red
    $primarywanrdsruledscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf79467db234.65307739"}).source.address -eq $mspalias) {
    Write-Host "Firewall access rule source for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access rule source for primary WAN will change to $mspalias"  -ForegroundColor Red
    $primarywanfwrulesrcconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf79467db234.65307739"}).destination.address -eq $lanipaddr) {
    Write-Host "Firewall access rule target for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access rule target for primary WAN will change to $lanipaddr"  -ForegroundColor Red
    $primarywanfwruledstconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf79467db234.65307739"}).descr.'#cdata-section' -eq $primarywanfwnatdscr) {
    Write-Host "Firewall access rule description for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access rule description for primary WAN will change to $primarywanfwnatdscr"  -ForegroundColor Red
    $primarywanfwruledscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.protocol -eq "icmp" -and $_.interface -eq "wan"}).source.address -eq $mspalias) {
    Write-Host "Firewall ping rule source for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall ping rule source for primary WAN will change to $mspalias"  -ForegroundColor Red
    $primarywanpingulesrcconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.protocol -eq "icmp" -and $_.interface -eq "wan"}).descr.'#cdata-section' -eq $primarywanpingdscr) {
    Write-Host "Firewall ping rule description for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall ping rule description for primary WAN will change to $primarywanpingdscr"  -ForegroundColor Red
    $primarywanpinguledscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "161" -and $_.interface -eq "wan"}).source.address -eq $values.mspsnmp) {
    Write-Host "Firewall snmp rule source for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall snmp rule source for primary WAN will change to $($values.mspsnmp)"  -ForegroundColor Red
    $primarywansnmprulesrcconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "161" -and $_.interface -eq "wan"}).descr.'#cdata-section' -eq $primarywansnmpdscr) {
    Write-Host "Firewall snmp rule description for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall snmp rule description for primary WAN will change to $primarywansnmpdscr"  -ForegroundColor Red
    $primarywansnmpruledscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.descr.'#cdata-section' -eq "Default allow LAN to any rule" -and $_.interface -eq "lan"}).gateway -eq $gatewaygroup) {
    Write-Host "Firewall default LAN rule gateway for primary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall default LAN rule gateway for primary WAN will change to $gatewaygroup"  -ForegroundColor Red
    $defaultlanrulegtwconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "161" -and $_.interface -eq "opt1"}).source.address -eq $values.mspsnmp) {
    Write-Host "Firewall snmp rule source for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall snmp rule source for secondary WAN will change to $($values.mspsnmp)"  -ForegroundColor Red
    $secondarywansnmprulesrcconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "161" -and $_.interface -eq "opt1"}).descr.'#cdata-section' -eq $secondarywansnmpdscr) {
    Write-Host "Firewall snmp rule description for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall snmp rule description for secondary WAN will change to $secondarywansnmpdscr"  -ForegroundColor Red
    $secondarywansnmpruledscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf76e6bc7b91.79202521"}).destination.address -eq $values.rdsgateway) {
    Write-Host "RDS gateway access rule for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "RDS gateway access rule for secondary WAN will change to $($values.rdsgateway)"  -ForegroundColor Red
    $secondarywanrdsruledstconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf76e6bc7b91.79202521"}).descr.'#cdata-section' -eq $secondarywanrdsnatdscr) {
    Write-Host "RDS gateway access rule description for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "RDS gateway access rule description for secondary WAN will change to $secondarywanrdsnatdscr"  -ForegroundColor Red
    $secondarywanrdsruledscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf781df0fd34.27286944"}).source.address -eq $mspalias) {
    Write-Host "Firewall access rule source for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access rule source for secondary WAN will change to $mspalias"  -ForegroundColor Red
    $secondarywanfwrulesrcconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf781df0fd34.27286944"}).destination.address -eq $lanipaddr) {
    Write-Host "Firewall access rule target for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access rule target for secondary WAN will change to $lanipaddr"  -ForegroundColor Red
    $secondarywanfwruledstconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf781df0fd34.27286944"}).descr.'#cdata-section' -eq $secondarywanfwnatdscr) {
    Write-Host "Firewall access rule description for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall access rule description for secondary WAN will change to $secondarywanfwnatdscr"  -ForegroundColor Red
    $secondarywanfwruledscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.protocol -eq "icmp" -and $_.interface -eq "opt1"}).source.address -eq $mspalias) {
    Write-Host "Firewall ping rule source for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall ping rule source for secondary WAN will change to $mspalias"  -ForegroundColor Red
    $secondarywanpingulesrcconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.filter.rule | Where-Object {$_.protocol -eq "icmp" -and $_.interface -eq "opt1"}).descr.'#cdata-section' -eq $secondarywanpingdscr) {
    Write-Host "Firewall ping rule description for secondary WAN is already configured"  -ForegroundColor Green
} else {
    Write-Host "Firewall ping rule description for secondary WAN will change to $secondarywanpingdscr"  -ForegroundColor Red
    $secondarywanpinguledscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.aliases.alias | Where-Object {$_.type -eq "host" -and $_.descr.'#cdata-section' -eq "Firewall_WAN_Access"}).name -eq $mspalias) {
    Write-Host "MSP Alias name is already configured"  -ForegroundColor Green
} else {
    Write-Host "MSP Alias name will change to $mspalias"  -ForegroundColor Red
    $mspaliasnameconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.aliases.alias | Where-Object {$_.type -eq "host" -and $_.descr.'#cdata-section' -eq "Firewall_WAN_Access"}).address -eq $values.mspaliashosts) {
    Write-Host "MSP Alias hosts is already configured"  -ForegroundColor Green
} else {
    Write-Host "MSP Alias hosts will change to $($values.mspaliashosts)"  -ForegroundColor Red
    $mspaliashostsconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.aliases.alias | Where-Object {$_.type -eq "host" -and $_.descr.'#cdata-section' -eq "Firewall_WAN_Access"}).detail.'#cdata-section' -eq $values.mspaliashostsdetails) {
    Write-Host "MSP Alias hosts details is already configured"  -ForegroundColor Green
} else {
    Write-Host "MSP Alias hosts details will change to $($values.mspaliashostsdetails)"  -ForegroundColor Red
    $mspaliashostsdetailsconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "wan"}).gateway -eq $values.primarywangatewayaddr) {
    Write-Host "Primary WAN gateway address is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN gateway address will change to $($values.primarywangatewayaddr)"  -ForegroundColor Red
    $primarywangatewayaddrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "wan"}).name -eq $primarywangateway) {
    Write-Host "Primary WAN gateway name is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN gateway name will change to $primarywangateway"  -ForegroundColor Red
    $primarywangatewaynameconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "wan"}).descr.'#cdata-section' -eq $primarywangateway) {
    Write-Host "Primary WAN gateway description is already configured"  -ForegroundColor Green
} else {
    Write-Host "Primary WAN gateway description will change to $primarywangateway"  -ForegroundColor Red
    $primarywangatewaydscrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "opt1"}).gateway -eq $values.secondarywangatewayaddr) {
    Write-Host "Secondary WAN gateway address is already configured"  -ForegroundColor Green
} else {
    Write-Host "Secondary WAN gateway address will change to $($values.secondarywangatewayaddr)"  -ForegroundColor Red
    $secondarywangatewayaddrconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "opt1"}).name -eq $secondarywangateway) {
    Write-Host "Secondary WAN gateway name is already configured"  -ForegroundColor Green
} else {
    Write-Host "Secondary WAN gateway name will change to $secondarywangateway"  -ForegroundColor Red
    $secondarywangatewaynameconfig = 1
    $configflag = 1
}

if (($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "opt1"}).descr.'#cdata-section' -eq $secondarywangateway) {
    Write-Host "Secondary WAN gateway description is already configured"  -ForegroundColor Green
} else {
    Write-Host "Secondary WAN gateway description will change to $secondarywangateway"  -ForegroundColor Red
    $secondarywangatewaydscronfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.gateways.defaultgw4 -eq $gatewaygroup) {
    Write-Host "Gateway group is already configured"  -ForegroundColor Green
} else {
    Write-Host "Gateway group will change to $gatewaygroup"  -ForegroundColor Red
    $defaultwangtwconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.gateways.gateway_group.name -eq $gatewaygroup) {
    Write-Host "Gateway group name is already configured"  -ForegroundColor Green
} else {
    Write-Host "Gateway group name will change to $gatewaygroup"  -ForegroundColor Red
    $wangtwgrpnameconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.gateways.gateway_group.item[0] -eq $gatewaygroupprimarywan) {
    Write-Host "Gateway group primary wan is already configured"  -ForegroundColor Green
} else {
    Write-Host "Gateway group primary wan will change to $gatewaygroupprimarywan"  -ForegroundColor Red
    $gatewaygroupprimarywanconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.gateways.gateway_group.item[1] -eq $gatewaygroupsecondarywan) {
    Write-Host "Gateway group secondary wan is already configured"  -ForegroundColor Green
} else {
    Write-Host "Gateway group secondary wan will change to $gatewaygroupsecondarywan"  -ForegroundColor Red
    $gatewaygroupsecondarywanconfig = 1
    $configflag = 1
}

if ($fwcfg.pfsense.gateways.gateway_group.descr.'#cdata-section' -eq $gatewaygroup) {
    Write-Host "Gateway group description is already configured"  -ForegroundColor Green
} else {
    Write-Host "Gateway group description will change to $gatewaygroup"  -ForegroundColor Red
    $wangtwgrpdscrconfig = 1
    $configflag = 1
}


Write-Host "Evaluation finished." -ForegroundColor Magenta

if($configflag -eq 1){

    $title1    = 'Configuration change required'
    $question1 = 'Do you confirm the configuration changes?'
    $choices1 = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices1.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices1.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision1 = $Host.UI.PromptForChoice($title1, $question1, $choices1, 1)
    if ($decision1 -eq 0) {
        Write-Log INFO 'Configuration Confirmed'

        if ($hostnameconfig -eq 1) {
            Write-Log INFO "Configuring hostname to $fwhostname..."
            $fwcfg.pfsense.system.hostname = $fwhostname
        } else {
            Write-Log INFO "Skipping hostname configuration."
        }

        if ($timezoneconfig -eq 1) {
            Write-Log INFO "Configuring timezone to $($values.timezone)..."
            $fwcfg.pfsense.system.timezone = $values.timezone
        } else {
            Write-Log INFO "Skipping timezone configuration."
        }
        
        if ($primarywaninterfaceconfig -eq 1) {
            Write-Log INFO "Configuring primary WAN interface to $($values.primarywaninterface)..."
            $fwcfg.pfsense.interfaces.wan.if = $values.primarywaninterface
        } else {
            Write-Log INFO "Skipping primary WAN interface configuration."
        }

        if ($primarywandescrconfig -eq 1) {
            Write-Log INFO "Configuring primary WAN description to $primarywandescr..."
            $fwcfg.pfsense.interfaces.wan.descr.'#cdata-section' = $primarywandescr
        } else {
            Write-Log INFO "Skipping primary WAN description configuration."
        }

        if ($primarywanipaddrconfig -eq 1) {
            Write-Log INFO "Configuring primary WAN ip address to $primarywanipaddr..."
            $fwcfg.pfsense.interfaces.wan.ipaddr = $primarywanipaddr
        } else {
            Write-Log INFO "Skipping primary WAN ip address configuration."
        }

        if ($primarywansubnetconfig -eq 1) {
            Write-Log INFO "Configuring primary WAN subnet to $primarywansubnet..."
            $fwcfg.pfsense.interfaces.wan.subnet = $primarywansubnet
        } else {
            Write-Log INFO "Skipping primary WAN subnet configuration."
        }

        if ($primarywangatewayconfig -eq 1) {
            Write-Log INFO "Configuring primary WAN gateway to $($primarywangateway)..."
            $fwcfg.pfsense.interfaces.wan.gateway = $primarywangateway
        } else {
            Write-Log INFO "Skipping primary WAN gateway configuration."
        }

        if ($laninterfaceconfig -eq 1) {
            Write-Log INFO "Configuring LAN interface to $($values.laninterface)..."
            $fwcfg.pfsense.interfaces.lan.if = $values.laninterface
        } else {
            Write-Log INFO "Skipping LAN interface configuration."
        }

        if ($landescrconfig -eq 1) {
            Write-Log INFO "Configuring LAN description to $($values.landescr)..."
            $fwcfg.pfsense.interfaces.lan.descr.'#cdata-section' = $values.landescr
        } else {
            Write-Log INFO "Skipping LAN description configuration."
        }

        if ($lanipaddrconfig -eq 1) {
            Write-Log INFO "Configuring LAN ip address to $($lanipaddr)..."
            $fwcfg.pfsense.interfaces.lan.ipaddr = $lanipaddr
        } else {
            Write-Log INFO "Skipping LAN ip address configuration."
        }

        if ($lansubnetconfig -eq 1) {
            Write-Log INFO "Configuring LAN subnet to $($lansubnet)..."
            $fwcfg.pfsense.interfaces.lan.subnet = $lansubnet
        } else {
            Write-Log INFO "Skipping LAN subnet configuration."
        }

        if ($secondarywaninterfaceconfig -eq 1) {
            Write-Log INFO "Configuring secondary WAN interface to $($values.secondarywaninterface)..."
            $fwcfg.pfsense.interfaces.opt1.if = $values.secondarywaninterface
        } else {
            Write-Log INFO "Skipping secondary WAN interface configuration."
        }

        if ($secondarywandescrconfig -eq 1) {
            Write-Log INFO "Configuring secondary WAN description to $($secondarywandescr)..."
            $fwcfg.pfsense.interfaces.opt1.descr.'#cdata-section' = $secondarywandescr
        } else {
            Write-Log INFO "Skipping secondary WAN description configuration."
        }

        if ($secondarywanipaddrconfig -eq 1) {
            Write-Log INFO "Configuring secondary WAN ip address to $($secondarywanipaddr)..."
            $fwcfg.pfsense.interfaces.opt1.ipaddr = $secondarywanipaddr
        } else {
            Write-Log INFO "Skipping secondary WAN ip address configuration."
        }

        if ($secondarywansubnetconfig -eq 1) {
            Write-Log INFO "Configuring secondary WAN subnet to $($secondarywansubnet)..."
            $fwcfg.pfsense.interfaces.opt1.subnet = $secondarywansubnet
        } else {
            Write-Log INFO "Skipping secondary WAN subnet configuration."
        }

        if ($secondarywangatewayconfig -eq 1) {
            Write-Log INFO "Configuring secondary WAN gateway to $($secondarywangateway)..."
            $fwcfg.pfsense.interfaces.opt1.gateway = $secondarywangateway
        } else {
            Write-Log INFO "Skipping secondary WAN gateway configuration."
        }

        if ($snmpconfig -eq 1) {
            Write-Log INFO "Configuring SNMP to $($values.snmp)..."
            $fwcfg.pfsense.snmpd.rocommunity = $values.snmp
        } else {
            Write-Log INFO "Skipping SNMP configuration."
        }

        if ($primarywanrdsnatdstconfig -eq 1) {
            Write-Log INFO "Configuring RDS Gateway NAT target for primary WAN to $($values.rdsgateway)..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan"}).target = $values.rdsgateway
        } else {
            Write-Log INFO "Skipping RDS Gateway NAT target for primary WAN configuration."
        }

        if ($primarywanrdsnatdscrconfig -eq 1) {
            Write-Log INFO "Configuring RDS Gateway NAT description for primary WAN to $primarywanrdsnatdscr..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan"}).descr.'#cdata-section' = $primarywanrdsnatdscr
        } else {
            Write-Log INFO "Skipping RDS Gateway NAT description for primary WAN configuration."
        }

        if ($secondarywanrdsnatdstconfig -eq 1) {
            Write-Log INFO "Configuring RDS Gateway NAT target for secondary WAN to $($values.rdsgateway)..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1"}).target = $values.rdsgateway
        } else {
            Write-Log INFO "Skipping RDS Gateway NAT target for secondary WAN configuration."
        }

        if ($secondarywanrdsnatdscrconfig -eq 1) {
            Write-Log INFO "Configuring RDS Gateway NAT description for secondary WAN to $secondarywanrdsnatdscr..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1"}).descr.'#cdata-section' = $secondarywanrdsnatdscr
        } else {
            Write-Log INFO "Skipping RDS Gateway NAT description for secondary WAN configuration."
        }

        if ($primarywanfwnatdstconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access NAT target for primary WAN to $lanipaddr..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "wan"}).target = $lanipaddr
        } else {
            Write-Log INFO "Skipping Firewall access NAT target for primary WAN configuration."
        }

        if ($primarywanfwnatdscrconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access NAT description for primary WAN to $primarywanfwnatdscr..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "wan"}).descr.'#cdata-section' = $primarywanfwnatdscr
        } else {
            Write-Log INFO "Skipping Firewall access NAT description for primary WAN configuration."
        }

        if ($primarywanfwnatsrcconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access NAT source for primary WAN to $mspalias..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "wan"}).source.address = $mspalias
        } else {
            Write-Log INFO "Skipping Firewall access NAT source for primary WAN configuration."
        }

        if ($secondarywanfwnatdstconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access NAT target for secondary WAN to $lanipaddr..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "opt1"}).target = $lanipaddr
        } else {
            Write-Log INFO "Skipping Firewall access NAT target for secondary WAN configuration."
        }

        if ($secondarywanfwnatdscrconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access NAT description for secondary WAN to $primarywanfwnatdscr..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "opt1"}).descr.'#cdata-section' = $secondarywanfwnatdscr
        } else {
            Write-Log INFO "Skipping Firewall access NAT description for secondary WAN configuration."
        }

        if ($secondarywanfwnatsrcconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access NAT source for secondary WAN to $mspalias..."
            ($fwcfg.pfsense.nat.rule | Where-Object {$_.destination.port -eq "8080" -and $_.interface -eq "opt1"}).source.address = $mspalias
        } else {
            Write-Log INFO "Skipping Firewall access NAT source for secondary WAN configuration."
        }

        if ($primarywanrdsruledstconfig -eq 1) {
            Write-Log INFO "Configuring RDS gateway access rule target for primary WAN to $($values.rdsgateway)..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf7756dd7fb6.68085449"}).destination.address = $values.rdsgateway
        } else {
            Write-Log INFO "Skipping RDS gateway access rule target for primary WAN configuration."
        }

        if ($primarywanrdsruledscrconfig -eq 1) {
            Write-Log INFO "Configuring RDS gateway access rule description for primary WAN to $primarywanrdsnatdscr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf7756dd7fb6.68085449"}).descr.'#cdata-section' = $primarywanrdsnatdscr
        } else {
            Write-Log INFO "Skipping RDS gateway access rule description for primary WAN configuration."
        }

        if ($primarywanfwrulesrcconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access rule source for primary WAN to $mspalias..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf79467db234.65307739"}).source.address = $mspalias
        } else {
            Write-Log INFO "Skipping Firewall access rule source for primary WAN configuration."
        }

        if ($primarywanfwruledstconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access rule target for primary WAN to $lanipaddr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf79467db234.65307739"}).destination.address = $lanipaddr
        } else {
            Write-Log INFO "Skipping Firewall access rule target for primary WAN configuration."
        }

        if ($primarywanfwruledscrconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access rule description for primary WAN to $primarywanfwnatdscr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "wan" -and $($_."associated-rule-id") -eq "nat_5caf79467db234.65307739"}).descr.'#cdata-section' = $primarywanfwnatdscr
        } else {
            Write-Log INFO "Skipping Firewall access rule description for primary WAN configuration."
        }

        if ($primarywanpingulesrcconfig -eq 1) {
            Write-Log INFO "Configuring Firewall ping rule source for primary WAN to $mspalias..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.protocol -eq "icmp" -and $_.interface -eq "wan"}).source.address = $mspalias
        } else {
            Write-Log INFO "Skipping Firewall ping rule source for primary WAN configuration."
        }

        if ($primarywanpinguledscrconfig -eq 1) {
            Write-Log INFO "Configuring Firewall ping rule description for primary WAN to $primarywanpingdscr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.protocol -eq "icmp" -and $_.interface -eq "wan"}).descr.'#cdata-section' = $primarywanpingdscr
        } else {
            Write-Log INFO "Skipping Firewall ping rule description for primary WAN configuration."
        }

        if ($primarywansnmprulesrcconfig -eq 1) {
            Write-Log INFO "Configuring Firewall snmp rule source for primary WAN to $($values.mspsnmp)..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "161" -and $_.interface -eq "wan"}).source.address = $values.mspsnmp
        } else {
            Write-Log INFO "Skipping Firewall snmp rule source for primary WAN configuration."
        }

        if ($primarywansnmpruledscrconfig -eq 1) {
            Write-Log INFO "Configuring Firewall snmp rule description for primary WAN to $primarywansnmpdscr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "161" -and $_.interface -eq "wan"}).descr.'#cdata-section' = $primarywansnmpdscr
        } else {
            Write-Log INFO "Skipping Firewall snmp rule description for primary WAN configuration."
        }

        if ($defaultlanrulegtwconfig -eq 1) {
            Write-Log INFO "Configuring Firewall default LAN rule gateway for primary WAN to $gatewaygroup..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.descr.'#cdata-section' -eq "Default allow LAN to any rule" -and $_.interface -eq "lan"}).gateway = $gatewaygroup
        } else {
            Write-Log INFO "Skipping Firewall default LAN rule gateway for primary WAN configuration."
        }

        if ($secondarywansnmprulesrcconfig -eq 1) {
            Write-Log INFO "Configuring Firewall snmp rule source for secondary WAN to $($values.mspsnmp)..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "161" -and $_.interface -eq "opt1"}).source.address = $values.mspsnmp
        } else {
            Write-Log INFO "Skipping Firewall snmp rule source for secondary WAN configuration."
        }

        if ($secondarywansnmpruledscrconfig -eq 1) {
            Write-Log INFO "Configuring Firewall snmp rule description for secondary WAN to $secondarywansnmpdscr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "161" -and $_.interface -eq "opt1"}).descr.'#cdata-section' = $secondarywansnmpdscr
        } else {
            Write-Log INFO "Skipping Firewall snmp rule description for secondary WAN configuration."
        }

        if ($secondarywanrdsruledstconfig -eq 1) {
            Write-Log INFO "Configuring RDS gateway access rule target for secondary WAN to $($values.rdsgateway)..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf76e6bc7b91.79202521"}).destination.address = $values.rdsgateway
        } else {
            Write-Log INFO "Skipping RDS gateway access rule target for secondary WAN configuration."
        }

        if ($secondarywanrdsruledscrconfig -eq 1) {
            Write-Log INFO "Configuring RDS gateway access rule description for secondary WAN to $secondarywanrdsnatdscr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf76e6bc7b91.79202521"}).descr.'#cdata-section' = $secondarywanrdsnatdscr
        } else {
            Write-Log INFO "Skipping RDS gateway access rule description for secondary WAN configuration."
        }

        if ($secondarywanfwrulesrcconfig -eq 1) {
            Write-Log INFO "Configuring RDS gateway access rule source for secondary WAN to $mspalias..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf781df0fd34.27286944"}).source.address = $mspalias
        } else {
            Write-Log INFO "Skipping RDS gateway access rule source for secondary WAN configuration."
        }

        if ($secondarywanfwruledstconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access rule target for secondary WAN to $lanipaddr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf781df0fd34.27286944"}).destination.address = $lanipaddr
        } else {
            Write-Log INFO "Skipping Firewall access rule target for secondary WAN configuration."
        }

        if ($secondarywanfwruledscrconfig -eq 1) {
            Write-Log INFO "Configuring Firewall access rule description for secondary WAN to $secondarywanfwnatdscr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.destination.port -eq "443" -and $_.interface -eq "opt1" -and $($_."associated-rule-id") -eq "nat_5caf781df0fd34.27286944"}).descr.'#cdata-section' = $secondarywanfwnatdscr
        } else {
            Write-Log INFO "Skipping Firewall access rule description for secondary WAN configuration."
        }

        if ($secondarywanpingulesrcconfig -eq 1) {
            Write-Log INFO "Configuring Firewall ping rule source for secondary WAN to $mspalias..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.protocol -eq "icmp" -and $_.interface -eq "opt1"}).source.address = $mspalias
        } else {
            Write-Log INFO "Skipping Firewall ping rule source for secondary WAN configuration."
        }

        
        if ($secondarywanpinguledscrconfig -eq 1) {
            Write-Log INFO "Configuring Firewall ping rule description for secondary WAN to $secondarywanpingdscr..."
            ($fwcfg.pfsense.filter.rule | Where-Object {$_.protocol -eq "icmp" -and $_.interface -eq "opt1"}).descr.'#cdata-section' = $secondarywanpingdscr
        } else {
            Write-Log INFO "Skipping Firewall ping rule description for secondary WAN configuration."
        }

        if ($mspaliasnameconfig -eq 1) {
            Write-Log INFO "Configuring MSP Alias name to $mspalias..."
            ($fwcfg.pfsense.aliases.alias | Where-Object {$_.type -eq "host" -and $_.descr.'#cdata-section' -eq "Firewall_WAN_Access"}).name = $mspalias
        } else {
            Write-Log INFO "Skipping MSP Alias name configuration."
        }

        if ($mspaliashostsconfig -eq 1) {
            Write-Log INFO "Configuring MSP Alias hosts to $($values.mspaliashosts)..."
            ($fwcfg.pfsense.aliases.alias | Where-Object {$_.type -eq "host" -and $_.descr.'#cdata-section' -eq "Firewall_WAN_Access"}).address = $values.mspaliashosts
        } else {
            Write-Log INFO "Skipping MSP Alias hosts configuration."
        }

        if ($mspaliashostsdetailsconfig -eq 1) {
            Write-Log INFO "Configuring MSP Alias hosts details to $($values.mspaliashostsdetails)..."
            ($fwcfg.pfsense.aliases.alias | Where-Object {$_.type -eq "host" -and $_.descr.'#cdata-section' -eq "Firewall_WAN_Access"}).detail.'#cdata-section' = $values.mspaliashostsdetails
        } else {
            Write-Log INFO "Skipping MSP Alias hosts details configuration."
        }

        if ($primarywangatewayaddrconfig -eq 1) {
            Write-Log INFO "Configuring Primary WAN gateway address to $($values.primarywangatewayaddr)..."
            ($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "wan"}).gateway = $values.primarywangatewayaddr
        } else {
            Write-Log INFO "Skipping Primary WAN gateway address configuration."
        }

        if ($primarywangatewaynameconfig -eq 1) {
            Write-Log INFO "Configuring Primary WAN gateway name to $primarywangateway..."
            ($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "wan"}).name = $primarywangateway
        } else {
            Write-Log INFO "Skipping Primary WAN gateway name configuration."
        }

        if ($primarywangatewaydscrconfig -eq 1) {
            Write-Log INFO "Configuring Primary WAN gateway description to $primarywangateway..."
            ($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "wan"}).descr.'#cdata-section' = $primarywangateway
        } else {
            Write-Log INFO "Skipping Primary WAN gateway description configuration."
        }

        if ($secondarywangatewayaddrconfig -eq 1) {
            Write-Log INFO "Configuring Secondary WAN gateway address to $($values.secondarywangatewayaddr)..."
            ($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "opt1"}).gateway = $values.secondarywangatewayaddr
        } else {
            Write-Log INFO "Skipping Secondary WAN gateway address configuration."
        }
  
        if ($secondarywangatewaynameconfig -eq 1) {
            Write-Log INFO "Configuring Secondary WAN gateway name to $secondarywangateway..."
            ($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "opt1"}).name -eq $secondarywangateway
        } else {
            Write-Log INFO "Skipping Secondary WAN gateway name configuration."
        }

        if ($secondarywangatewaydscronfig -eq 1) {
            Write-Log INFO "Configuring Secondary WAN gateway description to $secondarywangateway..."
            ($fwcfg.pfsense.gateways.gateway_item | Where-Object {$_.interface -eq "opt1"}).descr.'#cdata-section' = $secondarywangateway
        } else {
            Write-Log INFO "Skipping Secondary WAN gateway description configuration."
        }
        
        if ($defaultwangtwconfig -eq 1) {
            Write-Log INFO "Configuring gateway group to $gatewaygroup..."
            $fwcfg.pfsense.gateways.defaultgw4 = $gatewaygroup
        } else {
            Write-Log INFO "Skipping gateway group configuration."
        }

        if ($wangtwgrpnameconfig -eq 1) {
            Write-Log INFO "Configuring gateway group name to $gatewaygroup..."
            $fwcfg.pfsense.gateways.gateway_group.name = $gatewaygroup
        } else {
            Write-Log INFO "Skipping gateway group name configuration."
        }

        if ($gatewaygroupprimarywanconfig -eq 1) {
            Write-Log INFO "Configuring gateway group primary wan to $gatewaygroupprimarywan..."
            $fwcfg.pfsense.gateways.gateway_group.ChildNodes.Item(1)."#text" = $gatewaygroupprimarywan
        } else {
            Write-Log INFO "Skipping gateway group primary wan configuration."
        }
        
        if ($gatewaygroupsecondarywanconfig -eq 1) {
            Write-Log INFO "Configuring gateway group secondary wan to $gatewaygroupsecondarywan..."
            $fwcfg.pfsense.gateways.gateway_group.ChildNodes.Item(2)."#text" = $gatewaygroupsecondarywan
        } else {
            Write-Log INFO "Skipping gateway group secondary wan configuration."
        }

        if ($wangtwgrpdscrconfig -eq 1) {
            Write-Log INFO "Configuring gateway group description to $gatewaygroup..."
            $fwcfg.pfsense.gateways.gateway_group.descr.'#cdata-section' = $gatewaygroup
        } else {
            Write-Log INFO "Skipping gateway group description configuration."
        }

        $fwcfg.Save("$dir\pfsense-config.xml")
        Write-Log INFO "Job finished"
    
        
    
    } else {
        Write-Log INFO 'Configuration Cancelled'
    }     

} else {

    Write-Log INFO "No configuration changes are required"
    
}


