# typed: false
# frozen_string_literal: true

class SafechainAgent < Formula
  desc "Aikido SafeChain Agent"
  homepage "https://github.com/AikidoSec/safechain-agent"
  version "0.1.0"
  license "AGPL"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/AikidoSec/safechain-agent/releases/download/v#{version}/safechain-agent-darwin-amd64"
      sha256 "84d4d9bb81a5b270989c4387b7f767828034284f739d5b20c7a58e8687d11ad8"

      resource "safechain-setup" do
        url "https://github.com/AikidoSec/safechain-agent/releases/download/v#{SafechainAgent.version}/safechain-setup-darwin-amd64"
        sha256 "e4213ea724d05f784a711af18bb063a2931f922a8afc3a93dd19d918dc0845b3"
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/AikidoSec/safechain-agent/releases/download/v#{version}/safechain-agent-darwin-arm64"
      sha256 "fa6b20f5e30385fcfbd83257c34502c5608ecdc9a7abfa276e5307f84fc8eebf"

      resource "safechain-setup" do
        url "https://github.com/AikidoSec/safechain-agent/releases/download/v#{SafechainAgent.version}/safechain-setup-darwin-arm64"
        sha256 "3b754d1519c3e0bebfd39f9e1e085b13b8f505bdbe92b054a407813ffe516e66"
      end
    end
  end

  def install
    arch = Hardware::CPU.intel? ? "amd64" : "arm64"
    
    binary_name = "safechain-agent-darwin-#{arch}"
    downloaded_file = if File.exist?(binary_name)
      binary_name
    elsif (file = Dir.glob("*").find { |f| File.file?(f) && File.executable?(f) })
      file
    else
      raise "Could not find downloaded binary file"
    end
    bin.install downloaded_file => "safechain-agent"
    chmod 0755, bin/"safechain-agent"

    resource("safechain-setup").stage do
      setup_binary = "safechain-setup-darwin-#{arch}"
      downloaded_setup = if File.exist?(setup_binary)
        setup_binary
      elsif (file = Dir.glob("*").find { |f| File.file?(f) })
        file
      else
        raise "Could not find downloaded setup binary file"
      end
      bin.install downloaded_setup => "safechain-setup"
      chmod 0755, bin/"safechain-setup"
    end
  end

  def caveats
    <<~EOS
      To start the SafeChain Agent service:

        brew services start safechain-agent

      After starting the service, run the setup to configure system-level settings:

        sudo #{opt_bin}/safechain-setup

      Before uninstalling, run:
        sudo #{opt_bin}/safechain-setup --uninstall
        
        brew services stop safechain-agent
    EOS
  end

  service do
    name macos: "com.aikidosecurity.safechainagent"
    run [opt_bin/"safechain-agent"]
    run_at_load true
    keep_alive true
    log_path var/"log/safechain-agent.log"
    error_log_path var/"log/safechain-agent.error.log"
  end

  test do
    system "#{bin}/safechain-agent", "--version"
  end
end
