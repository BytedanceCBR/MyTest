//
//  TTForwardWeitoutiaoContentItem.m
//  Article
//
//  Created by 王霖 on 17/4/24.
//
//
#import "TTForwardWeitoutiaoContentItem.h"
#import <TTKitchen/TTKitchenHeader.h>

NSString * const TTActivityContentItemTypeForwardWeitoutiao = @"com.toutiao.ActivityContentItem.ForwardWeitoutiao";
@implementation TTForwardWeitoutiaoContentItem
@synthesize contentTitle = _contentTitle;

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *contentTitle = [KitchenMgr getString:kKCUGCRepostWordingShareIconTitle];
        _contentTitle = contentTitle;
    }
    return self;
}

- (NSString *)contentItemType {
    return TTActivityContentItemTypeForwardWeitoutiao;
}

@end
