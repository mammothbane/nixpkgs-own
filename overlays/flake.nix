{
  description = "standard overlays";

  outputs = { self, ... }: with builtins;
  let
    composeOverlays = foldl' pkgs.lib.composeExtensions (self: super: {});
  in {
    overlays = {
      gnupg = (self: super: {
        gnupg = super.gnupg.overrideAttrs (oldattrs: {
          patches = oldattrs.patches ++ [ ./patches/scdaemon-shared-access.patch ];
        });
      });
    };

    overlay = composeOverlays builtins.attrValues self.overlays;
  };
}
