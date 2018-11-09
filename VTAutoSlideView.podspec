Pod::Spec.new do |s|

  s.name         = "VTAutoSlideView"
  s.version      = "0.0.5"
  s.summary      = "A Loop Scroll View"

  s.description  = <<-DESC
    A Loop Scroll View, easy to custom your own view
                   DESC

  s.homepage     = "https://github.com/VitoNYang/VTAutoSlideView"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "hao" => "740697612@qq.com" }

  s.source       = { :git => "https://github.com/VitoNYang/VTAutoSlideView.git", :tag => "#{s.version}" }
  s.platform     = :ios
  s.ios.deployment_target = '9.0'
  s.source_files = "VTAutoSlideView", "VTAutoSlideView/*{.plist,h,swift}"

end
