class Srv < Formula
  desc "Serve the current directory over HTTP"
  homepage "https://github.com/rognlien/srv"
  license "MIT"

  if Hardware::CPU.arm?
    url "https://github.com/rognlien/srv/releases/download/v0.3.1/srv-v0.3.1-macos-arm64.tar.gz"
    sha256 "645b8858c79888844407b3c56dd551c5388726941fd89be2cebef1c9b37b35cb"
  else
    url "https://github.com/rognlien/srv/releases/download/v0.3.1/srv-v0.3.1-macos-x86_64.tar.gz"
    sha256 "b153dff892d0cd7002fa87474aaead03a2310ba9cb415cc81f78a250a365dd7d"
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
