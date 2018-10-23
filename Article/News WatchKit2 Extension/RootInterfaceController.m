//
//  RootInterfaceController.m
//  Article
//
//  Created by yuxin on 5/26/15.
//
//

#import "RootInterfaceController.h"
#import "TTWatchItemModel.h"
#import "TTWatchFetchDataManager.h"
#import "TTWatchMacroDefine.h"

@interface RootInterfaceController ()

@end

@implementation RootInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self setTitle:@"爱看"];
    // Configure interface objects here.
    [self fetchData];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


#pragma mark 业务

- (void)fetchData
{
    [self.statusLb setText:@"努力加载中..."];
    [self.retryBtn setHidden: YES];

    [[TTWatchFetchDataManager sharedInstance] fetchDataWithCompleteBlock:^(NSData *data, NSError *error){
        if(!error){
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
        }
        
        if (error) {
            [self.statusLb setText:@"加载失败"];
            [self.retryBtn setHidden: NO];
        }
    }];
}

- (IBAction)retry:(id)sender{
    [self fetchData];
}

@end



