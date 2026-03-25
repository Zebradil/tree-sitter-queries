{
  description = "Tree-sitter injection and highlight queries for Neovim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils }:
    {
      overlays.default = final: prev: {
        vimPlugins = prev.vimPlugins // {
          tree-sitter-queries-nvim = final.vimUtils.buildVimPlugin {
            pname = "tree-sitter-queries";
            version = "0.1.0";
            src = self;
          };
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        packages = {
          default = pkgs.vimPlugins.tree-sitter-queries-nvim;
          nvim-plugin = pkgs.vimPlugins.tree-sitter-queries-nvim;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            stylua
          ];
        };
      }
    );
}
