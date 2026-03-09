# This flake sets up a Ruby development environment with Bundler and common dependencies.
# run `nix develop`

{
  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux; # Change to aarch64-linux if on ARM
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        ruby_4_0         # Choose your version: ruby_3_1, ruby_3_2, etc.
        bundler
        pkg-config
        libyaml          # Required for many gems
        openssl
      ];

      shellHook = ''
        export GEM_HOME=$PWD/.gem
        export PATH=$GEM_HOME/bin:$PATH
        echo "Ruby dev environment loaded!"
      '';
    };
  };
}
