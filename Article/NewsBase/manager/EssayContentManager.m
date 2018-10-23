//
//  EssayContentManager.m
//  Article
//
//  Created by Hua Cao on 13-10-22.
//
//

#import "EssayContentManager.h"
#import "TTNetworkManager.h"
#import "ArticleURLSetting.h"

@interface EssayContentManager ()

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@property (nonatomic, retain) NSString * essayGroupID;

@end

@implementation EssayContentManager

- (void)tryLoadContentWithEssayGroupID:(NSString *)essayGroupID {
    [self loadContentWithEssayGroupID:essayGroupID];
}

- (void)loadContentWithEssayGroupID:(NSString *)essayGroupID {
    if (essayGroupID==nil ||
        [essayGroupID isEqual:[NSNull null]]) {
        return;
    }
    
    if (self.isLoading) return;
    self.loading = YES;
    
    self.essayGroupID = essayGroupID;
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting essayDetailURLString] params:@{@"group_id":essayGroupID} method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if(error)
        {
            if (self.didFailCallback) {
                self.didFailCallback(error);
            }
        }
        else {
            NSDictionary * essayDic = [jsonObj valueForKey:@"data"];
            if (self.didFinishCallback) {
                self.didFinishCallback(essayDic);
            }
        }
        self.loading = NO;
    }];
}

@end
