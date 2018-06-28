#
# Be sure to run `pod lib lint ETBluetoothPrinterManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ETBluetoothPrinterManager'
  s.version          = '0.1.0'
  s.summary          = 'A library for Bluetooth Peripherals connecting to print.It‘s very easy to use!!!'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A library for Bluetooth Peripherals connecting to print.You can get the recent connected peripheral, judge where bluetooth is available and etc. It‘s very easy to use!!!
                       DESC

  s.homepage         = 'https://github.com/ElegantTeam/ETBluetoothPrinterManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'VolleyZ' => '552408690@qq.com' }
  s.source           = { :git => 'https://github.com/ElegantTeam/ETBluetoothPrinterManager.git', :tag => "0.1.0" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ETBluetoothPrinterManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ETBluetoothPrinterManager' => ['ETBluetoothPrinterManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MBProgressHUD'
end
