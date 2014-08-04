{
  www = {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox.memorySize = 2048;
    deployment.virtualbox.headless = true;
    deployment.virtualbox.disks = {
      boot = {
        port = 1;
        size = 20971520;
      };
    };
  };
}