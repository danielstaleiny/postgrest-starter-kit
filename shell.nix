# with import <nixpkgs> {};

# stdenv.mkDerivation {
#   name = "dev-environment-psqlREST";

#   buildInputs = with pkgs;  [
#     haskellPackages.postgrest
#   ];
# }

# haskellPackages = pkgs.haskellPackages.override {
#           overrides = self: super: {
#             ghcide = self.callHackageDirect {...} {
#               haskell-lsp-types = self.haskell-lsp-types_0_19_0_0;
#             };
#             haskell-lsp-types_0_19_0_0 = (self.callHackageDirect {...} {});
#             ...
#           };
#         };



{ pkgs ? import <nixpkgs> {} }:
let
  postgrest = (import (fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/b27a19d5bf799f581a8afc2b554f178e58c1f524.tar.gz";
    sha256 = "0xl67j7ns9kzk1arr64r4lfiq74nw0awqbv6hnh8njx07rspqhdb";
  }) {}).haskellPackages.postgrest;
in
pkgs.mkShell {
  buildInputs = [ postgrest ];
  shellHook = ''
    export PATH="${postgrest}/bin:$PATH"
  '';
}
