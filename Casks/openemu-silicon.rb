cask "openemu-silicon" do
  version "1.0.6"
  sha256 "26be11f44b531b16b1285db59f8504e86959a85f8d106024b3544973296edccc"

  url "https://github.com/nickybmon/OpenEmu-Silicon/releases/download/v#{version}/OpenEmu-Silicon.dmg"
  name "OpenEmu Silicon"
  desc "Native Apple Silicon port of the OpenEmu multi-system emulator"
  homepage "https://github.com/nickybmon/OpenEmu-Silicon"

  depends_on macos: ">= :big_sur"

  app "OpenEmu.app"

  zap trash: [
    "~/Library/Application Support/OpenEmu",
    "~/Library/Preferences/org.openemu.OpenEmu.plist",
    "~/Library/Caches/org.openemu.OpenEmu",
  ]
end
