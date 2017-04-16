#
# Be sure to run `pod lib lint DottedProgressBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DottedProgressBar'
  s.version          = '0.1.0'
  s.summary          = 'Simple and powerful animated progress bar with dots iOS library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Simple and powerful animated progress bar with dots iOS library. Progress bar has filled circles inspired by iOS framework component UIPageControl dots.
                       DESC

  s.homepage         = 'https://github.com/nikola9core/DottedProgressBar'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nikola9core' => 'nikola9core@yahoo.com' }
  s.source           = { :git => 'https://github.com/nikola9core/DottedProgressBar.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nikola9core'

  s.ios.deployment_target = '8.3'

  s.source_files = 'DottedProgressBar/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DottedProgressBar' => ['DottedProgressBar/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
