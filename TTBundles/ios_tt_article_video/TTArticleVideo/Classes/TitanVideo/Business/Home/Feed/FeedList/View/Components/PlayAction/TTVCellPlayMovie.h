//
//  TTVCellPlayMovie.h
//  Article
//
//  Created by panxiang on 2017/4/20.
//
//

#import <Foundation/Foundation.h>
#import "TTVFeedListItem.h"
#import "TTVPlayVideo.h"
#import "TTVCellPlayMovieProtocol.h"

@interface TTVCellPlayMovie : NSObject <TTVCellPlayMovieProtocol>

@property (nonatomic, weak) NSObject <TTVCellPlayMovieDelegate> *delegate;
@property (nonatomic, strong) TTVPlayVideo *movieView;
@property (nonatomic, strong) UIView *logo;
@property (nonatomic, strong) TTVFeedListItem *cellEntity;
@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, assign) CGRect frame;
- (void)attachMovieView:(TTVPlayVideo *)movieView;
- (UIView *)detachMovieView;
- (void)readyToPlay;

@end
