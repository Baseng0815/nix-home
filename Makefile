.PHONY: update home system clean
update: home system

home:
	home-manager switch --flake .#bastian

system:
	sudo nixos-rebuild switch --flake .#bastian

clean:
	nix-collect-garbage -d
