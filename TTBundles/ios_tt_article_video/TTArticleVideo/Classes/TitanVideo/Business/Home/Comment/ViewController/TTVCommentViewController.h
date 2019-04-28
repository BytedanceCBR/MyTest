//
//  TTVCommentViewController.h
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import "TTVCommentDefine.h"
#import "SSViewControllerBase.h"
#import "TTVVideoDetailContainerScrollView.h"
#import "TTVDetailContext.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTVCommentViewController : SSViewControllerBase <TTVCommentViewControllerProtocol,TTVDetailContext>

@property(nonatomic, weak) id<TTVCommentDelegate> delegate;

@property(nonatomic, assign) BOOL enableImpressionRecording;
@property(nonatomic, assign) BOOL hasSelfShown;
@property(nonatomic,strong) SSThemedTableView *commentTableView;
@property (nonatomic, strong) TTVContainerScrollView *ttvContainerScrollView;
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;

- (instancetype)initWithDataSource:(nullable id<TTVCommentDataSource>)datasource
                         delegate:(nullable id<TTVCommentDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (void)markTopCellNeedAnimation;

- (void)videoUpdateCommentWidth:(CGFloat)width;
- (void)refreshVideoCommentCellLayoutAtIndexPath:(NSIndexPath * _Nullable)indexPath replyCount:(NSInteger)replyCount;
- (void)commentViewWillScrollToTopCommentCell;
- (void)insertCommentWithDict:(NSDictionary *)dict;
@end
NS_ASSUME_NONNULL_END


