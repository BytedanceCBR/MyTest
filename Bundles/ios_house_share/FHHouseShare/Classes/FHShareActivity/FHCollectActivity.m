//
//  FHCollectActivity.m
//  FHHouseShare
//
//  Created by bytedance on 2020/11/9.
//

#import "FHCollectActivity.h"

@implementation FHCollectActivity

-(NSString *)contentItemType {
    return FHActivityContentItemTypeCollect;
}

-(void)performActivityWithCompletion:(BDUGActivityCompletionHandler)completion {
    if(self.contentItem.collectBlcok) {
        self.contentItem.collectBlcok();
    }
}

@end
