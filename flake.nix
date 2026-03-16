# This flake sets up a Ruby development environment with Bundler and common dependencies.
# run `nix develop`

{
  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux; # Change to aarch64-linux if on ARM
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        ruby_3_4         # Choose your version: ruby_3_1, ruby_3_2, etc.
        bundler
        pkg-config
        libyaml          # Required for many gems
        openssl
        chromium
        chromedriver
        postgresql
      ];

      shellHook = ''
        # Load environment variables from .env file
        if [ -f .env ]; then
          export $(grep -v '^#' .env | xargs)
        fi

        export GEM_HOME=$PWD/.gem
        export PATH=$GEM_HOME/bin:$PATH
        export CHROME_BIN=${pkgs.chromium}/bin/chromium
        export CHROMEDRIVER_PATH=${pkgs.chromedriver}/bin/chromedriver
        export PGDATA=$PWD/.postgres/data
        export PGHOST=$PWD/.postgres/sockets
        export PGLOG=$PWD/.postgres/logfile

        # Create socket directory
        mkdir -p "$PGHOST"

        # Initialize postgres if not already done
        if [ ! -d "$PGDATA" ]; then
          echo "Initializing PostgreSQL database..."
          initdb --auth=trust --no-locale --encoding=UTF8
        fi

        # Start postgres if not already running
        if ! pg_ctl status > /dev/null 2>&1; then
          echo "Starting PostgreSQL..."
          pg_ctl -l "$PGLOG" -o "-k $PGHOST" start
        else
          echo "PostgreSQL is already running"
        fi

        echo "Ruby dev environment loaded!"
        echo "Selenium WebDriver: Chromium and ChromeDriver available"
        echo "PostgreSQL running with socket at $PGHOST"

      '';
    };
  };
}
