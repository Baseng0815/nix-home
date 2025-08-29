{ lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      ${builtins.readFile ./neovim/options.lua}
      ${builtins.readFile ./neovim/lsp.lua}
      ${builtins.readFile ./neovim/keybinds.lua}
      ${builtins.readFile ./neovim/telescope.lua}
    '';
    plugins = with pkgs.vimPlugins; [
      # lsp and completion stuff
      nvim-lspconfig
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      nvim-cmp
      nvim-autopairs

      # tpope stuff
      vim-sensible
      vim-unimpaired
      vim-fugitive
      vim-surround
      vim-eunuch
      vim-repeat
      vim-commentary

      # seamless navigation between vim and tmux panes
      vim-tmux-navigator

      # snippets
      luasnip
      cmp_luasnip
      friendly-snippets

      # file browser and other navigation stuff
      nerdtree
      fzf-lua
      telescope-nvim
      telescope-ui-select-nvim
    ];
  };
}
