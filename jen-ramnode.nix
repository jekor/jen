{
  www = {
    deployment.targetEnv = "none";
    deployment.targetHost = "168.235.79.181";

    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };
}
