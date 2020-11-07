//
//  FHShareManager.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import <BDUGActivityContentItemProtocol.h>

typedef NS_ENUM(NSInteger, FHShareChannelType)
{
    FHShareChannelTypeWeChat,
    FHShareChannelTypeWeChatTimeline,
    FHShareChannelTypeQQFriend,
    FHShareChannelTypeQQZone,
    FHShareChannelTypeCopyLink,
};

NS_ASSUME_NONNULL_BEGIN

@interface FHShareBaseModel : NSObject
@property(nonatomic,assign) BDUGShareType shareType;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *desc;
@property(nonatomic,copy) NSString *shareUrl;
@property(nonatomic,copy) NSString *imageUrl;
@property(nonatomic,copy) UIImage *thumbImage;
@end

@interface FHShareContentModel : NSObject
@property(nonatomic,strong) FHShareBaseModel *dataModel;
@property(nonatomic,strong) NSArray *contentItemArray;
@end

@interface FHShareManager : NSObject
+ (instancetype)shareInstance;
- (NSArray *)createContentItemsWithModel:(FHShareContentModel *)model;
- (BOOL)isShareOptimization;
@end

NS_ASSUME_NONNULL_END
