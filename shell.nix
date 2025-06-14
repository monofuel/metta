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
    python311 # currently 3.11.12
    #myPython # 3.11.7
    uv
    cmake
    zstd
    stdenv.cc.cc.lib

    # for mettascope
    nodejs_24
    typescript
  ];


# Currently stuck on an error, probably some nvidia specific thing that isn't matching up on amd:
# Error in call to target 'metta.rl.pufferlib.trainer.PufferTrainer':
# AcceleratorError('HIP error: invalid device function\nHIP kernel errors might be asynchronously reported at some other API call, so the stacktrace below might be incorrect.\nFor debugging consider passing AMD_SERIALIZE_KERNEL=3\nCompile with `TORCH_USE_HIP_DSA` to enable device-side assertions.\n')
# full_key: trainer

  shellHook = ''
    # Prevent uv from downloading its own Python
    # export UV_PYTHON="${myPython}/bin/python3.11"

    # Clear PYTHONPATH to avoid conflicts
    # export PYTHONPATH=""

    # make cmake work
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH=${pkgs.zstd.out}/lib:$LD_LIBRARY_PATH

    # Create and activate a virtual environment with uv
    # uv sync
    # source .venv/bin/activate


    echo "Python version: $(python --version)"
    echo "uv version: $(uv --version)"
    echo "Run 'uv sync' to install project dependencies."
    echo "Run source .venv/bin/activate after uv sync" 
  '';
}