{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Önyükleyici (Bootloader) Ayarları
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;

  # Ağ ve Sistem Tanımları
  networking.hostName = "montana";
  networking.networkmanager.enable = true;

  # Zaman ve Dil Ayarları
  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "tr_TR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT    = "tr_TR.UTF-8";
    LC_MONETARY       = "tr_TR.UTF-8";
    LC_NAME           = "tr_TR.UTF-8";
    LC_NUMERIC        = "tr_TR.UTF-8";
    LC_PAPER          = "tr_TR.UTF-8";
    LC_TELEPHONE      = "tr_TR.UTF-8";
    LC_TIME           = "tr_TR.UTF-8";
  };

  console.keyMap = "trq";

  # Grafik Kartı (NVIDIA) Ayarları
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Pencere Yöneticisi (Niri)
  programs.niri.enable = true;

  # Giriş Yöneticisi (Greetd & Tuigreet) - Düzeltildi
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Ortam Değişkenleri (Wayland / NVIDIA)
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME         = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND               = "nvidia-drm";
    VK_ICD_FILENAMES          = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    NIXOS_OZONE_WL            = "1";
    QT_QPA_PLATFORM           = "wayland";
  };

  # Ses Ayarları (Pipewire) - Düzeltildi
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Oyun ve Uygulama Desteği
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  programs.gamemode.enable = true;

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.common.default = [ "gnome" "gtk" ];
  };

  services.udisks2.enable = true;

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount-system") &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };

  # Kabuk (Fish) ve Kullanıcı Tanımı
  programs.fish.enable = true;

  users.users."honey" = {
    isNormalUser = true;
    description  = "honey";
    extraGroups  = [ "networkmanager" "wheel" "video" "audio" ];
    shell        = pkgs.fish;
    packages     = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  # Sistem Paketleri
  environment.systemPackages = with pkgs; [
    alacritty
    rofi
    thunar
    udiskie
    udisks2
    playerctl
    brightnessctl
    libnotify
    flameshot
    helix
    papirus-icon-theme
    materia-theme
    mako
    swaybg
    polkit_gnome
    waybar
    xwayland-satellite
    fastfetch
    git
    protonup-qt
    wget
    unzip
    nftables
    zapret
    nvibrant
  ];

  # Yazı Tipleri
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    material-design-icons
    liberation_ttf
    unifont
  ];
  
  cursor {
    xcursor-theme "Adwaita"
    xcursor-size 24
  }

  # Zapret DPI Bypass Servisi - Düzeltildi
  systemd.services.zapret = {
    description = "DPI bypass service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.zapret}/bin/nfqws --pidfile=/run/nfqws.pid --wsize=1500 --dpi-desync=disorder --dpi-desync-ttl=0 --qnum=200";
      PIDFile = "/run/nfqws.pid";
      Restart = "always";
      Type = "simple";
    };
  };

  system.stateVersion = "26.05";
}
