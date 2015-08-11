Pod::Spec.new do |s|
  s.name         = "YapModel@alt"
  s.version      = "0.8.2.1"
  s.summary      = "YapModel is a DSL for working with YapDatabase."

  s.description  = <<-DESC
                   YapModel is a DSL for working with YapDatabase.
                   The syntax is borrowed from Ruby on Rails and inspired by ObjectiveRecord.
                   Alternative fork with more fancy add ons.
                   DESC

  s.homepage     = "https://github.com/skeeet/YapModel"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }

  s.authors             = { "Francis Chong" => "francis@ignition.hk", "Aleksei Shevchenko" => "i.am.skeeet@gmail.com" }
  
  #  When using multiple platforms
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.8'

  s.source       = { :git => "https://github.com/skeeet/YapModel.git", :tag => s.version.to_s }

  s.source_files  = 'source/**/*.{h,m}'
  s.requires_arc = true

  s.dependency 'YapDatabase/SQLCipher', '~> 2.7'
  s.dependency 'AutoCoding', '~> 2.2'
  s.dependency 'libextobjc'
end
