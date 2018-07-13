fenv source ~/.bashrc

# THEME PURE #
set fish_function_path ~/.config/fish/functions/theme-pure $fish_function_path

function fish_user_key_bindings.fish
  fish_vi_key_bindings
  bind -M insert -m default jj backward-char force-repaint
end

funcsave fish_user_key_bindings.fish

set fish_key_bindings fish_user_key_bindings.fish
set fish_bind_mode insert
