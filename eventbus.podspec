
#
#  Be sure to run `pod spec lint eventbus.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "eventbus"
  s.version      = "0.0.1"
  s.summary      = "mobile foundation framework"
  s.resources        = 'README.md'
  non_arc_files		= "mobilesdkfw/Helpers/RegexKitLite.{h,m}"
  s.preserve_paths = 'mobilesdkfw/sqlite3/module.modulemap'
#s.xcconfig = {'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/mobilesdkfw/sqlite3' }
#  s.pod_target_xcconfig = {'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/mobilesdkfw/sqlite3/**'}
  s.social_media_url = 'https://twitter.com/galblank'
  s.platform     = :ios, '8.1'
  s.requires_arc = true
  s.library = 'icucore','sqlite3'
  s.ios.frameworks = 'CoreFoundation','ExternalAccessory','Security'

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = "brings to provide ALL the foundational needs of any mobile applicaion"


  s.homepage     = "https://github.com/galblank/eventbus"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = { :type => "MIT", :file => "LICENSE.txt" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "Blank, Gal" => "galblank@gmail.com" }
  # Or just: s.author    = "Blank, Gal"
  # s.authors            = { "Blank, Gal" => "galblank@gmail.com" }
  # s.social_media_url   = "http://twitter.com/galblank"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios, "8.1"
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://github.com/galblank/eventbus.git", :tag => "0.0.1" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #
  s.source_files  = '**/*','mobilesdkfw/**/*.{swift,info,h,m}'
  s.exclude_files = "**/*.{png}","**/*.{pdf}",non_arc_files

  # s.public_header_files = "Classes/**/*.h"

s.subspec 'no-arc' do |sp|
sp.source_files = non_arc_files
sp.requires_arc = false
end

end
