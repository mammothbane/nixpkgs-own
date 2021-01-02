{
  description = "standard overlays";

  outputs = { self, ... }: with builtins;
    let
      composeExtensions = f: g: self: super:
        let fApplied = f self super;
            super' = super // fApplied;

        in fApplied // g self super';

      composeOverlays = foldl' composeExtensions (self: super: {});

    in {
      overlays = {
        gnupg = (self: super: {
          gnupg = super.gnupg.overrideAttrs (oldattrs: {
            patches = oldattrs.patches ++ [ ./patches/scdaemon-shared-access.patch ];
          });
        });
      };

      overlay = composeOverlays (attrValues self.overlays);
    };
}
