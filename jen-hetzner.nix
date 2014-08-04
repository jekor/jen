{
  www = {
    deployment.targetEnv = "hetzner";
    deployment.hetzner.mainIPv4 = "88.198.63.90";
    deployment.hetzner.partitions = ''
      clearpart --all --initlabel --drives=sda,sdb

      part swap --size=4096 --label=swap --fstype=swap --ondisk=sdb

      part / --fstype=ext4 --label=root --grow --ondisk=sda
    '';
  };
}
