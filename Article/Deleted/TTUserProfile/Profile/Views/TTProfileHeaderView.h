//
//  TTProfileHeaderView.h
//  Article
//
//  Created by yuxin on 7/17/15.
//
//

#import "SSThemed.h"
#import "TTImageView.h"
#import <TTAvatarDecoratorView.h>
#import "TTProfileHeaderVisitorView.h"

@class TTNameContainerView;

@interface TTProfileHeaderView : SSThemedView
@property (nonatomic,   weak) IBOutlet SSThemedTableView *tableView;
@property (nonatomic,   weak) IBOutlet SSThemedView *loginView;
@property (nonatomic,   weak) IBOutlet SSThemedView *userInfoView;
@property (nonatomic, strong) SSThemedImageView     *backgoundImageView;
@property (nonatomic, strong, readonly) TTNameContainerView *nameContainerView;
@property (nonatomic, strong) TTAvatarDecoratorView *decorationView;
@property (nonatomic, strong) TTProfileHeaderAppFansView *appFansView;
@property (nonatomic,   weak) IBOutlet id delegate;

@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageRatio; // width:height

@property (nonatomic, strong) NSMutableArray *fansInfoArray;

/**
 * refresh content of tableViewHeader
 */
- (void)refreshUserinfo;
- (void)refreshCommonwealInfoWithTitle:(NSString *)title subTitle:(NSString *)subTitle isEnableGetMoney:(BOOL)enable;

/**
 * only refresh user's history visitor information
 */
- (void)refreshUserHistoryInfo;

#pragma mark - Account Dynamic Conf (服务端下发) Helper

+ (BOOL)isConfSupportedOfPlatform:(NSString *)platformName;

@end
