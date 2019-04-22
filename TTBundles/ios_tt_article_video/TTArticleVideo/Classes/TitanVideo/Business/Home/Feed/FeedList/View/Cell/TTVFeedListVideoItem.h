//
//  TTVFeedListVideoItem.h
//  Article
//
//  Created by pei yun on 2017/3/31.
//
//

#import "TTVFeedListCell.h"
#import "TTVFeedListItem.h"

@interface TTVFeedListVideoItem : TTVFeedListItem
@end

@class TTVFeedListVideoTopContainerView;
@class TTVFeedListVideoBottomContainerView;
@interface TTVFeedListVideoCell : TTVFeedListCell

@property (nonatomic, strong) TTVFeedListVideoTopContainerView *topContainerView;
@property (nonatomic, strong) TTVFeedListVideoBottomContainerView *bottomContainerView;

@end
