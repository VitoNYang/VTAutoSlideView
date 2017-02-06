Pod::Spec.new do |s|

  s.name         = "VTAutoSlideView"
  s.version      = "0.0.1"
  s.summary      = "A short description of VTAutoSlideView."

  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/VitoNYang/VTAutoSlideView"

  s.license      = "MIT"
  s.author             = { "hao" => "740697612@qq.com" }

  s.source       = { :git => "https://github.com/VitoNYang/VTAutoSlideView.git", :tag => "#{s.version}" }
  s.platform     = :ios
  s.source_files = "Classes", "Classes/**/*.swift"

end
