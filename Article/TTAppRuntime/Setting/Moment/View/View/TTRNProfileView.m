//
//  TTRNProfileView.m
//  Article
//
//  Created by Chen Hong on 16/8/7.
//
//

#import "TTRNProfileView.h"
#import "TTRNBridge+Call.h"
#import "SSUserModel.h"
#import <TTUserSettingsManager+FontSettings.h>
#import <TTAccountBusiness.h>
#import "ArticleMomentCommentModel.h"
#import "TTProfileShareService.h"
#import "ArticleMomentProfileViewController.h"
#import "TTGradientView.h"
#import "TTViewWrapper.h"
#import <CrashLytics/Answers.h>
#import "RCTRootView.h"



@interface TTRNProfileView () <TTMomentProfileProtocol>
@property(nonatomic,strong)TTRNView *rnView;
@property(nonatomic,strong)SSUserModel *userModel;
@property (nonatomic) NSTimeInterval startLoadTime;
@end

@implementation TTRNProfileView

- (id)initWithFrame:(CGRect)frame userModel:(SSUserModel *)model source:(NSString *)source refer:(NSString *)refer {
    self = [super initWithFrame:frame];
    if (self) {
        self.userModel = model;
        self.momentProfileDelegate = self;
        
        NSString *daymode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @"day" : @"night";
        NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
        BOOL isLogin =[TTAccountManager isLogin];
        NSString *currentUserID = [TTAccountManager userID];
        
        NSDictionary *modelDict = [model toDict];
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:modelDict];
        [props setValue:model.ID forKey:@"id"];
        [props setValue:daymode forKey:@"daymode"];
        [props setValue:@(isLogin) forKey:@"islogin"];
        [props setValue:fontSizeType forKey:@"font"];
        [props setValue:currentUserID forKey:@"current_id"];
        [props setValue:@(20) forKey:@"translucentHeight"];
        [props setValue:model.media_id forKey:@"media_id"];
        [props setValue:refer forKey:@"origin"];
        [props setValue:source forKey:@"source"];
        [props setValue:refer forKey:@"refer"];
        
        self.rnView = [[TTRNView alloc] initWithFrame:self.bounds];
        self.rnView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.startLoadTime = CACurrentMediaTime();
        
        [self.rnView loadModule:@"Profile" initialProperties:props];
        
        if ([TTDeviceHelper isPadDevice]) {
            TTViewWrapper *wrapperView = [TTViewWrapper viewWithFrame:self.bounds targetView:self.rnView];
            [self addSubview:wrapperView];
        }
        else {
            [self addSubview:self.rnView];
        }
        
//        TTGradientView *loading = [[TTGradientView alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
//        [self.rnView setLoadingView:loading];
        
        [self registerRNBridge];

#if RCT_DEV
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rctReload)
                                                     name:RCTJavaScriptDidLoadNotification
                                                   object:nil];
#endif
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewContentDidAppear:)
                                                     name:RCTContentDidAppearNotification
                                                   object:nil];

    }
    
    return self;
}

- (void)setRNFatalHandler:(TTRNFatalHandler)handler {
    [self.rnView setFatalHandler:handler];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rnView.frame = [self frameForRNView];
}

- (CGRect)frameForRNView {
    CGRect rect = self.bounds;
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        return CGRectInset(rect, padding, 0);
    }
    return rect;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.rnView.userInteractionEnabled = userInteractionEnabled;
}

- (void)rctReload {
    [self registerRNBridge];
}

- (void)viewContentDidAppear:(NSNotification *)notification {
    NSTimeInterval didAppear = CACurrentMediaTime();
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSNumber *loadTime = @(didAppear - self.startLoadTime);
    [dict setValue:loadTime forKey:@"loadTime"];
    [Answers logCustomEventWithName:@"profile_load" customAttributes:dict];
    [[TTMonitor shareManager] trackService:@"profile_load" value:loadTime extra:nil];
}

- (void)registerRNBridge {
    
    WeakSelf;
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSDictionary *momentDict = [result dictionaryValueForKey:@"data" defalutValue:nil];
        ArticleMomentModel *moment = [[ArticleMomentModel alloc] initWithDictionary:momentDict];
        [wself shareMoment:moment];
    } forMethod:@"update_share"];

    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSDictionary *momentDict = [result dictionaryValueForKey:@"data" defalutValue:nil];
        [wself shareProfile:momentDict];
    } forMethod:@"sharePanel"];

    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSDictionary *moment = [result tt_dictionaryValueForKey:@"moment"];
        NSString *momentID = [moment tt_stringValueForKey:@"id"];
        [wself deleteMoment:momentID];
    } forMethod:@"update_delete"];
    
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSString *commentID = [result tt_stringValueForKey:@"id"];
        [wself deleteMomentComment:commentID];
    } forMethod:@"update_comment_delete"];

    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself report:result];
    } forMethod:@"update_report"];
    
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself follow:result];
    } forMethod:@"follow"];

    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself unfollow:result];
    } forMethod:@"unfollow"];

    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSString *userID = [result tt_stringValueForKey:@"id"];
        [wself block:userID isBlock:YES];
    } forMethod:@"block_user"];
    
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSString *userID = [result tt_stringValueForKey:@"id"];
        [wself block:userID isBlock:NO];
    } forMethod:@"unblock_user"];
    
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSString *momentID = [result tt_stringValueForKey:@"id"];
        [wself updateDigg:momentID];
    } forMethod:@"update_digg"];
    
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSString *comentID = [result tt_stringValueForKey:@"comment_id"];
        [wself updateCommentDigg:comentID];
    } forMethod:@"update_comment_digg"];
    
    //调起Native评论
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSDictionary *momentDict = [result tt_dictionaryValueForKey:@"moment"];     //动态数据
        int commentIndex = [result tt_intValueForKey:@"comment_index"];   //评论数据
        [wself showCommentViewWithMoment:momentDict commentIndex:commentIndex];
    } forMethod:@"update_write_comment"];
    
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself showGallery:result];
    } forMethod:@"gallery"];
    
#pragma mark init_profile
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSDictionary *data = [wself parseUserProfileData:result];
    } forMethod:@"init_profile"];
}

#pragma mark - TTMomentProfileProtocol

- (void)didPublishComment:(NSDictionary *)commentModel momentID:(NSString *)momentID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:momentID forKey:@"id"];
    [dict setValue:commentModel forKey:@"comment"];
    [self.rnView.bridgeModule invokeJSWithEventID:@"commentPublishEvent" parameters:dict];
}

- (void)didDigUpdate:(NSString *)momentID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:momentID forKey:@"id"];
    [self.rnView.bridgeModule invokeJSWithEventID:@"updateDiggEvent" parameters:dict];
}

- (void)didDeleteUpdate:(NSString *)momentID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:momentID forKey:@"id"];
    [self.rnView.bridgeModule invokeJSWithEventID:@"updateDeleteEvent" parameters:dict];
}

- (void)didDeleteComment:(NSString *)commentID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:commentID forKey:@"comment_id"];
    [self.rnView.bridgeModule invokeJSWithEventID:@"commentDeleteEvent" parameters:dict];
}

- (void)didDeleteCommentInThread:(NSString *)threadID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:threadID forKey:@"id"];
    [self.rnView.bridgeModule invokeJSWithEventID:@"commentDeleteEvent" parameters:dict];
}

- (void)didForwardUpdate:(NSDictionary *)momentDict {
    if (![TTAccountManager isLogin]) {
        return;
    }
    
    if ([TTAccountManager userIDLongInt] != [self.userModel.ID longLongValue]) {
        return;
    }
    
    [self.rnView.bridgeModule invokeJSWithEventID:@"updateForwardEvent" parameters:momentDict];
}

- (void)didForwardUserInfo:(NSDictionary *)userInfoDict {
    if (![TTAccountManager isLogin]) {
        return;
    }
    
    if ([[TTAccountManager userID] longLongValue] != [self.userModel.ID longLongValue]) {
        return;
    }
    
    [self.rnView.bridgeModule invokeJSWithEventID:@"accountProfileEvent" parameters:userInfoDict];
}

- (void)deleteDetailUGCMovie:(NSDictionary *)dict {
    [self.rnView.bridgeModule invokeJSWithEventID:@"detail_delete_ugc_movie" parameters:dict];
}

- (void)didDeleteThread:(NSString *)threadID {
    if (isEmptyString(threadID)) {
        return;
    }
    [self.rnView.bridgeModule invokeJSWithEventID:@"updateDeleteEvent" parameters:@{@"id":threadID}];
}

@end
