# deno2nix

[Nix](https://nixos.org/) support for [Deno](https://deno.land)

There are two other versions of this library that I can't get to work for various reasons so I forked it, made some modifications, and updated the readme with a working example.

## Usage

- lockfile -> `./lock.json`
- import map -> `./import_map.json`
- entrypoint -> `./mod.ts`

### Update `lock.json` for caching

```bash
deno cache --import-map=./import_map.json --lock lock.json --lock-write ./mod.ts
```

### Setup for nix flake (example)

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    deno2nix.url = "github:jcpsimmons/deno2nix";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, deno2nix, devshell, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          devshell.overlays.default
          deno2nix.overlay
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        packages = {
          default = pkgs.deno2nix.mkExecutable {
            pname = "example-executable";
            version = "0.1.2";
            src = ./.;
            lockfile = ./lock.json;
            output = "example";
            entrypoint = "./main.ts";
          };
        };
      });
}
```
