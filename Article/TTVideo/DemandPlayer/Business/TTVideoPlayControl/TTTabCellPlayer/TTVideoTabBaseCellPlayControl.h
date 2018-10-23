//
//  TTVideoTabBaseCellPlayControl.h
//  Article
//
//  Created by panxiang on 2017/6/5.
//
//

#import <Foundation/Foundation.h>
#import "ExploreCellBase.h"

@class ExploreOrderedData;
@class TTImageView;
@class Article;
@class SSViewBase;
@class TTVideoCellActionBar;
@protocol TTVideoTabBaseCellPlayControlDelegate <NSObject>
- (void)ttv_shareButtonOnMovieTopViewDidPress;
- (void)ttv_moreButtonOnMovieTopViewDidPress;
- (void)ttv_shareButtonOnMovieFinishViewDidPress;
- (void)ttv_shareActionClickedWithActivityType:(NSString *)activityType;
- (void)ttv_invalideMovieView;
- (void)ttv_movieViewDidExitFullScreen;
- (void)ttv_movieViewWillAppear:(UIView *)newView;
- (void)ttv_commodityViewClosed;
- (void)ttv_movieViewReplayButtonDidPress;
@end

@interface TTVideoTabBaseCellPlayControl : NSObject
@property (nonatomic, weak) NSObject <TTVideoTabBaseCellPlayControlDelegate> *delegate;
@property(nonatomic, strong) ExploreOrderedData *orderedData;
@property(nonatomic, strong) Article *article;
@property (nonatomic, strong) TTImageView *logo;
@property(nonatomic, strong)UIView *movieView;
@property (nonatomic, weak) SSViewBase *movieViewDelegateView;
@property (nonatomic, strong) TTVideoCellActionBar *actionBar;
- (void)playButtonClicked;
- (void)invalideMovieView;
- (void)didEndDisplaying;
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context;
- (BOOL)isPlaying;
- (BOOL)isPause;
- (BOOL)isStopped;
- (BOOL)isMovieFullScreen;
- (BOOL)exitFullScreen:(BOOL)animation completion:(void (^)(BOOL finished))completion;
- (void)goVideoDetail;
- (void)beforeCellReuse;
- (BOOL)hasMovieView;
- (UIView *)detachMovieView;
- (void)attachMovieView:(UIView *)movieView;
- (void)willAppear;
- (void)addCommodity;
@end

