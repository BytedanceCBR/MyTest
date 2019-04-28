//
//  TTVCellCommodityCenter.h
//  Article
//
//  Created by panxiang on 2017/8/14.
//
//

#import <Foundation/Foundation.h>
#import "TTActivity.h"

@class TTVFeedListVideoTopContainerView;
@class TTVFeedListVideoBottomContainerView;
@interface TTVCellCommodityCenter : NSObject
@property (nonatomic, weak) TTVFeedListVideoTopContainerView *topContainerView;
@property (nonatomic, weak) TTVFeedListVideoBottomContainerView *bottomContainerView;
- (void)moreActionTypeClick:(NSString *)type;
@end
