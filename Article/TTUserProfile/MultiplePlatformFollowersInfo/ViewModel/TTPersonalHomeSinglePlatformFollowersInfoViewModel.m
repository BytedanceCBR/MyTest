//
//  TTPersonalHomeSinglePlatformFollowersInfoViewModel.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import "TTPersonalHomeSinglePlatformFollowersInfoViewModel.h"
#import "TTPersonalHomeSinglePlatformFollowersInfoModel.h"
#import <ReactiveObjC.h>
#import "TTNetworkManager.h"

static NSString *const kFollowersDetailInfoShowLaunchAppAlertKey = @"kFollowersDetailInfoShowLaunchAppAlertKey";

@interface TTPersonalHomeSinglePlatformFollowersInfoViewModel()

@property (nonatomic, strong) TTPersonalHomeSinglePlatformFollowersInfoModel *itemModel;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *followersCountDisplayStr;
@property (nonatomic, strong) NSString *iconURLStr;
@property (nonatomic, strong) NSURL *openURL;
@property (nonatomic, strong) NSString *appleID;
@property (nonatomic, strong) NSString *downloadURLStr;
@property (nonatomic, strong) NSString *appName;

@end

@implementation TTPersonalHomeSinglePlatformFollowersInfoViewModel

- (instancetype)initWithItemModel:(TTPersonalHomeSinglePlatformFollowersInfoModel *)itemModel
{
    if (self = [super init]) {
        self.itemModel = itemModel;
        
        [self bindRAC];
    }
    
    return  self;
}

- (void)bindRAC
{
    RAC(self, displayName) = RACObserve(self, itemModel.name);
    
    RAC(self, followersCountDisplayStr) = [RACObserve(self, itemModel.fansCount) map:^NSString *(NSNumber *value) {
        CGFloat tmpNumber = value.floatValue / 10000;
        
        if (tmpNumber < 1) {
            return [NSString stringWithFormat:@"%@", value];
        } else {
            NSString *tmpStr = [NSString stringWithFormat:@"%.1f", tmpNumber];
            NSRange dotRange = [tmpStr rangeOfString:@"."];
            
            if (dotRange.location != NSNotFound) {
                NSString *left = [tmpStr substringToIndex:dotRange.location];
                NSString *right = [tmpStr substringWithRange:NSMakeRange(dotRange.location + 1, 1)];
                if ([right isEqualToString:@"0"]) {
                    return [NSString stringWithFormat:@"%@万", left];
                } else {
                    return [NSString stringWithFormat:@"%@.%@万", left, right];
                }
            } else {
                return [NSString stringWithFormat:@"%.1f万", tmpNumber];
            }
        }
    }];
    
    RAC(self, iconURLStr) = RACObserve(self, itemModel.icon);
    
    RAC(self, openURL) = [RACObserve(self, itemModel.openUrl) map:^NSURL *(NSString *openUrl) {
        return [TTStringHelper URLWithURLString:openUrl];
    }];
    
    RAC(self, appleID) = RACObserve(self, itemModel.appleId);
    
    RAC(self, downloadURLStr) = RACObserve(self, itemModel.downloadUrl);
    
    RAC(self, appName) = RACObserve(self, itemModel.appName);
}

- (void)trackDownloadApp
{
    if (!isEmptyString(self.downloadURLStr)) {
        [[TTNetworkManager shareInstance] requestForJSONWithURL:self.downloadURLStr params:nil method:@"GET" needCommonParams:YES callback:nil];
    }
}

- (void)trackClickEventWithAction:(NSString *)action
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"position" : @"profile"}];
    [params setValue:self.appName forKey:@"app"];
    [params setValue:action forKey:@"action"];
    
    [TTTrackerWrapper eventV3:@"followers_click" params:params];
}

- (BOOL)shouldShowLaunchAppAlert
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kFollowersDetailInfoShowLaunchAppAlertKey];
    
    if (!dict || ![dict isKindOfClass:[NSDictionary class]] || !self.appName) {
        return YES;
    }
    
    return ![dict tt_boolValueForKey:self.appName];
}

- (void)markHasShownLaunchAppAlert
{
    NSMutableDictionary *mutDict;
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kFollowersDetailInfoShowLaunchAppAlertKey];
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        mutDict = [NSMutableDictionary dictionary];
    } else {
        mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    
    if (self.appName) {
        [mutDict setObject:@(YES) forKey:self.appName];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[mutDict copy] forKey:kFollowersDetailInfoShowLaunchAppAlertKey];
}

@end
