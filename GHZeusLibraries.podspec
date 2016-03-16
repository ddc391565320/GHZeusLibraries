#
# Be sure to run `pod lib lint GHZeusLibraries.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GHZeusLibraries"
  s.version          = "1.0.1"
  s.summary          = "GHZeusLibraries is a library for TutorKit, LearnerKit and Other Apps."
  s.description      = <<-DESC
                       GHZeusLibraries is a library for TutorKit, LearnerKit and Other Apps.

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://www.classserver.cn/"
  s.license          = 'MIT'
  s.author           = { "张冠华" => "67131930@qq.com" }
  s.source           = { :git => "https://github.com/ddc391565320/GHZeusLibraries.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*.{h,m}'
  
  s.resource_bundles = {
    'ZeusLibraries' => ['Pod/Assets/*.png']
  }
  s.public_header_files = 'Pod/Classes/**/*.h'
  
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
