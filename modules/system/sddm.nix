{ pkgs, ... }:

let
  sddm-astronaut = (pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";
    themeConfig = {
      # ── Background ────────────────────────────────────────────
      Background                    = "Backgrounds/katana.mp4"; # png jpg jpeg webp gif mp4 mov mkv m4v webm avi
      BackgroundPlaceholder         = "";                    # shown while video loads, relative path
      BackgroundSpeed               = "1.0";                 # 0.0–10.0, animated only
      PauseBackground               = "false";               # gif-only
      DimBackground                 = "0.0";                 # 0.0–1.0
      CropBackground                = "true";                # false = fit
      BackgroundHorizontalAlignment = "center";              # left center right (CropBackground=false only)
      BackgroundVerticalAlignment   = "center";              # top center bottom (CropBackground=false only)

      # ── General ───────────────────────────────────────────────
      ScreenWidth   = "1920";
      ScreenHeight  = "1080";
      ScreenPadding = "";
      Font          = "Jetbrains Mono Nerd font";
      FontSize      = "16";
      KeyboardSize  = "0.4";   # 0.1–1.0
      RoundCorners  = "20";
      Locale        = "";
      HourFormat    = "HH:mm";
      DateFormat    = "dddd d MMMM";
      HeaderText    = "";

      # ── Colors ────────────────────────────────────────────────
      HeaderTextColor                     = "#ffffff";
      DateTextColor                       = "#ffffff";
      TimeTextColor                       = "#ffffff";
      FormBackgroundColor                 = "#21222C";
      BackgroundColor                     = "#21222C";
      DimBackgroundColor                  = "#21222C";
      LoginFieldBackgroundColor           = "#222222";
      PasswordFieldBackgroundColor        = "#222222";
      LoginFieldTextColor                 = "#ffffff";
      PasswordFieldTextColor              = "#ffffff";
      UserIconColor                       = "#ffffff";
      PasswordIconColor                   = "#ffffff";
      PlaceholderTextColor                = "#bbbbbb";
      WarningColor                        = "#343746";
      LoginButtonTextColor                = "#ffffff";
      LoginButtonBackgroundColor          = "#343746";
      SystemButtonsIconsColor             = "#F8F8F2";
      SessionButtonTextColor              = "#F8F8F2";
      VirtualKeyboardButtonTextColor      = "#F8F8F2";
      DropdownTextColor                   = "#ffffff";
      DropdownSelectedBackgroundColor     = "#343746";
      DropdownBackgroundColor             = "#21222C";
      HighlightTextColor                  = "#bbbbbb";
      HighlightBackgroundColor            = "#343746";
      HighlightBorderColor                = "#343746";
      HoverUserIconColor                  = "#b7cef1";
      HoverPasswordIconColor              = "#b7cef1";
      HoverSystemButtonsIconsColor        = "#b7cef1";
      HoverSessionButtonTextColor         = "#b7cef1";
      HoverVirtualKeyboardButtonTextColor = "#b7cef1";

      # ── Blur / Form ───────────────────────────────────────────
      PartialBlur        = "true";  # blur behind form only
      FullBlur           = "false";  # blur entire screen
      BlurMax            = "20";     # 2–64
      Blur               = "0.6";    # 0.0–3.0
      HaveFormBackground = "false";  # false = transparent form
      FormPosition       = "left"; # left center right

      # ── Virtual Keyboard ──────────────────────────────────────
      VirtualKeyboardPosition = "center"; # left center right

      # ── Behavior ──────────────────────────────────────────────
      HideVirtualKeyboard              = "true";
      HideSystemButtons                = "true";
      HideLoginButton                  = "false";
      ForceLastUser                    = "true";
      PasswordFocus                    = "true";
      HideCompletePassword             = "true";
      AllowEmptyPassword               = "false";
      AllowUppercaseLettersInUsernames = "false"; # don't touch
      BypassSystemButtonsChecks        = "false";
      RightToLeftLayout                = "false";

      # ── Translations (optional, any string) ───────────────────
      TranslatePlaceholderUsername     = "";
      TranslatePlaceholderPassword     = "";
      TranslateLogin                   = "";
      TranslateLoginFailedWarning      = "";
      TranslateCapslockWarning         = "";
      TranslateSuspend                 = "";
      TranslateHibernate               = "";
      TranslateReboot                  = "";
      TranslateShutdown                = "";
      TranslateSessionSelection        = "";
      TranslateVirtualKeyboardButtonOn  = "";
      TranslateVirtualKeyboardButtonOff = "";
    };
  }).overrideAttrs (old: {
    installPhase = old.installPhase + ''
      chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
      cp ${./katana.mp4} $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/katana.mp4
    '';
  });
in
{
  services.displayManager.sddm = {
    enable         = true;
    wayland = {
	enable = true;
	compositor = "kwin";
    };
    theme          = "sddm-astronaut-theme";
    package        = pkgs.kdePackages.sddm;
    extraPackages  = [
      sddm-astronaut
      pkgs.kdePackages.qtmultimedia # required for video/gif backgrounds
      pkgs.adwaita-icon-theme
      pkgs.bibata-cursors
    ];
	 settings.Theme = {
    CursorTheme = "Bibata-Modern_Classic";
    CursorSize  = 24;
  };
  };

    environment.etc."sddm.conf.d/cursor.conf".text = ''
	[Theme]
	CursorTheme=Bibata-Modern-Classic
	CursorSize=24
	'';
	
    environment.sessionVariables = {
	XCURSOR_THEME = "Bibata-Modern-Classic";
	XCURSOR_SIZE = "24";
	};

    environment.systemPackages = [ sddm-astronaut pkgs.bibata-cursors ];
}
