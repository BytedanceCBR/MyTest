//
//  TTArticlePanorama3DView.h
//  Article
//
//  Created by rongyingjie on 2017/11/1.
//

#import "SSThemed.h"
#import "TTPanorama3DView.h"

@class ExploreOrderedData;

@interface TTArticlePanorama3DView : SSThemedView

@property (nonatomic, strong) TTPanorama3DView * _Nonnull panoramaView;

- (void)layoutPics;
- (void)updatePics:(ExploreOrderedData * _Nonnull)orderedData;
- (UIImage *_Nonnull)animationFromView;
- (void)willDisplay;
- (void)didEndDisplaying;
- (void)resumeDisplay;

@end
