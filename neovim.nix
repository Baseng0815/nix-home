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
    '';
    plugins = with pkgs.vimPlugins; [
      # lsp and completion stuff
      telescope-nvim
      nvim-lspconfig
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      nvim-cmp

      # seamless navigation between vim and tmux panes
      vim-tmux-navigator

      # snippets
      luasnip
      cmp_luasnip

      # file browser
      nerdtree
    ];
  };
}
