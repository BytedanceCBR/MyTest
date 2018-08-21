//
//  TTWatchPageManager.m
//
//  Created by 邱鑫玥 on 16/9/11.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "TTWatchPageManager.h"
#import "TTWatchFetchDataManager.h"
#import "TTWatchItemModel.h"
#import "TTWatchMacroDefine.h"

@implementation TTWatchPageManager

//加载历史缓存数据，目前针对complication和启动APP时候
+ (void)loadCachedData{
    NSError *error;
    NSData *data = [[TTWatchFetchDataManager sharedInstance] getStoredData];
    if(data){
        NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if(!error){
            NSArray * datas = [responseDict objectForKey:@"data"];
            
            NSMutableArray * vcAry = [@[] mutableCopy];
            NSMutableArray * modelAry = [@[] mutableCopy];
            
            for (NSDictionary * itemDict in datas) {
                TTWatchItemModel * itemModel = [[TTWatchItemModel alloc] initWithDict:itemDict];
                
                if(!isEmptyString(itemModel.title)){
                    [vcAry addObject:@"InterfaceController"];
                    [modelAry addObject:itemModel];
                }
            }
            [vcAry addObject:@"LoadMoreInterfaceController"];
            [modelAry addObject:[NSNull null]];
            
            [WKInterfaceController reloadRootControllersWithNames:vcAry contexts:modelAry];
        }
        else{
            [self loadRemoteData];
        }
    }
    else{
        [self loadRemoteData];
    }
}

+ (void)loadRemoteData{
    [WKInterfaceController reloadRootControllersWithNames:@[@"RootInterfaceController"] contexts:nil];
}

@end
