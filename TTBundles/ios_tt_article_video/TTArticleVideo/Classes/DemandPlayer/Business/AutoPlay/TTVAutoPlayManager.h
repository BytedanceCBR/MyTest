//
//  TTVAutoPlayManager.h
//  Article
//
//  Created by panxiang on 2017/7/3.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayVideo.h"
#import "TTVArticleProtocol.h"

@class TTVAutoPlayModel;
@protocol TTVAutoPlayingCell <NSObject>
@required;
- (void)ttv_autoPlayingAttachMovieView:(UIView *)movieView;
- (TTVPlayVideo *)ttv_movieView;
- (CGRect)ttv_logoViewFrame;

- (TTVAutoPlayModel *)ttv_autoPlayModel;
- (BOOL)ttv_cellCouldAutoPlaying;
- (void)ttv_autoPlayVideo;
@end
@class ExploreOrderedData;
@interface TTVAutoPlayModel : NSObject
@property (nonatomic, copy) NSString *uniqueID;//自动播放视频的uniqueID
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSString *adID;
@property (nonatomic, copy) NSString *logExtra;
@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *groupID;
+ (TTVAutoPlayModel *)modelWithOrderedData:(ExploreOrderedData *)data;
+ (TTVAutoPlayModel *)modelWithArticle:(id <TTVArticleProtocol>)article category:(NSString *)categoryID;
@end

@interface TTVAutoPlayManager : NSObject
@property(nonatomic ,strong)TTVAutoPlayModel *model;
- (BOOL)IsCurrentAutoPlayingWithUniqueId:(NSString *)uniqueID;
+ (TTVAutoPlayManager *)sharedManager;

- (void)resetForce;//视频播放结束/失败/cell disappear后reset

/**
 *  在当前tableView中可见cell中，播放可播放的视频，停止需要停止的视频
 *
 *  @param tableView
 */
- (void)tryAutoPlayInTableView:(UITableView *)tableView;

/**
 *  取消已经开始的自动播放判断
 */
- (void)cancelTrying;


- (void)cacheAutoPlayingCell:(id<TTVAutoPlayingCell>)cell movie:(id)movie fromView:(UITableView *)fromView;

- (BOOL)cachedAutoPlayingCellInView:(UITableView *)view;
- (void)continuePlayCachedMovie;

- (void)ttv_cellTriggerPlayVideoIfCould:(UITableViewCell <TTVAutoPlayingCell> *)cell;

/**
 自动播放的视频 进入详情页
 */
- (void)trackForClickFeedAutoPlay:(TTVAutoPlayModel *)data movieView:(TTVPlayVideo *)movieView;

/**
 自动播放的视频 播放结束
 */
- (void)trackForFeedAutoOver:(TTVAutoPlayModel *)data movieView:(id)movieView;
@end
