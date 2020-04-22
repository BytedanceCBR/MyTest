# coding: utf-8
source 'https://rubygems.byted.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'cocoapods', '1.7.4'
gem 'bd_pod_extentions', '6.3.0'
gem 'cocoapods-BDTransform', '~> 5.0'
# 修复CocoaPods和Xcode 11兼容问题
gem 'cocoapods-xcode-patch', '~> 0.1'


# CI专用的gem，本地RD不需要
if ENV['WORKSPACE']
    #临时解决CI上多进程Pod Install导致的缓存问题
    gem 'cocoapods-fix_cache', '0.3.3'
else
 # gem 'cocoapods-bytedance-monitor'
end 
