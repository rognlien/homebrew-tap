class Srv < Formula
  desc "Serve a directory or the output of a command over HTTP"
  homepage "https://github.com/rognlien/srv"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.5.1/srv-v0.5.1-aarch64-apple-darwin.tar.gz"
      sha256 "aa28e5f5911cd90472df5097e75c2835aa1f358170103731c52cd638baab0e7b"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.5.1/srv-v0.5.1-x86_64-apple-darwin.tar.gz"
      sha256 "b4d2778eb9415274e3f9832727aee1f15c933c26296d89fc7bc17f17fedc7cb8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rognlien/srv/releases/download/v0.5.1/srv-v0.5.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "7c24c57ac06e10784a325dee6de441a1ba93cbe6db7f187765f04aa50d8d4fd6"
    else
      url "https://github.com/rognlien/srv/releases/download/v0.5.1/srv-v0.5.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "070a0db251c37f4f29c3dfee52794e0f23f8a2ca2f966c7386a78625e287b37b"
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
