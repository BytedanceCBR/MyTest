//
//  ZCLChannelManager.m
//  SSPackUtil
//
//  Created by Zhang Leonardo on 14-11-26.
//  Copyright (c) 2014年 leonardo. All rights reserved.
//

#import "ZCLChannelManager.h"
#import "ZCLChannelModel.h"

#define kChannelManagerUserDefault @"kChannelManagerUserDefault"

@implementation ZCLChannelManager

+ (NSArray *)channelIDs
{
    NSArray * channelModels = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kChannelManagerUserDefault]];
    if (channelModels == nil) {
        NSArray * channelIDStrs = @[@"aisizhushou", @"xyzhushou", @"91zhushou", @"pp", @"youpo", @"youpoios1", @"youpoios2", @"youpoios3", @"youpoios4", @"kuaiyong", @"haimazhushou", @"itools", @"hulizhushou", @"applezhushou", @"tongbu", @"qingmo", @"tianyou"];
        NSMutableArray * models = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < [channelIDStrs count]; i ++) {
            ZCLChannelModel * model = [[ZCLChannelModel alloc] init];
            NSString * cID = [channelIDStrs objectAtIndex:i];
            model.channelID = cID;
            model.checked = YES;
            [models addObject:model];
        }
        [self save:models];
        channelModels = [NSArray arrayWithArray:models];
    }
    
    return channelModels;
}

+ (ZCLChannelModel *)modelByChannelID:(NSString *)channelID
{
    ZCLChannelModel * model = [[ZCLChannelModel alloc] init];
    model.channelID = channelID;
    model.checked = YES;
    return model;
}

+ (void)save:(NSArray *)models
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:models] forKey:kChannelManagerUserDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
