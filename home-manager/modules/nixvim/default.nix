{ lib, ... }:
{
  imports = [
    ./autoclose.nix
    ./cmp.nix
    ./conform.nix
    ./gitsigns.nix
    ./git-conflict.nix
    ./lsp.nix
    ./surround.nix
    ./telescope.nix
    ./treesitter.nix
    ./yazi.nix
  ];

  options = { };

  config = {
    programs.nixvim = {
      performance = {
        byteCompileLua.plugins = true;
      };

      diagnostics = {
        virtual_text = {
          severity.__raw = ''
            vim.diagnostic.severity.ERROR
          '';
        };
      };

      autoCmd = [
        {
          command = "wall";
          event = [ "BufLeave" ];
          pattern = [ "*" ];
        }
      ];

      keymaps =
        let
          mkKeymap =
            {
              action,
              key,
              options ? {
                silent = true;
              },
              mode ? [
                "n"
                "v"
                "i"
              ],
            }:
            {
              inherit
                action
                key
                options
                mode
                ;
            };
        in
        lib.map mkKeymap [
          {
            action = "<cmd>w<cr>";
            key = "<C-s>";
          }
          {
            action = "<cmd>vs<cr>";
            key = "<C-\\>";
          }
          {
            action = "<C-r>";
            key = "U";
            mode = [ "n" ];
          }
        ];

      opts = {
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        swapfile = false;
        signcolumn = "yes:3";
        ph = 10;
        wrap = false;
        fillchars = {
          eob = " ";
        };
        jumpoptions = "stack";
        # timeoutlen = 0;
      };
      globals.mapleader = " ";
      globals.omni_sql_no_default_maps = 1;

      plugins.yazi.enable = true;
      plugins.lsp.enable = true;
      plugins.conform-nvim.enable = true;
      plugins.autoclose.enable = true;
      plugins.gitsigns.enable = true;
      plugins.git-conflict.enable = true;
    };
  };
}
