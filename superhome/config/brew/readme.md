`vim.rb` is just taken from the standard [homebrew formulae](https://formulae.brew.sh/formula/vim).
Specifically [here](https://github.com/Homebrew/homebrew-core/blob/29829751bce517da11c405ccf0483ae2878071aa/Formula/v/vim.rb).

It is modified to compile against python3.12 instead of 3.13, because 3.12 still has setuptools,
and I need that for vimspector to install the pydebugger gadget.

Compiled with `brew install --build-from-source ~/superhome/config/brew/vim.rb`.


