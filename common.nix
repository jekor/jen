{pkgs, ...}:

{
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;
  security.initialRootPassword = "";
  users.extraUsers.jekor = {
    useDefaultShell = true;
    createHome = true;
    home = "/home/jekor";
    group = "users";
    extraGroups = ["wheel"];
    uid = 1001;
    openssh.authorizedKeys.keyFiles = [ (./. + "/jekor.pub") ];
  };
  users.extraUsers.root.openssh.authorizedKeys.keyFiles = [ (./. + "/jekor.pub") ];

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    passwordAuthentication = false;
  };

  environment.systemPackages = [
    pkgs.atool
    pkgs.atop
    pkgs.file
    pkgs.htop
    pkgs.iftop
    pkgs.iotop
    pkgs.links
    pkgs.lsof
    pkgs.mg
    pkgs.ncdu
    pkgs.pv
    pkgs.renameutils
    pkgs.tmux
    pkgs.tree
    pkgs.wget
  ];

  environment.etc = {
    "tmux.conf".source = ./tmux.conf;
  };
}
