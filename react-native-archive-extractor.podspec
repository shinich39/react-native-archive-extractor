require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-archive-extractor"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "11.0" }
  s.source       = { :git => "https://github.com/shinich39/react-native-archive-extractor.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.dependency "React-Core"
  s.dependency "SSZipArchive"
  s.dependency "UnrarKit"
  s.dependency "PLzmaSDK"
end