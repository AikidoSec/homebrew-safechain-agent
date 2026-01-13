# typed: false
# frozen_string_literal: true

class SafechainAgent < Formula
  desc "Aikido SafeChain Agent"
  homepage "https://github.com/AikidoSec/safechain-agent"
  version "0.1.0"
  license "AGPL"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/AikidoSec/safechain-internals/releases/download/v#{version}/safechain-agent-darwin-amd64"
      sha256 "30f2232e7f8013cee6ed90aad2f3f64c4adbe97839f3009f07bf78c411436fcf"

      resource "safechain-proxy" do
        url "https://github.com/AikidoSec/safechain-internals/releases/download/v#{SafechainAgent.version}/safechain-proxy-darwin-amd64"
        sha256 "b2cc381874a5ebea6c270ca2b22418c6f5a9c595d7e235ba2d912a41d4b365aa"
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/AikidoSec/safechain-internals/releases/download/v#{version}/safechain-agent-darwin-arm64"
      sha256 "7efcb2c2a60667612588fafd9329fe0b8b2eb4f7ea0881caa414ea148432ebfe"

      resource "safechain-proxy" do
        url "https://github.com/AikidoSec/safechain-internals/releases/download/v#{SafechainAgent.version}/safechain-proxy-darwin-arm64"
        sha256 "c5b5f217314fb3170a909eff5b7f138d084cf129b1c2fdd0e88ca3508e069a58"
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

    resource("safechain-proxy").stage do
      proxy_binary = "safechain-proxy-darwin-#{arch}"
      downloaded_proxy = if File.exist?(proxy_binary)
        proxy_binary
      elsif (file = Dir.glob("*").find { |f| File.file?(f) })
        file
      else
        raise "Could not find downloaded proxy binary file"
      end
      bin.install downloaded_proxy => "safechain-proxy"
      chmod 0755, bin/"safechain-proxy"
    end
  end

  def caveats
    <<~EOS
      To start the SafeChain Agent service (runs as root):
        sudo brew services start safechain-agent

      Before uninstalling, run:        
        sudo brew services stop safechain-agent
    EOS
  end

  service do
    name macos: "com.aikidosecurity.safechainagent"
    run [opt_bin/"safechain-agent"]
    run_at_load true
    keep_alive true
    require_root true
    log_path var/"log/safechain-agent.log"
    error_log_path var/"log/safechain-agent.error.log"
  end

  test do
    system "#{bin}/safechain-agent", "--version"
  end
end