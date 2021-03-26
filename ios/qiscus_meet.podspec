#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint qiscus_meet.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'qiscus_meet'
  s.version          = '0.0.1'
  s.summary          = 'Qiscus Meet iOS SDK'
  s.description      = <<-DESC
Qiscus Meet is a WebRTC compatible, free and Open Source video conferencing system that provides browsers and mobile applications with Real Time Communications capabilities.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'Qiscus' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'QiscusMeetFramework', '3.2.0'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
   s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
   s.swift_version = '5.0'
 end
