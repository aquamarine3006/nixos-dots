{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name           = "aquamarine3006";
      user.email          = "pavkar02@gmail.com";
      init.defaultBranch  = "main";
      pull.rebase         = false;
    };
  };
}
