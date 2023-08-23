#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint beauty_cam.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'beauty_cam'
  s.version          = '1.0.3'
  s.summary          = 'Beauty Camera.'
  s.description      = <<-DESC
Beauty Camera.
                       DESC
  s.homepage         = 'https://theuniversalx.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'The  Universal X' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source           ={:git => 'https://github.com/wysaid/ios-gpuimage-plus.git'}
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # v3.5.11
  s.subspec 'cge' do |sp|
    sp.vendored_frameworks = 'Libraries/*.framework'
    sp.libraries = 'z', 'stdc++'
  end
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
