{ inputs, pkgs, ... }:

let
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users."muffy" = { ... }: {
    programs.helix = {
      enable = true;
      package = unstablePkgs.steelix;

      settings = {
        theme = "monokai_pro_spectrum";
        editor.line-number = "relative";
      };
    };

    # Keep hxwiki's init.scm here too, if you want this file to own
    # all Steelix-related configuration.
      xdg.dataFile = {
        "steel/cogs/cogs/keymaps.scm".source =

    "${inputs.helix-config}/cogs/keymaps.scm";
    };
    xdg.configFile = {
      "helix/hxwiki/hxwiki.scm".source = "${inputs.hxwiki}/hxwiki.scm";

      "helix/hxwiki/hxwiki-core.scm".source = "${inputs.hxwiki}/hxwiki-core.scm";

      "helix/init.scm".text = ''
        (require "hxwiki/hxwiki.scm")
        (require "cogs/keymaps.scm")

        (set-hxwiki-root! "~/hxwiki")

        (set-hxwiki-assets-dir-name! "assets")

        ;; space w w -> open the wiki index
        ;; space w d -> open/create today's diary entry
        ;; space w p -> paste the clipboard image into the current note (Windows only for now)
        (keymap (global)
          (normal (space (w (w ":hxwiki-index") (d ":hxwiki-diary-today") (p ":hxwiki-paste-image")))))

        ;; Enter (normal mode), only in .md files, follows/creates the [[link]] under the cursor
        (define md-keybindings (deep-copy-global-keybindings))
        (merge-keybindings md-keybindings (keymap (normal (ret ":hxwiki-follow-or-create"))))
        (set-global-buffer-or-extension-keymap (hash "md" md-keybindings))
      '';
    };
  };
}
