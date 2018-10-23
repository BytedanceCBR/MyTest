//
//  SSItemActionSender.m
//  Article
//
//  Created by Zhang Leonardo on 14-7-20.
//
//

#import "SSItemActionSender.h"
#import "CommonURLSetting.h"
#import <TTNetworkManager/TTNetworkManager.h>

static SSItemActionSender * shareManager;
@implementation SSItemActionSender

+ (id)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[SSItemActionSender alloc] init];
    });
    return shareManager;
}

- (void)sendADItemAction:(SSItemActionType)type adID:(NSNumber *)aID finishBlock:(SSItemActionFinishBlock)finishBlock
{
    if ([aID longLongValue] == 0) {
        return;
    }
    NSString * urlStr = nil;

    NSDictionary * postParameter = nil;
    switch (type) {
        case SSItemActionTypeADUnDislike:
        {
            urlStr = [CommonURLSetting adItemActionUnDislikeURLString];
            postParameter = @{@"ad_id" : @([aID longLongValue])};
        }
            break;
        case SSItemActionTypeADDislike:
        {
            urlStr = [CommonURLSetting adItemActionDislikeURLString];
            postParameter = @{@"ad_id" : @([aID longLongValue])};
        }
            
        default:
            break;
    }
    
    if (!isEmptyString(urlStr)) {
        [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:postParameter method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
            if (jsonObj) {
                jsonObj = @{@"result":jsonObj};
            }
            if (finishBlock) {
                finishBlock(jsonObj, error);
            }
        }];
    }
}

@end
