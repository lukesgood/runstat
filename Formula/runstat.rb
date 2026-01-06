class Runstat < Formula
  desc "macOS menubar system monitor - CPU usage percentage display"
  homepage "https://github.com/lukesgood/runstat"
  url "https://github.com/lukesgood/runstat.git", tag: "v1.2.1"
  license "MIT"

  depends_on xcode: :build
  depends_on :macos

  def install
    system "make", "build"
    
    # Create app bundle
    app_bundle = "#{buildpath}/runstat.app"
    (app_bundle/"Contents/MacOS").mkpath
    (app_bundle/"Contents/Resources").mkpath
    
    # Copy binary
    (app_bundle/"Contents/MacOS").install "runstat"
    
    # Create Info.plist
    (app_bundle/"Contents").install_p "runstat.app/Contents/Info.plist" if File.exist?("runstat.app/Contents/Info.plist")
    
    # Install to Applications
    prefix.install "runstat.app"
  end

  def caveats
    <<~EOS
      To complete the installation:
        1. Copy runstat.app to your Applications folder:
           cp -r "#{prefix}/runstat.app" /Applications/
        2. Launch runstat from Applications
    EOS
  end

  test do
    assert_predicate prefix/"runstat.app/Contents/MacOS/runstat", :exist?
  end
end
