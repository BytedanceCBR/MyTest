//
//  FHUGCCellPlayMovie.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/8.
//

#import <Foundation/Foundation.h>
#import "TTVFeedListItem.h"
#import "TTVPlayVideo.h"
#import "TTVCellPlayMovieProtocol.h"
#import "ExploreCellBase.h"
#import "TTVPlayerDoubleTap666Delegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellPlayMovie : NSObject <TTVCellPlayMovieProtocol>

@property (nonatomic, weak) NSObject <TTVCellPlayMovieDelegate> *delegate;
@property (nonatomic, weak) id<TTVPlayerDoubleTap666Delegate> doubleTap666Delegate;
@property (nonatomic, strong) TTVPlayVideo *movieView;
@property (nonatomic, strong) UIView *logo;
@property (nonatomic, strong) TTVFeedListItem *cellEntity;
@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, assign) CGRect frame;
- (void)attachMovieView:(TTVPlayVideo *)movieView;
- (UIView *)detachMovieView;
- (void)removeCommodityView;
@end

NS_ASSUME_NONNULL_END
