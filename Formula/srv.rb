class Srv < Formula
  desc "Serve the current directory over HTTP"
  homepage "https://github.com/rognlien/srv"
  license "MIT"

  if Hardware::CPU.arm?
    url "https://github.com/rognlien/srv/releases/download/v0.3.3/srv-v0.3.3-macos-arm64.tar.gz"
    sha256 "99683af44b3f46f92e8e1e38c317b8f5e34565ada69822143d0a36f3c8845560"
  else
    url "https://github.com/rognlien/srv/releases/download/v0.3.3/srv-v0.3.3-macos-x86_64.tar.gz"
    sha256 "7fa47078516139e93fecefe2a952d72676dced90ca6e0fdc10a7b69c49138e06"
  end

  depends_on :macos

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
