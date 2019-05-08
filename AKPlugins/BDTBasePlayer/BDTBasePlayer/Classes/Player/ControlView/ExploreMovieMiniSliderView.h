//
//  ExploreMovieMiniSliderView.h
//  Article
//
//  Created by Chen Hong on 15/5/27.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerContext.h"
#import "SSThemed.h"

@interface ExploreMovieMiniSliderView : SSThemedView<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;

@property(nonatomic, assign)CGFloat cacheProgress;
@property(nonatomic, assign)CGFloat watchedProgress;
@property(nonatomic, assign)BOOL isVerticle;

@end
