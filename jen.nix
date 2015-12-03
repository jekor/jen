let
  _nixpkgs = import <nixpkgs> { };
in

{ nixpkgs ? _nixpkgs.fetchgit {
    url = "https://github.com/NixOS/nixpkgs.git";
    rev = "d53213677dc414f7c0464dd09c8530c22a4d45b6";
    sha256 = "211e649dc6dd850b8d5fff27f6645c10dc8b498a6586e2368bc7866b464d70aa";
  }
}:

let
  pkgs = if nixpkgs == null then _nixpkgs else import nixpkgs { };
in
{
  network.description = "jekor's network";

  www = {config, pkgs, ...}:
  let
    toplevel = "/www/jekor.com";
    fsrest = pkgs.haskellPackages.callPackage <fsrest> { };
    jcoreutils = pkgs.haskellPackages.callPackage <jcoreutils> { };
    jigplate = pkgs.haskellPackages.callPackage <jigplate> { };
    jsonwrench = pkgs.haskellPackages.callPackage <jsonwrench> { };
    gressgraph = pkgs.haskellPackages.callPackage <gressgraph> { };
    jekor-com = pkgs.callPackage <jekor.com> { inherit jcoreutils jigplate jsonwrench gressgraph toplevel; pandoc = pkgs.haskellPackages.pandoc; };
    minjs-com = pkgs.callPackage <minjs.com> { pygments = pkgs.pythonPackages.pygments; uglify = pkgs.nodePackages.uglify-js; };
  in {
    imports = [
      ./common.nix
      <fsrest/module.nix>
    ];

    system.fsPackages = [ pkgs.unionfs-fuse ];

    # Because of the way I designed my site (for fsrest), modifications happen
    # within the www directory. This is not possible with my site in the
    # Nix store (nor desirable), so for now I'm using a union mount to combine
    # static content (generated by Nix/Make) and user-generated content
    # (comments, etc.).
    #
    # I tried using a systemd.mount, but it didn't seem to like fuse.
    # systemd.mounts = [
    #   { description = "/www/jekor.com";
    #     what = "/var/jekor.com=rw:${jekor-com}=ro";
    #     where = toplevel;
    #     type = "unionfs-fuse";
    #     options = "cow";
    #     requiredBy = [ "fsrest.service" ];
    #   }
    # ];
    #
    # So here's a service instead.
    systemd.services.www-jekor = {
      preStart = ''
        mkdir -p /var/jekor.com
        chown wwwrun:wwwrun /var/jekor.com
        umount ${toplevel} 2>/dev/null || true
        mkdir -p ${toplevel}
      '';
      requiredBy = [ "fsrest.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.unionfs-fuse}/bin/unionfs -o cow,allow_other,uid=${toString config.ids.uids.wwwrun} /var/jekor.com=rw:${jekor-com}=ro ${toplevel}";
        RemainAfterExit = true;
        ExecStop = "${pkgs.utillinux}/bin/umount ${toplevel}";
      };
    };

    services.fsrest = {
      enable = true;
      package = fsrest;
      directory = "${toplevel}/www";
      address = "localhost";
      port = 8001;
    };

    services.nginx = {
      enable = true;
      httpConfig = ''
        gzip on;
        gzip_types text/plain text/css application/json application/javascript application/rss+xml;

        server {
          server_name jekor.com;
          location / {
            proxy_pass http://localhost:8001/;
          }
        }

        # For historical reasons, my site lives at jekor.com instead of www.jekor.com.
        # www.jekor.com -> jekor.com
        server {
          server_name www.jekor.com;
          return 301 $scheme://jekor.com$request_uri;
        }

        server {
          server_name www.minjs.com;
          location / {
            root "${minjs-com}";
          }
        }

        # minjs.com -> www.minjs.com
        server {
          server_name minjs.com;
          return 301 $scheme://www.minjs.com$request_uri;
        }
      '';
    };

    networking.firewall.allowedTCPPorts = [22 80];
  };
}
