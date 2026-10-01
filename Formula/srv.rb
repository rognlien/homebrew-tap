class Srv < Formula
  desc "Serve a directory or the output of a command over HTTP"
  homepage "https://github.com/rognlien/srv"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.7.0/srv-v0.7.0-aarch64-apple-darwin.tar.gz"
      sha256 "ba2cd995c9357301469fab7e60e5bb7ae8491d31d191c7e8457189f345ba11da"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.7.0/srv-v0.7.0-x86_64-apple-darwin.tar.gz"
      sha256 "cf69e8edbba0b20fedb33d421547716e98eef32c4a3bcbd9d74516ff6d68ae79"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.7.0/srv-v0.7.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "2f2caddf5c8c16f95c00c3a5158e7589f97e8a709a6a14025fe370ff04525fa3"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.7.0/srv-v0.7.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "83c73d78797e102cdda88caa9b26469d00a9802ab54e15104d941fb04c87616a"
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
