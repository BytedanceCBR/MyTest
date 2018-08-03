//
//  TTVFeedListLiveItem.h
//  Article
//
//  Created by panxiang on 2017/4/20.
//
//

#import "TTVFeedListItem.h"
#import "TTVFeedListCell.h"
#import "TTVFeedListLiveBottomContainerView.h"

@class TTVFeedListLiveTopContainerView;
@class TTVFeedListLiveBottomContainerView;
@interface TTVFeedListLiveItem : TTVFeedListItem

@end


@interface TTVFeedListLiveCell : TTVFeedListCell

@property (nonatomic, strong) TTVFeedListLiveTopContainerView *topContainerView;
@property (nonatomic, strong) TTVFeedListLiveBottomContainerView *bottomContainerView;

@end
