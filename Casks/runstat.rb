cask "runstat" do
  version "1.2.0"
  sha256 :no_check

  url "https://github.com/lukesgood/runstat/releases/download/v#{version}/runstat.app.zip"
  name "runstat"
  desc "macOS menubar system monitor - CPU usage percentage display"
  homepage "https://github.com/lukesgood/runstat"

  app "runstat.app"

  zap trash: [
    "~/Library/Preferences/com.runstat.plist",
  ]
end
