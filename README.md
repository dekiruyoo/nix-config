# NixOS config for my PC

Personal project.

Originally, the plan was to make a config that I could apply to all my devices,
only with host specific configs that would use different drivers, kernels, etc.

As time went on, I realized using NixOS with Home-Manager and Flakes means you are
spending more time configuring Nix itself in order to have the system you want than
you are spending configuring the tools you are using directly. This abstraction
no longer satisfies me and I have decided to move on.

I'm keeping this repository in case I change my mind, so all of the work I poured
into it gets preserved, as I already managed to get to a point where my system is
somewhat useable.

I had a lot of fun setting up my configuration, every now and then, you may see
some comments which I added more for fun rather than providing anything useful. <sub>~It's
MY mental illness and I get to choose the coping mechanism~</sub>

I started using NixOS around the 2nd half of July/2026.

Desktop: GT 1030, Legacy_580 drivers, requiring the linux kernel version 6.18 or below.

Rebuild with:
```
  sudo nixos-rebuild switch --flake \.\#t1me # zsh
  sudo nixos-rebuild switch --flake .#t1me # bash
```

Only `#t1me` host is present at this point.
