//
//  TTPersonalHomeSinglePlatformFollowersInfoViewModel.h
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import <Foundation/Foundation.h>
#import "TTPersonalHomeMultiplePlatformFollowersInfoViewModel.h"

@class TTPersonalHomeSinglePlatformFollowersInfoModel;

@interface TTPersonalHomeSinglePlatformFollowersInfoViewModel : NSObject

@property (nonatomic, readonly, strong) NSString *displayName;
@property (nonatomic, readonly, strong) NSString *followersCountDisplayStr;
@property (nonatomic, readonly, strong) NSString *iconURLStr;
@property (nonatomic, readonly, strong) NSURL *openURL;
@property (nonatomic, readonly, strong) NSString *appleID;
@property (nonatomic, assign) TTPersonalHomePlatformFollowersInfoViewStyle uiStyle;

- (instancetype)initWithItemModel:(TTPersonalHomeSinglePlatformFollowersInfoModel *)itemModel;

- (void)trackDownloadApp;

- (void)trackClickEventWithAction:(NSString *)action;

- (BOOL)shouldShowLaunchAppAlert;

- (void)markHasShownLaunchAppAlert;

@end
