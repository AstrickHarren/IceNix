export ICENIX := "icenix"

update: 
  nix flake update icenix --flake $FLAKE

git-update:
  git cadn

home-manager-switch:
  home-manager switch --flake $FLAKE 

nixos-switch:
  sudo nixos-rebuild switch --flake $FLAKE

hms: update home-manager-switch
nixs: update nixos-switch
ghms: git-update update home-manager-switch
gnixs: git-update update nixos-switch
