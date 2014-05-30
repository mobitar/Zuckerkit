Pod::Spec.new do |s|
  s.name         = "Zuckerkit"
  s.version      = "0.1.0"
  s.summary      = "A wrapper around the Facebook SDK that makes common tasks easy."
  s.homepage     = "https://github.com/mobitar/Zuckerkit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = 'Mo Bitar'
  s.source       = { :git => "https://github.com/mobitar/Zuckerkit.git", :tag => s.version.to_s }
  s.platform     = :ios, '6.0'
  s.source_files = 'Zuckerkit'
  s.requires_arc = true
  s.dependency 'Facebook-iOS-SDK', '~> 3.11.0'
end
