//
//  FHShareManager.h
//  FHHouseShare
//
//  Created by bytedance on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import <BDUGActivityContentItemProtocol.h>
#import "FHReportContentItem.h"
#import "FHIMContentItem.h"
#import "FHCollectContentItem.h"

typedef NS_ENUM(NSInteger, FHShareChannelType)
{
    FHShareChannelTypeWeChat,
    FHShareChannelTypeWeChatTimeline,
    FHShareChannelTypeQQFriend,
    FHShareChannelTypeQQZone,
    FHShareChannelTypeCopyLink,
    FHShareChannelTypeReport,
    FHShareChannelTypeBlock,
    FHShareChannelTypeDislike,
    FHShareChannelTypeIM,
    FHShareChannelTypeCollect,
};

NS_ASSUME_NONNULL_BEGIN

@interface FHShareCommonDataModel : NSObject
@property(nonatomic,assign) BDUGShareType shareType;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *desc;
@property(nonatomic,copy) NSString *shareUrl;
@property(nonatomic,copy) NSString *imageUrl;
@property(nonatomic,strong) UIImage *thumbImage;
@end

@interface FHShareDataModel : NSObject
@property(nonatomic,strong) FHShareCommonDataModel *commonDataModel;
@property(nonatomic,strong) FHShareReportDataModel *reportDataModel;
@property(nonatomic,strong) FHShareIMDataModel *imDataModel;
@property(nonatomic,strong) FHShareCollectDataModel *collectDataModel;
@end

@interface FHShareContentModel : NSObject
- (instancetype)initWithDataModel:(FHShareDataModel *)dataModel contentItemArray:(NSArray *)contentItemArray;
@end

@interface FHShareManager : NSObject
+ (instancetype)shareInstance;
- (void)addCustomShareActivity;
- (void)showSharePanelWithModel:(FHShareContentModel *)model tracerDict:(NSDictionary *)tracerDict;
- (BOOL)isShareOptimization;
@end

NS_ASSUME_NONNULL_END
