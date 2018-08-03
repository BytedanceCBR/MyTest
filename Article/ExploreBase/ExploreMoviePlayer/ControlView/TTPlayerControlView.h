//
//  TTPlayerControlView.h
//  Article
//
//  Created by panxiang on 2017/2/17.
//
//

#import <Foundation/Foundation.h>
#import "ExploreMoviePlayerControlViewDelegate.h"
#import "TTVPlayerStateStore.h"

@protocol TTPlayerControlView <NSObject>

@required
- (BOOL)hasAdButton;
@property(nonatomic, weak)id<ExploreMoviePlayerControlViewDelegate> delegate;
@end
