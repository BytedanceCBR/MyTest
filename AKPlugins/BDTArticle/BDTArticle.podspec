#
# Be sure to run `pod lib lint TOTArticle.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'BDTArticle'
    s.version          = '0.2.3'
    s.summary          = 'BDTArticle是一个包含Article类的pod库，方便其它pod依赖它'

    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = <<-DESC
    BDTArticle是一个包含Article类的pod库，方便其它pod依赖它。目前它依赖的pod较多，后期可以精简依赖。
    DESC

    s.homepage         = 'https://code.byted.org/TTIOS/BDTArticle'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'peiyun007' => 'peiyun@bytedance.com' }
    s.source           = { :git => 'git@code.byted.org:TTIOS/BDTArticle.git', :tag => s.version.to_s }

    s.ios.deployment_target = '7.0'

    s.source_files = 'BDTArticle/Classes/**/*'


end

