{ inputs, config, lib, ... }: let
  inherit (lib) mkOption types;

  cfg = config.hetzner-dedicated.nic;
in assert (inputs ? disko); {
  imports = [ inputs.disko.nixosModules.disko ];

  options.hetzner-dedicated.nic = {
    ipv4 = mkOption {
      description = "The IPv4 address of the main NIC";
      type = types.str;
      example = "65.108.236.230";
    };
    netmask4 = mkOption {
      description = "The IPv4 netmask of the main NIC";
      type = types.int;
      example = 26;
    };
    gateway4 = mkOption {
      description = "The IPv4 network gateway of the main NIC";
      type = types.str;
      example = "65.108.236.193";
    };
    ipv6 = mkOption {
      description = "The IPv6 address of the main NIC";
      type = types.str;
      example = "2a01:4f9:1a:b0de::2";
    };
    netmask6 = mkOption {
      description = "The IPv6 netmask of the main NIC";
      type = types.int;
      example = 64;
    };
    gateway6 = mkOption {
      description = "The IPv6 network gateway of the main NIC";
      type = types.str;
      default = "fe80::1";
    };
    mac = mkOption {
      description = "The MAC address of the main NIC";
      type = types.str;
      example = "a8:a1:59:a2:95:40";
    };
  };

  config = {
    boot = {
      initrd.availableKernelModules = [ "ahci" "nvme" "ext4" ];

      kernelModules = [ "kvm-amd" ];

      kernelParams = [ "amd_pstate.shared_mem=1 amd_pstate=passive" ];

      loader.grub = {
        copyKernels = true;
        devices = [ "/dev/disk/by-path/pci-0000:2c:00.0-nvme-1" ];
        enable = true;
        fsIdentifier = "uuid";
      };
    };

    disko.devices.disk = {
      disk0 = {
        device = "/dev/disk/by-path/pci-0000:2c:00.0-nvme-1";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "boot";
              start = "0";
              end = "1M";
              part-type = "primary";
              flags = [ "bios_grub" ];
            }
            {
              name = "root";
              start = "1M";
              end = "100%";
              fs-type = "ext4";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
          ];
        };
      };
      disk1 = {
        device = "/dev/disk/by-path/pci-0000:2d:00.0-nvme-1";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "nix";
              start = "0";
              end = "100%";
              fs-type = "ext4";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            }
          ];
        };
      };
    };

    systemd.network.links."10-main" = {
      matchConfig.PermanentMACAddress = cfg.mac;
      linkConfig.Name = "main";
    };

    networking = {
      interfaces.main = {
        ipv4.addresses = [ { address = cfg.ipv4; prefixLength = cfg.netmask4; } ];

        ipv6.addresses = [ { address = cfg.ipv6; prefixLength = cfg.netmask6; } ];
      };

      defaultGateway = cfg.gateway4;

      defaultGateway6 = {
        address = cfg.gateway6;
        interface = "main";
      };
    };

    services.openssh.enable = true;
  };
}
