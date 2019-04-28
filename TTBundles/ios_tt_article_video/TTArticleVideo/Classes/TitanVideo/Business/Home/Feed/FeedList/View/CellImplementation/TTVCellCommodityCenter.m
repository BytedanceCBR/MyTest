//
//  TTVCellCommodityCenter.m
//  Article
//
//  Created by panxiang on 2017/8/14.
//
//

#import "TTVCellCommodityCenter.h"
#import "TTVFeedListVideoTopContainerView.h"
#import "TTVFeedListVideoBottomContainerView.h"
#import "TTVCellPlayMovieProtocol.h"
#import "TTVFeedListTopImageContainerView.h"

extern NSString * TTActivityContentItemTypeCommodity;

@implementation TTVCellCommodityCenter
- (void)moreActionTypeClick:(NSString *)type
{
    if ([type isEqualToString:TTActivityContentItemTypeCommodity]) {
        [self.topContainerView.imageContainerView addCommodity];
    }
}
@end
