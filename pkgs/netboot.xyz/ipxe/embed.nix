{
  site,
  domain,
  version,
  ...
}:

builtins.toFile "boot.ipxe" ''
#!ipxe
set esc:hex 1b
set bold ''${esc:string}[1m
set boldoff ''${esc:string}[22m
set fg_gre ''${esc:string}[32m
set fg_cya ''${esc:string}[36m
set fg_whi ''${esc:string}[37m
set VARS_ERR Local vars file not found... attempting TFTP boot...
set TFTP_ERR Local TFTP failed... attempting remote HTTPS
set HTTPS_ERR HTTPS appears to have failed... attempting HTTP
set HTTP_ERR HTTP has failed, localbooting...
set site_name ${site}
set boot_domain ${domain}
set ipxe_version ''${version}
set version ${version}

:start
echo ''${bold}''${fg_gre}''${site_name} - ''${fg_whi}v''${version}''${boldoff}
iseq ''${site_name} netboot.xyz || echo ''${bold}''${fg_whi}Powered by ''${fg_gre}netboot.xyz''${fg_whi}''${boldoff}
prompt --key m --timeout 4000 Hit the ''${bold}m''${boldoff} key to open failsafe menu... && goto failsafe || goto dhcp

:dhcp
echo
dhcp || goto netconfig
isset ''${next-server} && iseq ''${filename} ${site}.kpxe && goto tftpmenu ||
isset ''${next-server} && iseq ''${filename} ${site}.efi && goto tftpmenu ||
goto menu

:failsafe
menu ''${boot_domain} Failsafe Menu
item localboot Boot to local drive
item netconfig Manual network configuration
item vlan Manual VLAN configuration
item retry Retry boot
item debug iPXE Debug Shell
item reboot Reboot System
choose failsafe_choice || exit
goto ''${failsafe_choice}

:netconfig
echo Network Configuration:
echo Available interfaces...
ifstat
imgfree
echo -n Set network interface number [0 for net0, defaults to 0]: ''${} && read net
isset ''${net} || set net 0
echo -n IP: && read net''${net}/ip
echo -n Subnet mask: && read net''${net}/netmask
echo -n Gateway: && read net''${net}/gateway
echo -n DNS: && read dns
ifopen net''${net}
echo Attempting chainload of ''${boot_domain}...
goto menu || goto failsafe

:vlan
echo VLAN Configuration:
echo Available interfaces...
ifstat
imgfree
echo -n Set network interface number [0 for net0, defaults to 0]: ''${} && read net
isset ''${net} || set net 0
echo -n Set VLAN 802.1Q tag [0 to 4094]: ''${} && read vlan
vcreate --tag ''${vlan} net''${net}
ifconf --configurator dhcp net''${net}-''${vlan} || echo DHCP failed trying manual && goto netvlan
echo Attempting chainload of ''${boot_domain}...
goto menu || goto failsafe

:netvlan
echo -n IP: && read net''${net}-''${vlan}/ip
echo -n Subnet mask: && read net''${net}-''${vlan}/netmask
echo -n Gateway: && read net''${net}-''${vlan}/gateway
echo -n DNS: && read dns
ifopen net''${net}-''${vlan}
echo Attempting chainload of ''${boot_domain}...
goto menu || goto failsafe

:tftpmenu
chain tftp://''${next-server}/local-vars.ipxe || echo ''${VARS_ERR}
isset ''${hostname} && chain --autofree tftp://''${next-server}/HOSTNAME-''${hostname}.ipxe || echo Custom boot by Hostname not found trying MAC...
chain --autofree tftp://''${next-server}/MAC-''${mac:hexraw}.ipxe || echo Custom boot by MAC not found booting default...
chain --autofree tftp://''${next-server}/menu.ipxe || echo ''${TFTP_ERR} && goto menu

:menu
{% if bootloader_https_enabled | bool %}
set conn_type https
chain --autofree https://''${boot_domain}/menu.ipxe || echo ''${HTTPS_ERR}
sleep 5
{% endif %}
{% if bootloader_http_enabled | bool %}
set conn_type http
chain --autofree http://''${boot_domain}/menu.ipxe || echo ''${HTTP_ERR}
{% endif %}
goto localboot

:localboot
exit

:retry
goto start

:reboot
reboot
goto start

:debug
echo Type "exit" to return to menu
shell
goto failsafe
''