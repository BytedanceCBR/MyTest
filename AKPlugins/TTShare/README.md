# TTShare

# 更新记录
- v0.0.1 : 分享库构建
- v0.1.0 : 修复若干bug、移除UI相关的逻辑 
- v0.1.1 : 
    1.TTShareManager所有分享调用统一Delegte出口；
    2.Email和Sms分享不支持分享类型，改遵循TTActivityContentItemProtocol协议；
- v0.1.2 :
    1.升级微信SDK到1.7.7，增加分享到小程序
    2.由于SDK去掉了原来的图片UR分享方式，所以去掉了对应的方法 
- v0.1.3 : SDK初始化采用懒加载方式
- v0.1.4 : 修改默认Title
- v0.1.5 : 手机QQ修改为QQ
- v0.2.0 : TTShareManger的Delegate增加Panel
- v0.2.1 : 合并0.1.3的功能到0.2.x
- v0.2.2 : 修改微博分享Item的入参，去掉微博140字限制，对url做最大长度处理
- v0.2.3 : TTShareManager去单例
- v0.2.4 : 合入v0.1.4功能、代码调优、添加设置全局默认分享面板能力
- v0.2.5 : TTShareManager部分实例方法改为类方法

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TTShare is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TTShare"
```

## Author

王霖, wanglin.02@bytedance.com

## License

TTShare is available under the MIT license. See the LICENSE file for more info.
