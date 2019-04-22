//
//  TTArticlePanoramaView.h
//  Article
//
//  Created by rongyingjie on 2017/7/30.
//
//

#import "SSThemed.h"
#import "TTMotionView.h"

@class ExploreOrderedData;

@interface TTArticlePanoramaView : SSThemedView

@property (nonatomic, strong) TTMotionView * _Nonnull motionView;

- (void)layoutPics;
- (void)updatePics:(ExploreOrderedData * _Nonnull)orderedData;
- (TTMotionView *_Nonnull)animationFromView;
- (void)willDisplay;
- (void)didEndDisplaying;
- (void)resumeDisplay;

@end
