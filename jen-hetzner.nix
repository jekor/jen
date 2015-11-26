{
  www = {
    deployment.targetEnv = "hetzner";
    deployment.hetzner.mainIPv4 = "46.4.72.243";
    deployment.hetzner.partitions = ''
      clearpart --all --initlabel --drives=sda

      part / --fstype=ext4 --label=root --grow --ondisk=sda
    '';
  };
}
