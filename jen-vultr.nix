{
  www = {config, pkgs, ...}:
  let
    gpg = pkgs.gnupg1orig;
  in
  {
    deployment.targetEnv = "none";
    deployment.targetHost = "45.32.66.132";

    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };

    services.cron.enable = true;
    services.cron.systemCronJobs = [
      "0 0 * * * root ${pkgs.postgresql}/bin/pg_dump -U vocabulink --create vocabulink | ${gpg}/bin/gpg --keyring ${./security/backups.gpg} -e -r 'jekor@jekor.com' --trust-model always | ${pkgs.s3cmd}/bin/s3cmd --access_key ${builtins.readFile ./security/vocabulink-backup-aws-access-key} --secret_key ${builtins.readFile ./security/vocabulink-backup-aws-secret-key} put - s3://vocabulink.com-archive/sql/vocabulink--$(date --iso-8601).sql.gpg"
    ];
  };
}
