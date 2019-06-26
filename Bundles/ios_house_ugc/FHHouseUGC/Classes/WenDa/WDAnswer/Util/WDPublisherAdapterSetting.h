//
//  WDPublisherAdapterSetting.h
//  TTWenda
//
//  Created by 延晋 张 on 2017/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const KWDToutiaoImageHostArray;

@class WDRedPackStructModel;
@class TTRecordedVideo;

@protocol WDPublisherAdapterMethodDelegate <NSObject>

@optional

@end

@interface WDPublisherAdapterSetting : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *uploadImageURL;
@property (nonatomic, copy) NSString *toutiaoImageHost;

@property (nonatomic, strong) id<WDPublisherAdapterMethodDelegate> methodDelegate;


@end

NS_ASSUME_NONNULL_END
