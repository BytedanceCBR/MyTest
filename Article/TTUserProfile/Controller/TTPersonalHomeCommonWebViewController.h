//
//  TTPersonalHomeCommonWebViewController.h
//  Article
//
//  Created by wangdi on 2017/3/28.
//
//

#import <UIKit/UIKit.h>
#import "ArticleMomentProfileWapView.h"
#import "TTPersonalHomeUserInfoResponseModel.h"

@interface TTPersonalHomeCommonWebViewController : UIViewController

@property (nonatomic, strong, readonly) ArticleMomentProfileWapView *webView;
@property (nonatomic, copy) void (^followBlock)(BOOL isFollow);
@property (nonatomic, copy) void (^blockUserBlock)(BOOL isBlock,NSDictionary *dict);
@property (nonatomic, assign, readonly) BOOL requestFailure;
- (void)loadRequestWithType:(NSString *)type uri:(NSString *)uri isDefault:(BOOL)isDefault;
- (void)share;
- (void)reportWithUserID:(NSString *)userID;
- (void)updateUserInfo;
- (void)setInfoModel:(TTPersonalHomeUserInfoDataResponseModel *)infoModel trackDict:(NSDictionary *)dict needAdjustInset:(BOOL)needAdjustInset;
@end
