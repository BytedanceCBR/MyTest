//
//  WDPublisherAdapterSetting.m
//  TTWenda
//
//  Created by 延晋 张 on 2017/10/23.
//

#import "WDPublisherAdapterSetting.h"

NSString * const KWDToutiaoImageHostArray = @"tt_image_host_address";

@implementation WDPublisherAdapterSetting

+ (instancetype)sharedInstance
{
    static WDPublisherAdapterSetting *setting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[WDPublisherAdapterSetting alloc] init];
    });
    return setting;
}

- (instancetype)init
{
    if (self = [super init]) {
        _uploadImageURL =  @"http://ib.snssdk.com/wenda/v1/upload/image/";
        _toutiaoImageHost = @"pstatp.com";
    }
    return self;
}

@end
