
Pod::Spec.new do |s|
  s.name                  = "RJWebView"
  s.version               = "0.2.0"
  s.summary               = "This's a integration of WKWebView and UIWebView"
  s.description           = "This's a integration of WKWebView and UIWebView"

  s.homepage              = "https://github.com/yirenjun/RJWebView"
  s.license               = 'MIT'
  s.author                = { "yirenjun@gmail.com" => "RJWebView" }
  s.source                = { :git => "https://github.com/yirenjun/RJWebView.git", :tag => s.version.to_s }

  s.platform              = :ios, '7.0'
  s.requires_arc          = true
  
  s.source_files          = 'Pod/Classes/**/*'
  s.public_header_files   = 'Pod/Classes/**/RJ*.h'

  s.frameworks            = 'UIKit'
  s.weak_frameworks       = 'WebKit'
  s.dependency 'WebViewJavascriptBridge', '~> 4.1.5'
end
