{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ── Bootloader ────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Ağ ───────────────────────────────────────────────────────────────────
  networking.hostName = "montana";
  networking.networkmanager.enable = true;

  # ── Saat / Dil ───────────────────────────────────────────────────────────
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

  # ── Klavye (TTY) ─────────────────────────────────────────────────────────
  # Not: Wayland/niri oturumunda klavye düzeni artık Xorg üzerinden değil,
  # ~/.config/niri/config.kdl içindeki `input { keyboard { xkb { layout "tr"; } } }`
  # bloğundan ayarlanır. Burada sadece sanal konsol (TTY) için bırakıyoruz.
  console.keyMap = "trq";

  # ── NVIDIA sürücüsü ──────────────────────────────────────────────────────
  # Xorg tamamen kapalı olsa da, çekirdek modülünün doğru yüklenmesi için
  # videoDrivers alanını "nvidia" olarak bırakıyoruz.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;   # Wayland/niri için ZORUNLU
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ── Wayland / Niri Oturumu ───────────────────────────────────────────────
  # niri paketini ve oturum dosyasını (niri-session) sisteme ekler.
  programs.niri.enable = true;

  # greetd + tuigreet: hafif, Wayland-native login manager.
  # lightdm'nin yerini bu alıyor çünkü lightdm Wayland oturumlarını
  # düzgün başlatmıyor.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # ── Ortam Değişkenleri ───────────────────────────────────────────────────
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME          = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME  = "nvidia";
    GBM_BACKEND                = "nvidia-drm";
    # Ryujinx / Ryubing için Vulkan ICD
    VK_ICD_FILENAMES           = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    # Chromium tabanlı uygulamalar (Brave, VSCode) Wayland'da native çalışsın
    NIXOS_OZONE_WL             = "1";
    # Qt uygulamaları Wayland kullansın
    QT_QPA_PLATFORM            = "wayland";
  };

  # ── Ses (PipeWire) ───────────────────────────────────────────────────────
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Steam / Oyun ─────────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  programs.gamemode.enable = true;

  # ── Flatpak (Ryubing için) ────────────────────────────────────────────────
  services.flatpak.enable = true;

  # ── XDG Portal (ekran paylaşımı, dosya seçici, Flatpak GUI vs.) ──────────
  # niri için gtk + gnome portal'ları birlikte: gnome portalı ekran
  # görüntüsü/paylaşım (screencast) desteğini sağlıyor.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.common.default = [ "gnome" "gtk" ];
  };

  # ── Disk Yönetimi / Polkit ───────────────────────────────────────────────
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

  # ── Shell ────────────────────────────────────────────────────────────────
  programs.fish.enable = true;

  # ── Kullanıcı ────────────────────────────────────────────────────────────
  users.users."honey" = {
    isNormalUser = true;
    description  = "honey";
    extraGroups  = [ "networkmanager" "wheel" "video" "audio" ];
    shell        = pkgs.fish;
    packages     = with pkgs; [];
  };

  # ── Paketler ─────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # --- Niri masaüstü (istediğin Arch paket listesinin Nix karşılıkları) ---
    alacritty
    rofi
    thunar
    udiskie
    # udisks2 zaten services.udisks2 ile geliyor, paket olarak da ekliyoruz
    udisks2
    playerctl
    brightnessctl
    libnotify
    xclip
    flameshot
    neovim
    papirus-icon-theme
    materia-theme

    # Wayland yardımcıları (bspwm'in X11 araçlarının niri karşılıkları)
    mako            # dunst'ın yerine (Wayland notification daemon)
    waybar          # polybar'ın yerine (repodaki waybar klasörü için)
    swaybg          # feh'in yerine (wallpaper)
    swaylock        # ekran kilidi
    swayidle        # otomatik kilit/uyku
    polkit_gnome    # GUI polkit ajanı (parola sorma pencereleri için)

    # "base-devel" karşılığı (derleme araçları)
    gcc
    gnumake
    binutils
    pkg-config
    gettext

    fastfetch
    git
    vscode

    brave
    spotify
    mangohud
    heroic
    protonup-qt
    eden
    prismlauncher

    wget
    wine-staging
    flightgear
    unzip
    nftables
  ];

  # ── Fontlar ──────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono   # ttf-jetbrains-mono-nerd karşılığı
    nerd-fonts.symbols-only
    material-design-icons
    liberation_ttf              # ttf-liberation karşılığı
    unifont
  ];

  systemd.services.zapret = {
    description = "DPI bypass service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/nix/store/nds7al2dh9z4110hipw92ya7wpbrx2ac-zapret-72.12/bin/nfqws --pidfile=/run/nfqws.pid --wsize=1500 --dpi-desync=disorder --dpi-desync-ttl=0 --qnum=200";
      PIDFile = "/run/nfqws.pid";
      Restart = "always";
      Type = "simple";
    };
  };

  system.stateVersion = "26.05";
}
