# typed: false
# frozen_string_literal: true

class SafechainAgent < Formula
  desc "Aikido SafeChain Agent"
  homepage "https://github.com/AikidoSec/safechain-agent"
  version "0.2.0"
  license "AGPL"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/AikidoSec/safechain-internals/releases/download/v#{version}/safechain-agent-darwin-amd64"
      sha256 "e2fb9917b1fa0b23750c4386155b417302bd3d93b76de9de0817dd6701a3c7d9"

      resource "safechain-proxy" do
        url "https://github.com/AikidoSec/safechain-internals/releases/download/v#{SafechainAgent.version}/safechain-proxy-darwin-amd64"
        sha256 "0a14726d91afc0a5637419e75eb67e42f5d34bc557c03c84aaf253c15d9aec47"
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/AikidoSec/safechain-internals/releases/download/v#{version}/safechain-agent-darwin-arm64"
      sha256 "dc32a5ff5f57df3bd1310499cf657ef9bc4ed4f42a8bce84386ad28b4c9b46f7"

      resource "safechain-proxy" do
        url "https://github.com/AikidoSec/safechain-internals/releases/download/v#{SafechainAgent.version}/safechain-proxy-darwin-arm64"
        sha256 "b4bffda4c6336dd7dc6553b1a48ac3be4ecb2300554ed4eb112ef7a01390c61a"
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
