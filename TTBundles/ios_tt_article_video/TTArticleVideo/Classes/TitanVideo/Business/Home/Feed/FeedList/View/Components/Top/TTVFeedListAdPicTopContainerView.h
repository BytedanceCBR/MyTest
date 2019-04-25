//
//  TTVFeedListAdPicTopContainerView.h
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import "TTVFeedListItem.h"
#import "TTVFeedContainerBaseView.h"

@interface TTVFeedListAdPicTopContainerView : TTVFeedContainerBaseView

@property (nonatomic, strong) TTVFeedListItem *cellEntity;

+ (CGFloat)obtainHeightForFeed:(TTVFeedListItem *)cellEntity cellWidth:(CGFloat)width;
@end
