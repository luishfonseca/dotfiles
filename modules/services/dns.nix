{ config, options, lib, pkgs, ... }:

with lib;
let cfg = config.lhf.services.dns; in
{
  options.lhf.services.dns = {
    enable = mkEnableOption "DNS server";
    tls = {
      enable = mkEnableOption "DNS-over-TLS";
      enableACME = mkEnableOption "Whether an ACME certificate should be used";
      domain = mkOption {
        type = types.str;
        example = "ns.example.com";
        description = "Domain name to use for DNS-over-TLS";
      };
    };
    forward = mkOption {
      type = types.listOf types.str;
      description = "List of upstream DNS servers";
    };
    cache = mkOption {
      type = types.int;
      default = 0;
      description = "Cache TTL in seconds";
    };
    magicDNS = {
      enable = mkEnableOption "Magic DNS";
      domain = mkOption {
        type = types.str;
        example = "in.example.com";
        description = "Domain name to use for Magic DNS";
      };
      tailnet = mkOption {
        type = types.str;
        example = "tail9db2a.ts.net";
        description = "Tailscale's tailnet";
      };
    };
  };

  config =
    let
      escape = replaceStrings [ "." ] [ "\." ];
      acmePath = config.security.acme.certs.${cfg.tls.domain}.directory;
      corednsConfig = optionalString cfg.tls.enable ''
        tls://.:853 {
          tls ${acmePath}/fullchain.pem ${acmePath}/key.pem
          forward . 127.0.0.1
        }
      '' + optionalString cfg.magicDNS.enable ''
        ${cfg.magicDNS.domain} {
          rewrite name suffix ${cfg.magicDNS.domain} ${cfg.magicDNS.tailnet} answer auto
          forward . 100.100.100.100
        }
        100.in-addr.arpa {
          rewrite stop {
            name suffix arpa arpa
            answer name auto
            answer value (.*)\.${escape cfg.magicDNS.tailnet} {1}.${escape cfg.magicDNS.domain}
          }
          forward . 100.100.100.100
        }
      '' + ''
        . {
          forward . ${concatStringsSep " " cfg.forward}
          ${optionalString (cfg.cache != 0) "cache ${toString cfg.cache}"}
        }
      '';
    in
    mkIf cfg.enable (mkMerge [
      {
        services.coredns = {
          enable = true;
          config = corednsConfig;
        };
        networking.firewall.allowedTCPPorts = [ 53 ];
        networking.firewall.allowedUDPPorts = [ 53 ];
      }
      (mkIf cfg.tls.enable {
        networking.firewall.allowedTCPPorts = [ 853 ];
      })
      (mkIf (cfg.tls.enable && cfg.tls.enableACME) {
        security.acme.certs.${cfg.tls.domain}.webroot = "/var/lib/acme/.challenges/${cfg.tls.domain}";
        services.nginx = {
          enable = true;
          virtualHosts.${cfg.tls.domain} = {
            locations."/.well-known/acme-challenge" = {
              root = config.security.acme.certs.${cfg.tls.domain}.webroot;
              extraConfig = ''
                try_files $uri =404;
              '';
            };
          };
        };
        systemd.services.coredns.serviceConfig.Group = config.security.acme.certs.${cfg.tls.domain}.group;
      })
    ]);
}


