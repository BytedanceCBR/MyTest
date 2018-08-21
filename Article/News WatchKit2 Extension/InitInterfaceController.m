//
//  InitInterfaceController.m
//  Article
//
//  Created by 邱鑫玥 on 16/8/19.
//
//

#import "InitInterfaceController.h"
#import "TTWatchFetchDataManager.h"
#import "TTWatchPageManager.h"

//开屏加载的controller
//区分应用程序启动的时候加载历史数据还是从远端获取数据
@implementation InitInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self setTitle:@"爱看"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if([[TTWatchFetchDataManager sharedInstance] shouldFetchRemoteData]){
        [TTWatchPageManager loadRemoteData];
    }
    else{
        [TTWatchPageManager loadCachedData];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end
