//
//  TTVPlayerLogEvent.m
//  Article
//
//  Created by panxiang on 2017/6/4.
//
//

#import "TTVPlayerLogEvent.h"
//#import "TTLogManager.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "SSLogDataManager.h"
#import "TTVideoEngineEventManager.h"

@interface TTVPlayerLogEvent ()<TTVideoEngineEventManagerProtocol>
@property (nonatomic ,strong)TTVideoEngineEventManager *event;
@end

@implementation TTVPlayerLogEvent

+ (instancetype)sharedInstance
{
    static TTVPlayerLogEvent *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.event = [TTVideoEngineEventManager sharedManager];
        self.event.delegate = self;
    }
    return self;
}

- (void)logPreloaderData:(NSArray<NSDictionary *> *)logData
{
    for (NSDictionary *event in logData) {
        [[SSLogDataManager shareManager] appendLogData:event];
    }
}

- (void)eventManagerDidUpdate:(TTVideoEngineEventManager *)eventManager
{
    NSArray *dics = [eventManager popAllEvents];
    for (NSDictionary *dic in dics) {
        [[SSLogDataManager shareManager] appendLogData:dic];
    }
}


@end
