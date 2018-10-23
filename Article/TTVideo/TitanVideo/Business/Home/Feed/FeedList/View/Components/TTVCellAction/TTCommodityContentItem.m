//
//  TTCommodityContentItem.m
//  Article
//
//  Created by lishuangyang on 2017/9/14.
//
//

#import "TTCommodityContentItem.h"

NSString * const TTActivityContentItemTypeCommodity        =
@"com.toutiao.ActivityContentItem.commodity";

@implementation TTCommodityContentItem

- (instancetype)initWithDesc:(NSString *)desc
{
    if (self = [super init]) {
        self.desc = desc;
    }
    return self;
}

-(NSString *)contentItemType
{
    return TTActivityContentItemTypeCommodity;
}

- (NSString *)contentTitle{
    if (self.desc) {
        return self.desc;
    }else{
        return NSLocalizedString(@"推荐商品", nil);
    }
}

- (NSString *)activityImageName{
    return @"video_commodity_goods";
}

@end
