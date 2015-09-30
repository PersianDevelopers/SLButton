Pod::Spec.new do |s|
  s.name         = 'SLButton'
  s.version      = '0.0.1'
  s.summary      = 'Lightweight and simple Loading button for iOS'
  s.homepage         = "https://github.com/PersianDevelopers/SLButton"
  s.license          = 'MIT'
  s.author = {
    'Ali Pourhadi' => 'Ali.Pourhadi@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/PersianDevelopers/SLButton.git',
    :tag => s.version.to_s
  }
  s.source_files = 'SLButton/*.{h,m}'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.frameworks = 'UIKit'
end
