//
//  TTVFeedListVideoAdItem.h
//  Article
//
//  Created by panxiang on 2017/3/2.
//
//

#import "TTVFeedListCell.h"
#import "TTVFeedListVideoTopContainerView.h"
#import "TTVFeedListAdBottomContainerView.h"

@interface TTVFeedListVideoAdItem : TTVFeedListItem
@end

@interface TTVFeedListVideoAdCell : TTVFeedListCell

@property (nonatomic, strong) TTVFeedListVideoTopContainerView *topContainerView;
@property (nonatomic, strong) TTVFeedListAdBottomContainerView *bottomContainerView;

@end

