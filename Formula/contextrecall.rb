# frozen_string_literal: true

# tap
class Contextrecall < Formula
  desc 'Contextual Directory-Specific Shell History Manager'
  homepage 'https://github.com/prklm10/contextrecall'

  # 1. Define the version here. Update this when you cut a new release.
  version '0.1.0'

  # 2. Architecture and OS specific routing
  if OS.mac?
    if Hardware::CPU.intel?
      # Intel Mac
      url "https://github.com/prklm10/contextrecall/releases/download/v#{version}/contextrecall-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 'sha256:919e683116ded25b4ad372ba0ddcea8a3991a546b0ec243043487519e91ffead'
    elsif Hardware::CPU.arm?
      # Apple Silicon (M1/M2/M3) Mac
      url "https://github.com/prklm10/contextrecall/releases/download/v#{version}/contextrecall-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 'sha256:fd9fe57deedf0aa68877b504ac2085e239a7d207bbb32d172646ad02acecb741'
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      # Linux (x86_64)
      url "https://github.com/prklm10/contextrecall/releases/download/v#{version}/contextrecall-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 'sha256:23e25a25467ee3551f9bc58318fcd3269d55a9e2ba8fd37e4b0632aebd085a44'
    end
  end

  # Ensure the user has fzf installed
  depends_on 'fzf'

  def install
    bin.install 'contextrecall'
  end

  def caveats
    <<~EOS
      ContextRecall is installed! To complete the setup:

      1. Run the following command to generate your shell hook:

      mkdir -p ~/.contextrecall && cat << 'EOF' > ~/.contextrecall/init.zsh
      _contextrecall_hook() {
          local exit_code=$?
          local last_cmd=$(fc -ln -1)
          last_cmd="${last_cmd#"${last_cmd%%[![:space:]]*}"}"
          contextrecall record "$last_cmd" --exit-code "$exit_code" > /dev/null 2>&1 &!
      }
      contextrecall_search() {
          local selected_command=$(contextrecall search | fzf --height 40% --reverse --header="Context History")
          if [ -n "$selected_command" ]; then
              LBUFFER="$selected_command"
          fi
          zle reset-prompt
      }
      autoload -Uz add-zsh-hook
      add-zsh-hook precmd _contextrecall_hook
      zle -N contextrecall-history-widget contextrecall_search
      bindkey '^R' contextrecall-history-widget
      EOF

      2. Add it to your ~/.zshrc:
      echo "source ~/.contextrecall/init.zsh" >> ~/.zshrc

      3. Restart your terminal.
    EOS
  end

  test do
    system "#{bin}/contextrecall", '--help'
  end
end
