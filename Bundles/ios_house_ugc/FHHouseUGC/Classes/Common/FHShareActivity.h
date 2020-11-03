//
//  FHShareActivity.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,FHShareType) {
    FHShareTypeWechat
//    FHShareTypeImage,
//    FHShareTypeImageUrl,
//    FHShareTypeWebPage,
//    FHShareTypeVideo,
};

@interface FHShareActivity : NSObject

@property(nonatomic,copy) NSString *activityTitle;
@property(nonatomic,copy) NSString *activityImageName;
@property(nonatomic,copy) NSString *activityShareUrl;
@property(nonatomic,assign) FHShareType shareType;

@end

@interface FHShareWeChatActivity: FHShareActivity
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *desc;
@property(nonatomic,copy) NSString *webPageUrl;
@property(nonatomic,strong) UIImage *thumbImage;

@end

NS_ASSUME_NONNULL_END
