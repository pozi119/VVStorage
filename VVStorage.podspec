#
# Be sure to run `pod lib lint VVStorage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VVStorage'
  s.version          = '0.1.1'
  s.summary          = 'A short description of VVStorage.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/pozi119/VVStorage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pozi119' => 'pozi119@163.com' }
  s.source           = { :git => 'https://github.com/pozi119/VVStorage.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  
  s.default_subspec = 'VVSequelize'
  s.subspec 'Core' do |ss|
    ss.source_files = 'VVStorage/Classes/Core/**/*'
  end
  
  s.subspec 'VVSequelize' do |ss|
    ss.source_files = 'VVStorage/Classes/VVSequelize/**/*'
    ss.dependency 'VVStorage/Core'
    ss.dependency 'VVSequelize'
  end
  
  s.subspec 'MMKV' do |ss|
    ss.source_files = 'VVStorage/Classes/MMKV/**/*'
    ss.dependency 'VVStorage/Core'
    ss.dependency 'MMKV'
  end
  
  s.subspec 'WCDB' do |ss|
    ss.source_files = 'VVStorage/Classes/WCDB/**/*'
    ss.dependency 'VVStorage/Core'
    ss.dependency 'WCDB'
  end
end
