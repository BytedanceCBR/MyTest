//
//  TTNotePermissionGuideManager.m
//  Article
//
//  Created by liuzuopeng on 11/07/2017.
//
//

#import "TTNotePermissionGuideManager.h"
#import "TTUserSettingsManager+Notification.h"
#import "TTNotePermissionGuideFactory.h"
#import "TTNotePermissionGuideModel.h"
#import "TTPushResourceMgr.h"



@interface TTNotePermissionGuideManager (ImageMgr)

+ (void)downloadImageByURLString:(NSString *)imageURLString;

+ (BOOL)imageHasDownloaded;

@end


@interface TTNotePermissionGuideManager (StyleHelper)

+ (TTNotePermissionGuideStyle)styleForModel:(TTNotePermissionGuideModel *)model;

@end

@interface TTNotePermissionGuideManager (ModelCreation)

+ (TTNotePermissionGuideModel *)notePermissionConfigModel;

@end


@implementation TTNotePermissionGuideManager

+ (instancetype)sharedNoteManager
{
    static id sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self.class new];
    });
    return sharedInst;
}

+ (BOOL)isAPNsEnabled
{
    BOOL bEnabled = NO;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        bEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    } else {
        bEnabled = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
    }
    return bEnabled;
}

+ (BOOL)needOpenUserNotePermission
{
    return ![self.class isAPNsEnabled] && ![TTUserSettingsManager apnsNewAlertClosed];
}

+ (BOOL)canShowNotePermissionGuideDialog
{
    return [[self.class sharedNoteManager] canShowNotePermissionGuideDialog];
}

- (BOOL)canShowNotePermissionGuideDialog
{
    // 确保 系统权限为关，且客户端权限为开
    if (![self.class needOpenUserNotePermission]) {
        return NO;
    }
    
    // 确保图片已经下载
    if (![self.class imageHasDownloaded]) {
        return NO;
    }
    
    // 确保时间达到显示要求
    
    
    return YES;
}

+ (void)showNotePermissionGuideDialogIfNeeded
{
    if (![self.class canShowNotePermissionGuideDialog]) {
        return;
    }
    
    TTNotePermissionGuideModel *aModel = [self.class notePermissionConfigModel];
    if (!aModel) {
        return;
    }
    
    TTNotePermissionGuideStyle style = [self.class styleForModel:aModel];
    TTNotePermissonGuideView *guideView = [TTNotePermissionGuideFactory permissionGuideViewForStyle:style];
    guideView.dataModel = aModel;
    [guideView showWithCompletion:^{
        
    }];
}

@end



@implementation TTNotePermissionGuideManager (ABConfigTest)

static NSString * kTTLastShowNoteGuideDialogTimeIntervalKey = @"kTTLastShowNoteGuideDialogTimeIntervalKey";

+ (void)updateShowDialogTime
{
    [self.class setShowDialogTimeInterval:[NSDate date].timeIntervalSince1970];
}

+ (void)setShowDialogTimeInterval:(NSTimeInterval)tiInterval
{
    [[NSUserDefaults standardUserDefaults] setObject:@(tiInterval) forKey:kTTLastShowNoteGuideDialogTimeIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)daysFromLastShowDialog
{
    NSNumber *lastTiIntervalNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTTLastShowNoteGuideDialogTimeIntervalKey];
    if (!lastTiIntervalNumber) {
        return NSIntegerMax;
    }
    NSTimeInterval nowDateTiInterval = [NSDate date].timeIntervalSince1970;
    NSInteger days = (nowDateTiInterval - lastTiIntervalNumber.integerValue) / (24.f * 60.f * 60.f);
    return (days >= 0) ? days : NSIntegerMax;
}

static NSString * kTTNotePermissionGuideTextConfigKey = @"kTTNotePermissionGuideTextConfigKey";

+ (void)parseNoteGuideFreqControlConfig:(NSDictionary *)dict
{
    
}

+ (NSDictionary *)notePermissionGuideTextConfig
{
    NSDictionary *configDict = [[NSUserDefaults standardUserDefaults] objectForKey:kTTNotePermissionGuideTextConfigKey];
    return configDict;
}

@end



@implementation TTNotePermissionGuideManager (ImageMgr)

+ (void)downloadImageByURLString:(NSString *)imageURLString
{
    [TTPushResourceMgr downloadImageWithURLString:imageURLString completion:nil];
}

+ (BOOL)imageHasDownloaded
{
    NSDictionary *noteConfig = [self.class notePermissionGuideTextConfig];
    if (!noteConfig) return NO;
    NSString *imageURLString = noteConfig[@"image_url"];
    return [TTPushResourceMgr cachedImageExistsForURLString:imageURLString];
}

@end


@implementation TTNotePermissionGuideManager (StyleHelper)

+ (TTNotePermissionGuideStyle)styleForModel:(TTNotePermissionGuideModel *)model
{
    if ([model numberOfButtons] == 2) {
        return TTNotePermissionGuideStyle1;
    } else if ([model numberOfButtons] == 1) {
        return TTNotePermissionGuideStyle2;
    } else if (model && [model numberOfButtons] == 0) {
        model.buttonTexts = [model.class defaultStyle2ButtonText];
        return TTNotePermissionGuideStyle2;
    }
    return TTNotePermissionGuideUnsupported;
}

@end

@implementation TTNotePermissionGuideManager (ModelCreation)

+ (TTNotePermissionGuideModel *)notePermissionConfigModel
{
    TTNotePermissionGuideModel *aMdl = [TTNotePermissionGuideModel new];
    
    return aMdl;
}

@end
