//
//  TTCopyContentItem.m
//  Pods
//
//  Created by 延晋 张 on 16/6/7.
//
//

#import "TTCopyContentItem.h"

NSString * const TTActivityContentItemTypeCopy         =
@"com.toutiao.ActivityContentItem.Copy";

@implementation TTCopyContentItem

- (instancetype)initWithDesc:(NSString *)desc
{
    if (self = [super init]) {
        self.desc = desc;
    }
    return self;
}

-(NSString *)contentItemType
{
    return TTActivityContentItemTypeCopy;
}

@end
