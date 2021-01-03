{
  dst,
  pciids,
  cacert,
  ...
}:

rec {
  # config
  site_name   = "nathanperry.dev";
  boot_domain = "boot.nathanperry.dev";

  custom_generate_menus = false;
  custom_github_menus = true;
  custom_templates_dir = "${netbootxyz_conf_dir}/custom";
  custom_url_menus = true;

  bootloader_tftp_enabled   = true;
  bootloader_https_enabled  = true;
  bootloader_http_enabled   = true;

  # win_base_url = "";

  generate_checksums      = true;
  generate_disks          = true;
  generate_disks_arm      = true;
  generate_disks_efi      = true;
  generate_disks_legacy   = true;
  generate_disks_rpi      = true;
  generate_menus          = true;
  generate_signatures     = false;
  generate_version_file   = true;

  # static
  cert_dir = "${dst}/etc/certs";
  cert_file_filename = "ca-netboot-xyz.crt";
  checksums_filename = "${site_name}-sha256-checksums.txt";
  codesign_cert_filename = "codesign.crt";
  codesign_key_filename = "codesign.key";

  ipxe_branch = "master";
  ipxe_ca_filename = "ca-ipxe-org.crt";
  ipxe_ca_url = "file:///${cacert}";
  ipxe_repo = "${dst}/ipxe.git";
  ipxe_source_dir = "${dst}/usr/src/ipxe";
  live_endpoint = "https://github.com/netbootxyz";

  memdisk_location = "http://${boot_domain}/memdisk";

  netbootxyz_conf_dir = "${dst}/etc/netbootxyz";
  netbootxyz_root = "${dst}/var/www/html";
  netbootxyz_packages = [];

  pciids_url = "file:///${pciids}/pciids.ipxe";

  pipxe_branch = "master";
  pipxe_repo = "${dst}/pipxe.git";
  pipxe_source_dir = "${dst}/usr/src/pipxe";

  ansible_distribution = "main";
}
