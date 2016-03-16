Pod::Spec.new do |s|
  s.name             = "GHZeusLibraries"
  s.version          = "1.0.1"
  s.homepage         = "https://github.com/ddc391565320/GHZeusLibraries"
  s.license          = 'MIT'
  s.author           = { "张冠华" => "67131930@qq.com" }
  s.source           = { :git => "https://github.com/ddc391565320/GHZeusLibraries.git", :tag => s.version }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'GHZeusLib/**/*.{h,m}'
  s.public_header_files = 'GHZeusLib/**/*.h'
  
  s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking'
  s.dependency 'FMDB'
  s.dependency 'MJExtension'
  s.dependency 'TMCache'
  s.dependency 'MBProgressHUD'
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'
  s.dependency 'MJRefresh'
  s.dependency 'FMDBMigrationManager'
  s.dependency 'AFNetworking'

end
