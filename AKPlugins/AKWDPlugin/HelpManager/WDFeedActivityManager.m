//
//  WDFeedActivityManager.m
//  Article
//
//  Created by 延晋 张 on 2017/8/1.
//
//

#import "WDFeedActivityManager.h"
#import "WDCommonLogic.h"
#import <TTImage/TTImageDownloader.h>
#import "WDDefines.h"

static NSString * const kActivityImagePath = @"wd_activity";

static NSString * const kActivityOpenURLKey = @"open_url";
static NSString * const kActivityStartTimeKey = @"start_time";
static NSString * const kActivityEndTimeKey = @"end_time";
static NSString * const kActivityImageUrlKey = @"image_url";
static NSString * const kActivityVersionKey = @"version";

static NSString * const kActivityDataKey = @"WDActivityDataKey";

@interface WDFeedActivityManager ()

@property (nonatomic,   copy) NSDictionary *activityData;
@property (nonatomic, strong) UIImage *image;

@end

@implementation WDFeedActivityManager

+ (instancetype)sharedInstance {
    static WDFeedActivityManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _activityData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kActivityDataKey];
        [self downloadImageIfNeededWithUrl:[self imageUrl]];
    }
    return self;
}

#pragma mark - Public Methods

- (void)refreshActivityWithDict:(NSDictionary *)dict
{
    if ([dict objectForKey:kActivityVersionKey]) {
        if ([self isDataValid:dict]) {
            [self replaceActivityDataWithDict:dict];
        }
    }
}

- (BOOL)isValidDate
{    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    return (nowTime > [self startTime]) && (nowTime < [self endTime]) && self.image && !isEmptyString([self openURL]);
}

- (BOOL)isCurrentVersionHasShown
{
    NSString *key = [NSString stringWithFormat:@"%@_Shown_%ld", kActivityDataKey, (long)[self currentVersion]];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)setCurrentVersionHasShown:(BOOL)shown
{
    NSString *key = [NSString stringWithFormat:@"%@_Shown_%ld", kActivityDataKey, (long)[self currentVersion]];
    [[NSUserDefaults standardUserDefaults] setBool:shown forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isCurrentVersionHasClosed
{
    NSString *key = [NSString stringWithFormat:@"%@_Closed_%ld", kActivityDataKey, (long)[self currentVersion]];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)setCurrentVersionHasClosed:(BOOL)closed
{
    NSString *key = [NSString stringWithFormat:@"%@_Closed_%ld", kActivityDataKey, (long)[self currentVersion]];
    [[NSUserDefaults standardUserDefaults] setBool:closed forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private Methods

- (void)replaceActivityDataWithDict:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kActivityDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)downloadImageIfNeededWithUrl:(NSString *)urlString
{
    if (isEmptyString(urlString)) {
        return;
    }
    NSString *imageDirectory = [[self class] fileDirectry];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", @([self currentVersion])]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.image = [UIImage imageWithContentsOfFile:filePath];
    } else {
        [[TTImageDownloader sharedInstance] downloadImageWithURL:urlString options:TTWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            self.image = image;
            [[NSFileManager defaultManager] removeItemAtPath:imageDirectory error:nil];
            [data writeToFile:filePath atomically:YES];
        }];
    }
    
}

#pragma mark - Util

+ (NSString *)fileDirectry
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kActivityImagePath];
}

- (BOOL)isDataValid:(NSDictionary *)data
{
    NSInteger newVersion = [[data objectForKey:kActivityVersionKey] integerValue];
    NSString *openUrl = [data tt_stringValueForKey:kActivityOpenURLKey];
    NSString *imageUrl = [data tt_stringValueForKey:kActivityImageUrlKey];
    
    if ((newVersion > [self currentVersion]) && !isEmptyString(openUrl) && !isEmptyString(imageUrl)) {
        return YES;
    }
    return NO;
}

#pragma mark - Getter

- (NSInteger)currentVersion
{
    return [[self.activityData objectForKey:kActivityVersionKey] integerValue];
}

- (NSString *)openURL
{
    return [self.activityData tt_stringValueForKey:kActivityOpenURLKey];
}

- (NSString *)imageUrl
{
    return [self.activityData tt_stringValueForKey:kActivityImageUrlKey];
}

- (NSTimeInterval)startTime
{
    return [[self.activityData objectForKey:kActivityStartTimeKey] doubleValue];
}

- (NSTimeInterval)endTime
{
    return [[self.activityData objectForKey:kActivityEndTimeKey] doubleValue];
}

@end
