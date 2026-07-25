# Need help? man configuration.nix 5 or run nixos-help.

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./minecarrft.nix
    ];

  # Graphics settings
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580; # Compatible with GT 1030.
  };
  
  # Use kernel compatible with GT 1030.
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Gaming.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  programs.gamemode.enable = true;

  # Enabling Flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  boot.initrd.luks.devices."luks-9e5f5584-7871-469f-88a1-91190fb31789".device = "/dev/disk/by-uuid/9e5f5584-7871-469f-88a1-91190fb31789";
  networking.hostName = "t1me"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "thinkpad";
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

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  
  # Enable Flatpak.
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "org.vinegarhq.Sober"
    #"org.prismlauncher.PrismLauncher"
    "com.heroicgameslauncher.hgl"
  ];
  #xdg.portal = {
  #  extraPortals = [ pkgs.xdg-desktop-portal-gdk ];
  #  config.common.default = "gtk";
  #};

  # Settings for the user
  users.users."muffy" = {
    isNormalUser = true;
    description = "Muffy";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      foot
      fuzzel
      discord
      fastfetch
    ];
  };
  home-manager.users."muffy" = {pkgs, ... }: {
    home.packages = with pkgs; [
      atool
      httpie
    ];
    

    programs.zsh.enable = true;

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
      extraConfig = ''
        Host github.com
        AddKeysToAgent yes
        IdentityFile ~/.ssh/id_ed25519
      '';
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
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    keepassxc
    git
    vulkan-tools
    nss
    nspr
    age
    temurin-jre-bin-21
    temurin-jre-bin-25
    appimage-run
  ];

  # sops + age config (for git authenticated requests)
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/home/muffy/.config/sops/age/keys.txt";
  sops.secrets.github_token.owner = "muffy";

  # Env vars
  environment.sessionVariables = {
    GITHUB_TOKEN = "/run/secrets/github_token";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
