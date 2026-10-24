{ inputs, pkgs, ... }:

let
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
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
  xdg.configFile."helix/init.scm".text = ''
    (require "cogs/keymaps.scm")
    (require "hxwiki/hxwiki.scm")

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
}
