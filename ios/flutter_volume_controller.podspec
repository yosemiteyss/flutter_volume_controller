#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_volume_controller.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_volume_controller'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Volume Controller'
  s.description      = <<-DESC
A Flutter plugin to control system volume and listen for volume changes on different platforms.
                       DESC
  s.homepage         = 'https://github.com/yosemiteyss/flutter_volume_controller'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'yosemiteyss' => 'kevinhonasdf@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_volume_controller/Sources/flutter_volume_controller/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
