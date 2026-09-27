class Srv < Formula
  desc "Serve the current directory over HTTP"
  homepage "https://github.com/rognlien/srv"
  license "MIT"

  if Hardware::CPU.arm?
    url "https://github.com/rognlien/srv/releases/download/v0.3.2/srv-v0.3.2-macos-arm64.tar.gz"
    sha256 "1f3b3806513560be832589268c88d65c5dedb4ba4b170bc0de81b16c3fb5d4e7"
  else
    url "https://github.com/rognlien/srv/releases/download/v0.3.2/srv-v0.3.2-macos-x86_64.tar.gz"
    sha256 "b1187449d781deaf860ca06a869b7cf53aaa18092f7f4cd909c0cd8eed25e3a8"
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
