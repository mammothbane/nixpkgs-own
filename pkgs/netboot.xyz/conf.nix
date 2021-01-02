{
  dst,
  pciids,
  cacert,
  ...
}:


let
  boot_domain = "boot";
  site_name = "site";

in rec {
  ansible_distribution = "main";
  netbootxyz_packages = [];

  cert_dir = "${dst}/etc/certs";
  cert_file_filename = "ca-netboot-xyz.crt";
  checksums_filename = "${site_name}-sha256-checksums.txt";
  codesign_cert_filename = "codesign.crt";
  codesign_key_filename = "codesign.key";

  custom_generate_menus = false;
  custom_github_menus = true;
  custom_templates_dir = "${netbootxyz_conf_dir}/custom";
  custom_url_menus = true;

  generate_checksums = true;
  generate_disks = true;
  generate_disks_arm = false;
  generate_disks_efi = true;
  generate_disks_legacy = true;
  generate_disks_rpi = false;
  generate_menus = true;
  generate_signatures = false;
  generate_version_file = true;
  ipxe_branch = "master";
  ipxe_ca_filename = "ca-ipxe-org.crt";
  ipxe_ca_url = "file:///${cacert}";
  ipxe_repo = "${dst}/ipxe.git";
  ipxe_source_dir = "${dst}/usr/src/ipxe";
  live_endpoint = "https://github.com/netbootxyz";
  memdisk_location = "http://${boot_domain}/memdisk";
  netbootxyz_conf_dir = "${dst}/etc/netbootxyz";
  netbootxyz_root = "${dst}/var/www/html";
  pciids_url = "file:///${pciids}/pciids.ipxe";
  pipxe_branch = "master";
  pipxe_repo = "${dst}/pipxe.git";
  pipxe_source_dir = "${dst}/usr/src/pipxe";
}
