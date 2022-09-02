#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_super_resolution.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_super_resolution'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter' 
  s.dependency 'TensorFlowLiteSwift/CoreML'
  s.dependency 'TensorFlowLiteSwift/Metal'
  # s.ios.vendored_frameworks = 'TensorFlowLiteC.framework', 'TensorFlowLiteCMetal.framework'
  # s.xcconfig = { 'OTHER_LDFLAGS' => '-framework TensorFlowLiteC -all_load -framework TensorFlowLiteCMetal -all_load', 
  #                 'FRAMEWORK_SEARCH_PATHS' => '$(PROJECT_DIR)/../Frameworks' }
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64, i386'
    }
  s.swift_version = '5.0'
  s.static_framework = true
end
