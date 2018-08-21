//
//  TTVFeedListVideoTopContainerView.h
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import "TTVFeedListTopImageContainerView.h"
#import "TTVFeedListItem.h"
#import "TTVFeedContainerBaseView.h"

@interface TTVFeedListVideoTopContainerView : TTVFeedContainerBaseView

@property (nonatomic, strong) TTVFeedListItem *cellEntity;

@property (nonatomic, strong, readonly) TTVFeedListTopImageContainerView *imageContainerView;

+ (CGFloat)obtainHeightForFeed:(TTVFeedListItem *)cellEntity cellWidth:(CGFloat)width;

@end
