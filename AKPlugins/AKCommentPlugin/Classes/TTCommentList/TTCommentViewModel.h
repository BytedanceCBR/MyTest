//
//  TTCommentViewModel.h
//  Article
//
//  Created by 冯靖君 on 16/3/30.
//
//

#import <Foundation/Foundation.h>
#import <BDTSharedHeaders/SSImpression_Emums.h>
#import "TTCommentDefines.h"


@protocol TTCommentModelProtocol;


/**
 * 评论列表加载结果
 */
typedef NS_ENUM(NSInteger, TTCommentLoadResult) {
    TTCommentLoadResultSuccess,
    TTCommentLoadResultFailed
};

@interface TTCommentManagedObject : NSObject
@property(nonatomic, strong) NSNumber * offset;
@property(nonatomic, copy) NSString * tabName;
@property(nonatomic, assign) BOOL needLoadingUpdate;
@property(nonatomic, assign) BOOL needLoadingMore;
@property(nonatomic, strong) NSMutableArray *commentModels;
@property(nonatomic, strong) NSMutableSet * uniqueIDSet;
@property(nonatomic, strong) NSMutableArray *commentLayoutArray;
@property(nonatomic, assign) CGFloat constraintWidth;
@property(nonatomic, assign) BOOL showDelete;

- (NSMutableArray *)queryCommentModels;
- (void)appendCommentModels:(NSArray <id<TTCommentModelProtocol>> *)models;
- (void)insertCommentModelToTop:(id<TTCommentModelProtocol>)model;
- (BOOL)deleteModel:(id<TTCommentModelProtocol>)model;
@end

@protocol TTCommentViewModelDelegate;
@protocol TTCommentDataSource;


@interface TTCommentViewModel : NSObject

@property (nonatomic, weak) id<TTCommentDataSource> dataSource;
@property (nonatomic, weak) id<TTCommentViewModelDelegate> delegate;

@property (nonatomic, assign) CGFloat constraintWidth;

/**
 * 评论状态
 */
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) TTCommentLoadResult loadResult;

/**
 * 评论数据
 */
@property (nonatomic, assign) NSInteger commentTotalNum;      // 评论数
@property (nonatomic, assign) BOOL banComment;                // 禁评论
@property (nonatomic, assign) BOOL banEmojiInput;             // 禁表情
@property (nonatomic, strong) NSString *commentPlaceholder;   // 评论输入框 placeholder
@property (nonatomic, assign) BOOL goTopicDetail;             // added 4.6:是否允许查看评论的动态详情页
@property (nonatomic, assign, readonly) BOOL detailNoComment; // 详情页不显示评论
@property (nonatomic, assign) BOOL hasFoldComment;            // 是否有被折叠的评论
@property (nonatomic, strong, nullable) id<TTCommentModelProtocol> defaultReplyCommentModel;

- (void)tt_startLoadCommentsForMode:(TTCommentLoadMode)loadMode withCompletionHandler:(TTCommentLoadCompletionHandler)handler;
- (NSArray<id<TTCommentModelProtocol>> *)tt_curCommentModels;
- (NSArray *)tt_curCommentLayoutArray;
- (TTGroupModel *)tt_groupModel;
- (void)tt_setCommentCategory:(TTCommentCategory)category; // 之前有热评和时间线评论
- (NSArray<NSString *> *)tt_commentTabNames;
- (void)tt_addToTopWithCommentModel:(id <TTCommentModelProtocol>)commentModel;
- (void)tt_removeCommentWithCommentID:(NSString *)commentID;
- (void)tt_removeComment:(id<TTCommentModelProtocol>)model;
- (BOOL)tt_isFooterCellWithIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tt_isFooterEmptyCellIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tt_needShowFooterCell;

//数据状态
- (BOOL)tt_needLoadingUpdate;
- (BOOL)tt_needLoadingMore;
- (void)tt_refreshLayout:(void (^)())completion;

@end


/**
 * 统计
 */
@interface TTCommentViewModel (TTCommentTrack)

- (void)tt_sendShowTrackForEmbeddedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


/**
 * Impression
 */
@interface TTCommentViewModel (TTCommentImpression)

- (void)tt_registerToImpressionManager:(id)object;
- (void)tt_unregisterFromImpressionManager:(id)object;
- (void)tt_enterCommentImpression;
- (void)tt_leaveCommentImpression;
- (void)tt_recordForComment:(id<TTCommentModelProtocol>)commentModel status:(SSImpressionStatus)status;

@end


/**
 * Delegate
 */
@protocol TTCommentViewModelDelegate <NSObject>

- (void)commentViewModel:(TTCommentViewModel *)viewModel refreshCommentCount:(int)commentCount;

@end


