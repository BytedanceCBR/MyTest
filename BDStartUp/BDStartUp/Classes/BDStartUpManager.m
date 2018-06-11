//
//  BDStartUpManager.m
//  StartUp
//
//  Created by jialei on 2018/5/15.
//

#import "BDStartUpManager.h"
@interface BDStartUpManager()

@property (nonatomic, copy) NSArray *registerList;

@end

@implementation BDStartUpManager

static BDStartUpManager* _instance = nil;

+(instancetype) sharedInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [BDStartUpManager sharedInstance];
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [BDStartUpManager sharedInstance];
}

- (NSArray *)registerList
{
    return @[
             @"TTNetworkSettingTask",
             @"TTFabricSDKRegister",
             @"TTAppLogStartupTask",
             @"TTGetInstallIDTask",
             @"TTMonitorStartupTask",
             @"TTWeixinSDKRegister"
             ];
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [self.registerList enumerateObjectsUsingBlock:^(NSString *className, NSUInteger idx, BOOL * _Nonnull stop) {
        id instanceClass = NSClassFromString(className);
        if ([instanceClass conformsToProtocol:@protocol(BDStartUpTaskProtocol)]) {
            id<BDStartUpTaskProtocol> instance = [[instanceClass alloc] init];
            if ([instance respondsToSelector:@selector(startWithApplication:options:)]) {
                [instance startWithApplication:application options:launchOptions];
            }
        }
    }];
}

- (NSString *)valueForKey:(NSString *) key
{
    NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"BDStartUp.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *plist = [bundle pathForResource:@"StartUpSettings" ofType:@"plist"];
    NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plist];
    return plistDic[key];
}

- (NSString *)appName
{
    if (!_appName) {
        _appName = [self valueForKey:@"appName"];
    }
    return _appName;
}

- (NSString *)channel
{
    if (!_channel) {
        _channel = [self valueForKey:@"channel"];
    }
    return _channel;
}

- (NSString *)appID
{
    if (!_appID) {
        _appID = [self valueForKey:@"appID"];
    }
    return _appID;
}

- (NSString *)wxApp
{
    if (!_wxApp) {
        _wxApp = [self valueForKey:@"wxApp"];
    }
    return _wxApp;
}

-(NSString *)apiKey
{
    if (!_apiKey) {
        _apiKey = [self valueForKey:@"apiKey"];
    }
    return _apiKey;
}

@end
