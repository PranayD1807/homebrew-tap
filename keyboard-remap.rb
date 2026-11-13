class KeyboardRemap < Formula
  desc "Fix PC & Windows keyboards on macOS: persistent Alt <-> Cmd layout remapping"
  homepage "https://github.com/PranayD1807/keyboard-remap"
  url "https://github.com/PranayD1807/keyboard-remap/archive/refs/tags/v0.0.2-beta.tar.gz"
  sha256 "793b0026e88847ab5a97e238e4e51c413245e8a7fccb23dd8a160e73fd36f503"
  license "MIT"
  head "https://github.com/PranayD1807/keyboard-remap.git", branch: "main"

  depends_on :macos

  def install
    system "swiftc", "-O", "src/daemon/main.swift", "-o", "keyboard-remap-daemon"
    system "swiftc", "-framework", "SwiftUI", "-framework", "AppKit",
           "-framework", "IOKit", "-O", "src/ui/main.swift", "-o", "keyboard-remap-ui"

    # Package Keyboard Remap.app in prefix
    app_contents = prefix/"Keyboard Remap.app/Contents"
    (app_contents/"MacOS").mkpath
    cp "keyboard-remap-ui", app_contents/"MacOS/Keyboard Remap"
    (app_contents/"Info.plist").write <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>CFBundleExecutable</key>
          <string>Keyboard Remap</string>
          <key>CFBundleIdentifier</key>
          <string>com.pranay.keyboard-remap-ui</string>
          <key>CFBundleName</key>
          <string>Keyboard Remap</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>CFBundleShortVersionString</key>
          <string>0.0.2-beta</string>
          <key>LSMinimumSystemVersion</key>
          <string>13.0</string>
          <key>NSHighResolutionCapable</key>
          <true/>
      </dict>
      </plist>
    EOS

    bin.install "keyboard-remap-daemon"
    bin.install "keyboard-remap-ui"
  end

  def caveats
    <<~EOS
      To start the background daemon that persists key mappings across disconnects/sleep:
        brew services start keyboard-remap

      To launch the Settings UI:
        keyboard-remap-ui
    EOS
  end

  service do
    run [opt_bin/"keyboard-remap-daemon"]
    keep_alive true
    log_path var/"log/keyboard-remap.log"
    error_log_path var/"log/keyboard-remap.err"
  end

  test do
    assert_path_exists bin/"keyboard-remap-daemon"
    assert_path_exists bin/"keyboard-remap-ui"
  end
end
