//
//  TTCommodityActivity.h
//  Article
//
//  Created by lishuangyang on 2017/9/14.
//
//

#import "TTActivityProtocol.h"
#import "TTCommodityContentItem.h"

extern NSString * const TTActivityTypeShowCommodity;

@interface TTCommodityActivity : NSObject<TTActivityProtocol>

@property (nonatomic, strong)TTCommodityContentItem *contentItem;

@end

