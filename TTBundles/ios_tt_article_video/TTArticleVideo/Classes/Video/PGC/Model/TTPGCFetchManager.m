//
//  TTPGCFetchManager.m
//  Article
//
//  Created by 刘廷勇 on 15/11/4.
//
//

#import "TTPGCFetchManager.h"
#import <TTNetworkManager.h>
#import "TTDefaultJSONResponseSerializer.h"

static NSString *url = @"http://ic.snssdk.com/video_api/get_video_pgc/";

NSString *kVideoPGCStatusChangedNotification = @"kVideoPGCStatusChangedNotification";

@interface TTPGCFetchManager ()

@property (nonatomic, strong) TTPGCCompletion completion;

@end

@implementation TTPGCFetchManager

- (void)startFetchWithCompletion:(TTPGCCompletion)completion
{
    self.completion = completion;
    [self fetchPGCByCategoryID:nil];
}

- (void)fetchPGCByCategoryID:(NSString *)categoryID
{
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        TTVideoPGCViewModel *model = nil;
        if (!error) {
            model = [[TTVideoPGCViewModel alloc] initWithDictionary:jsonObj error:nil];
            if (!model) {
                NSDictionary *dict = [TTPGCFetchManager localPGCCache];
                model = [[TTVideoPGCViewModel alloc] initWithDictionary:dict error:nil];
            } else {
                NSDictionary *modelDict = [model toDictionary];
                [TTPGCFetchManager updateLocalPGCCache:modelDict];
            }
        } else {
            NSDictionary *dict = [TTPGCFetchManager localPGCCache];
            model = [[TTVideoPGCViewModel alloc] initWithDictionary:dict error:nil];
        }
        self.completion(model, error);
    }];
}

static NSString *kVideoPGCShouldFetch = @"kVideoPGCShouldFetch";
static NSString *kLocalVideoPGCCache = @"kLocalVideoPGCCache";

+ (BOOL)shouldShowVideoPGC
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kVideoPGCShouldFetch];
}

+ (void)setShouldShowVideoPGC:(BOOL)show
{
    BOOL old = [self shouldShowVideoPGC];
    if (show != old) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:show forKey:kVideoPGCShouldFetch];
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoPGCStatusChangedNotification object:nil userInfo:@{@"show" : @(show)}];
    }
}

+ (void)updateLocalPGCCache:(NSDictionary *)dict
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dict forKey:kLocalVideoPGCCache];
    [defaults synchronize];
}

+ (NSDictionary *)localPGCCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLocalVideoPGCCache];
}

@end
