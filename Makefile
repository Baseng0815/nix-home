.PHONY: update clean
update:
	home-manager switch --flake .#bastian

clean:
	nix-collect-garbage -d
