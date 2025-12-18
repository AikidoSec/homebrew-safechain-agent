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
      sha256 "1cad83602fa2e72a029b38e6e20db2218be65f543f36695bbcc64080051e8a44"

      resource "safechain-setup" do
        url "https://github.com/AikidoSec/safechain-agent/releases/download/v#{SafechainAgent.version}/safechain-setup-darwin-amd64"
        sha256 "97daa3abebe3134190095f8f1367316a676faaa8ed55a620101d101a2b304f52"
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/AikidoSec/safechain-agent/releases/download/v#{version}/safechain-agent-darwin-arm64"
      sha256 "fa280e9bac20d150311e1dbf075e8922ea289ce7896e0748ea75416b74c8883f"

      resource "safechain-setup" do
        url "https://github.com/AikidoSec/safechain-agent/releases/download/v#{SafechainAgent.version}/safechain-setup-darwin-arm64"
        sha256 "047ec9dad859b12de996047ef30f30ad7e60afac5f20b3e5a6acf2ffd6d992ca"
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
