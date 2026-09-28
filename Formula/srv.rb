class Srv < Formula
  desc "Serve the current directory over HTTP"
  homepage "https://github.com/rognlien/srv"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.4.0/srv-v0.4.0-macos-arm64.tar.gz"
      sha256 "e0de9aaaf0024c664d3aa00f9c2302408db717c5767ec10b4426c712944240a5"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.4.0/srv-v0.4.0-macos-x86_64.tar.gz"
      sha256 "79b1caf42b196573bedf5c8841ee7976cd7b2586158445bd5908cf9d2319ca95"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.4.0/srv-v0.4.0-linux-arm64.tar.gz"
      sha256 "0cf221da994abb66846d6b9acb34c05a288de2a51beaf5ae09f6118184f1eb08"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.4.0/srv-v0.4.0-linux-x86_64.tar.gz"
      sha256 "a9178a30003d9d3547549c2e8d3bce2181824a9d5a353ea98fea3c3a7d9cdc3b"
    end
  end

  def install
    bin.install "srv"
    man1.install "srv.1"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/srv --version")

    port = free_port
    (testpath/"hello.txt").write "hello"
    pid = spawn bin/"srv", port.to_s, chdir: testpath
    sleep 1
    assert_equal "hello", shell_output("curl -s http://127.0.0.1:#{port}/hello.txt")
    assert_match "text/plain; charset=utf-8", shell_output("curl -sI http://127.0.0.1:#{port}/hello.txt")
  ensure
    Process.kill("TERM", pid) if pid
    Process.wait(pid) if pid
  end
end
