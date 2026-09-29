class Srv < Formula
  desc "Serve a directory or the output of a command over HTTP"
  homepage "https://github.com/rognlien/srv"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.6.0/srv-v0.6.0-aarch64-apple-darwin.tar.gz"
      sha256 "cf4f8cc7f7576c535efcdbc197cdd7183956497bccb0685dcd59c893a614fd06"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.6.0/srv-v0.6.0-x86_64-apple-darwin.tar.gz"
      sha256 "84d491bac551b6f75d9b30d965763c2be3a75b13087756b1e650a864d0d1d670"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.6.0/srv-v0.6.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "77dab111123d75c85b78a6be27e914970b92a5acfc617be31abdc88d32cfcbac"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.6.0/srv-v0.6.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a601e161db0c7187b124de0d6968f1de91f7ca355f023adf0226280b0fd6489d"
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
    file_server = spawn bin/"srv", "-p", port.to_s, chdir: testpath
    command_port = free_port
    command_server = spawn bin/"srv", "-p", command_port.to_s, "-x", "echo", "from a command"
    sleep 1
    assert_equal "hello", shell_output("curl -s http://127.0.0.1:#{port}/hello.txt")
    assert_match "text/plain; charset=utf-8", shell_output("curl -sI http://127.0.0.1:#{port}/hello.txt")
    assert_equal "from a command\n", shell_output("curl -s http://127.0.0.1:#{command_port}/")
  ensure
    [file_server, command_server].compact.each do |pid|
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
