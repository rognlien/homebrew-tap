class Srv < Formula
  desc "Serve a directory or the output of a command over HTTP"
  homepage "https://github.com/rognlien/srv"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.5.0/srv-v0.5.0-macos-arm64.tar.gz"
      sha256 "32621c3cc22e6a33bbc825484e40f9a17712a4d3bcb40a490ab17a3ab881dabf"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.5.0/srv-v0.5.0-macos-x86_64.tar.gz"
      sha256 "8669d60eec6e815180afc2340c5838a0be474875380f3f93010071952ecef3b4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.5.0/srv-v0.5.0-linux-arm64.tar.gz"
      sha256 "99aa4ec3779f9bedab34602f9697def2dffcef1fc5aefec74ba42b95a747e465"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.5.0/srv-v0.5.0-linux-x86_64.tar.gz"
      sha256 "ababd102e3b827f2b0ca5bef319b036d19247d4dd8373c36f0e6b8add9c41fdc"
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
    command_server = spawn bin/"srv", "-p", command_port.to_s, "-c", "echo", "from a command"
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
