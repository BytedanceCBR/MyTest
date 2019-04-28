//
//  TTVVideoDetailNatantPGCViewController.h
//  Article
//
//  Created by lishuangyang on 2017/5/24.
//
//

#import <TTUIWidget/SSViewControllerBase.h>
@class TTVVideoDetailNatantPGCViewModel;
#import "TTVVideoDetailNatantPGCModelProtocol.h"
@class TTVVideoDetailNatantPGCAuthorView;

@interface TTVVideoDetailNatantPGCModel : NSObject <TTVVideoDetailNatantPGCModelProtocol>
@property (nonatomic, strong)NSDictionary *contentInfo;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *videoSource;
@property (nonatomic, copy) NSString *userDecoration;
@property (nonatomic, copy) NSString *mediaUserID;
@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSDictionary *activityDic;//活动-关注红包
//log相关
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *groupIDStr;
@property (nonatomic, strong) NSDictionary *logPb;
@property (nonatomic, strong) void (^updateFansCountBlock)(NSNumber *fansCount);

@end

@interface TTVVideoDetailNatantPGCViewController : SSViewControllerBase

@property (nonatomic, strong)TTVVideoDetailNatantPGCAuthorView *authorView;

- (instancetype)initWithInfoModel: (TTVVideoDetailNatantPGCModel *) PGCInfo andWidth:(float) width;

@end
