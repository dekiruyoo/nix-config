# Need help? run either 'man configuration.nix 5' or 'nixos-help'.

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./AppImage/minecarrft.nix
    ./AppImage/wabba.nix

    ./virt.nix

    ./hosts/t1me.nix
  ];

  # Graphics settings
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Gaming.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  programs.gamemode.enable = true;

  # Enabling Flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network proxy. Keeping this for reference.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Tailscale
  services.tailscale.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable Bluetooth.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable Flatpak.
  services.flatpak = {
    enable = true;
    packages = [
      "org.vinegarhq.Sober"
      "com.heroicgameslauncher.hgl"
      "com.usebottles.bottles"
      "com.protonvpn.www"
      {
        # Gale.
        flatpakref = "https://kesomannen.com/com.kesomannen.gale.flatpakref";
        sha256 = "d17bcebe5e6845de4e8ae541ae3e91a621c2971ed799db17f34843ec27e6de04";
      }
    ];
  };

  # Settings for the user
  users.users."muffy" = {
    isNormalUser = true;
    description = "Muffy";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      foot
      fuzzel
      discord
      fastfetch
    ];
  };

  ## Home manager stuff goes here
  home-manager.users."muffy" = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [
      atool
      httpie
      obsidian
    ];

    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user = {
          name = "dekiruyoo";
          email = "remin-p@proton.me";
        };
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."github.com" = {
        AddKeysToAgent = "yes";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };

    home.stateVersion = "26.05";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    keepassxc
    git
    vulkan-tools
    nss
    nspr
    age
    mesa-demos
    temurin-jre-bin-21
    temurin-jre-bin-25
    appimage-run
    p7zip
    qbittorrent
    vlc
    mpv
    bibata-cursors
    ethtool
    go
    python3
    nixd
    nixfmt
    gofumpt
    jq
    ffmpeg
    yt-dlp
  ];

  # sops + age config (for git authenticated requests)
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/home/muffy/.config/sops/age/keys.txt";
  sops.secrets.github_token.owner = "muffy";

  # Env vars
  environment.sessionVariables = {
    GITHUB_TOKEN = "/run/secrets/github_token";
    EDITOR = "hx";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "26.05";
}
