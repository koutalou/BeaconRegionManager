Pod::Spec.new do |s|
  s.name         = "BeaconRegionManager"
  s.version      = "0.9.1.1"
  s.summary      = "Eddystone and iBeacon(region monitoring, ranging) library for iOS"
  s.homepage     = "https://github.com/koutalou/BeaconRegionManager"
  s.license      = "MIT"
  s.author       = { "koutalou" => "k.koutalou@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/leimon/BeaconRegionManager.git", :tag => "0.9.0" }
  s.requires_arc = true
  s.source_files = "BRM", "BRM/*.{h,m}"
  s.public_header_files = "BRM/*.h"

end
