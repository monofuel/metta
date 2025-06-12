let
  pkgs = import (fetchTarball {
    url = "https://nixos.org/channels/nixos-25.05/nixexprs.tar.xz";
  }) {
    config.allowUnfree = true;
  };
  # python 3.11.7 specific stuff
  flake-compat = import (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  });

  nixpkgs-python = (flake-compat {
    src = fetchTarball "https://github.com/cachix/nixpkgs-python/archive/master.tar.gz";
  }).defaultNix;

  myPython = nixpkgs-python.packages.x86_64-linux."3.11.7";
in
pkgs.mkShell {
  name = "metta-dev";

  buildInputs = with pkgs; [
    # python311 # currently 3.11.12
    myPython # 3.11.7
    uv
    cmake
    stdenv.cc.cc.lib
  ];

  # TODO having issues with `uv sync` failing on a cmake step
  shellHook = ''
    # Prevent uv from downloading its own Python
    export UV_PYTHON="${myPython}/bin/python3.11"

    # Clear PYTHONPATH to avoid conflicts
    export PYTHONPATH=""

    # Create and activate a virtual environment with uv
    uv venv
    source .venv/bin/activate

    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"

    echo "Python version: $(python --version)"
    echo "uv version: $(uv --version)"
    echo "Run 'uv sync' to install project dependencies."
  '';
}