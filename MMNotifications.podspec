Pod::Spec.new do |s|
  s.name         = "MMNotifications"
  s.version      = "0.1.0"
  s.summary      = "Simple in-app notifications for iOS apps."
  s.homepage     = "http://www.matmartinez.net/"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Matías Martínez" => "soy@matmartinez.net" }
  s.source       = { :git => "https://github.com/matmartinez/MMNotifications.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.framework  = 'QuartzCore'
  s.requires_arc = true
  s.source_files = 'MMNotifications/*.{h,m}', 'MMNotifications/Private/*.{h,m}'
  s.private_header_files = 'MMNotifications/Private/*.h'
 end