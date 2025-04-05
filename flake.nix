{
  description = "Asd darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-autoraise = {
      url = "github:Dimentium/homebrew-autoraise";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, homebrew-autoraise }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages =
        [
          pkgs.git
          pkgs.neovim
          pkgs.kitty
          pkgs.tmux
          pkgs.mkalias
          pkgs.vscodium
          pkgs.librewolf
          pkgs.tor
          pkgs.signal-desktop
        ];

      fonts.packages = [
        pkgs.fira-code
      ];

      homebrew = {
        enable = true;
        casks = [
          "the-unarchiver"
          "aerospace"
          "alt-tab"
          "dimentium/autoraise/autoraiseapp"
          "karabiner-elements"
          "docker"
        ];

        masApps = {

        };
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      power.sleep.display = 20;
      time.timeZone = "Europe/Kyiv";

      system.defaults = {
        finder.AppleShowAllExtensions = true;
        finder.AppleShowAllFiles = true;
        finder.FXEnableExtensionChangeWarning = false;
        finder.FXPreferredViewStyle = "Nlsv";
        finder.ShowPathbar = true;
        finder.ShowStatusBar = true;

        controlcenter = {
          AirDrop = false;
          Bluetooth = false;
          Display = false;
          NowPlaying = false;
          Sound = false;
          BatteryShowPercentage = true;
        };
        
        hitoolbox.AppleFnUsageType = "Do Nothing";
        NSGlobalDomain.AppleICUForce24HourTime = true;
        loginwindow.GuestEnabled = false;

        screensaver.askForPasswordDelay = 60;
        
        dock.autohide = true;
        dock.show-recents = false;
        dock.persistent-others = [];
        dock.tilesize = 64;
      };


      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "asd";

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;

            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "dimentium/homebrew-autoraise" = homebrew-autoraise;
            };
            mutableTaps = false;

          };
        }
      ];
    };
  };
}
