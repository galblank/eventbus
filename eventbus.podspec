#
#  Be sure to run `pod spec lint eventbus.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "eventbus"
  s.version      = "0.0.4"
  s.summary      = "mobile foundation framework"
  s.resources        = 'README.md'
  s.module_name      = 'mobilesdkfw'
  non_arc_files		= "mobilesdkfw/Helpers/RegexKitLite.{h,m}"
  s.preserve_paths = 'mobilesdkfw/sqlite3/module.{modulemap}'
  s.social_media_url = 'https://twitter.com/galblank'
  s.platform     = :ios, '8.1'
  s.requires_arc = true
  s.library = 'icucore','sqlite3'

  s.ios.frameworks = 'CoreFoundation','ExternalAccessory','Security'

  s.description  = "brings to provide ALL the foundational needs of any mobile applicaion"
  s.homepage     = "https://github.com/galblank/eventbus"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = { "Blank, Gal" => "galblank@gmail.com" }
  s.source       = { :git => "https://github.com/galblank/eventbus.git", :tag => "0.0.4" }
  #s.source_files  = '**/*','mobilesdkfw/**/*.{swift,info,h,m}','mobilesdkfw/**/**/*.{swift,info,h,m}'
  s.exclude_files = "**/*.{png}","**/*.{pdf}",non_arc_files
  s.default_subspec  = 'standard'
  s.subspec 'standard' do |ss|
    ss.source_files = 'mobilesdkfw/**/*.{c,h,m,swift}'
    ss.library = 'sqlite3'
    ss.preserve_paths = 'mobilesdkfw/sqlite3/**/*'
    ss.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]'         => '$(SRCROOT)/mobilesdkfw/sqlite3'
    }
end

  s.subspec 'standalone' do |ss|
    ss.source_files = 'mobilesdkfw/**/*.{c,h,m,swift}'
    ss.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DSQLITE_SWIFT_STANDALONE' }
    ss.dependency 'sqlite3'
  end

s.subspec 'no-arc' do |sp|
    sp.source_files = non_arc_files
    sp.requires_arc = false
end

end
