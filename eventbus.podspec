
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
  s.summary      = "foundation framework"
  s.resources        = 'README.md'
  s.xcconfig         = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/#{s.name}/**' }
s.social_media_url = 'https://twitter.com/galblank'
s.platform     = :ios, '8.0'
s.requires_arc = true
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

  s.platform     = :ios, "8.1"
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
  s.source_files  = "eventbus", "*.*"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"
#---------------------------------------------
# Database
#---------------------------------------------
s.subspec 'Database' do |database|
database.source_files   = 'mobilesdkfw/database/*.{h,m}'
end

#---------------------------------------------
# Networking - AFNetworking
#---------------------------------------------
s.subspec 'Networking' do |net|
net.source_files   = 'mobilesdkfw/Networking/AFNetworking/*.{h,m}', 'mobilesdkfw/Networking/UIKit+AFNetworking/*.{h,m}', 'mobilesdkfw/Networking/*.{h,m}'
end

#---------------------------------------------
# Dispatcher
#---------------------------------------------
s.subspec 'Dispatcher' do |dispatcher|
dispatcher.source_files   = 'mobilesdkfw/Dispatcher/*.{swift}'
end


#---------------------------------------------
# Crypto
#---------------------------------------------
s.subspec 'Crypto' do |crypto|
crypto.source_files   = 'mobilesdkfw/Crypto/GTM/*.{h,m}', 'mobilesdkfw/Crypto/*.{h,m}'
end

#---------------------------------------------
# Extensions
#---------------------------------------------
s.subspec 'Extensions' do |extensions|
extensions.source_files   = 'mobilesdkfw/Extensions/*.{swift}'
end

#---------------------------------------------
# Helpers
#---------------------------------------------
s.subspec 'Helpers' do |helpers|
helpers.source_files   = 'mobilesdkfw/Helpers/*.{swift}'
end

#---------------------------------------------
# Peripherials
#---------------------------------------------
s.subspec 'Peripherials' do |peripherials|
peripherials.source_files   = 'mobilesdkfw/Peripherials/Printers/*.{h,m}', 'mobilesdkfw/Peripherials/Scanners/*.{h,m}', 'mobilesdkfw/Peripherials/Swipers/*.{h,m}', 'mobilesdkfw/Peripherials/*.{swift}'
end

#---------------------------------------------
# Observables
#---------------------------------------------
s.subspec 'Observables' do |observables|
observables.source_files   = 'mobilesdkfw/Observables/*.{swift}'
end


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
