//
//  TTVideoFeedListPicAdAppCell.h
//  Article
//
//  Created by panxiang on 2017/3/2.
//
//

#import "TTVFeedListCell.h"
#import "TTVFeedListAdPicTopContainerView.h"
#import "TTVFeedListAdBottomContainerView.h"


@interface TTVFeedListPicAdItem : TTVFeedListItem

@end

@interface TTVFeedListPicAdCell : TTVFeedListCell

@property (nonatomic, strong) TTVFeedListAdPicTopContainerView *topContainerView;
@property (nonatomic, strong) TTVFeedListAdBottomContainerView *bottomContainerView;

@end



