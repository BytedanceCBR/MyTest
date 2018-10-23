//
//  ArticleMomentDetailView.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "SSViewBase.h"
#import "ArticleMomentModel.h"
#import "ArticleMomentManager.h"
#import "ExploreMomentDefine.h"
#import "ExploreMomentListCellHeaderItem.h"
#import "SSAttributeLabel.h"
#import "SSThemed.h"
#import "TTUserInfoView.h"
#import "ArticleAvatarView.h"
#import "ExploreAvatarView.h"
#import "TTGroupModel.h"
#import "TTUserInfoView.h"
#import "TTCommentModelProtocol.h"
#import "TTCommentDetailReplyCommentModel.h"

@class ExploreMomentListCellHeaderItem;

@interface TTVideoCommentDetailView : SSViewBase

@property(nonatomic, strong)UITableView * commentListView;
@property (nonatomic, assign, readonly)ArticleMomentSourceType sourceType;
@property(nonatomic, strong)ArticleMomentModel *momentModel;
@property (nonatomic, weak)id<ExploreMomentListCellUserActionItemDelegate>delegate;
@property (nonatomic, strong) TTGroupModel *groupModel;
@property (nonatomic, copy) dispatch_block_t dismissBlock;
@property (nonatomic, copy) void (^updateMomentCountBlock)(NSInteger count, NSInteger increment);
@property (nonatomic, copy) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^syncDigCountBlock)();
@property (nonatomic, strong) id<TTCommentModelProtocol> commentModel;
@property (nonatomic, assign)BOOL fromThread;
@property (nonatomic, assign)BOOL showComment;
@property (nonatomic, assign)BOOL banEmojiInput; // 禁用表情输入
@property (nonatomic, assign)BOOL enterFromClickComment; //通过点击评论按钮进入，目前UGC在用
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSDictionary *extraTrackDict;
@property (nonatomic, assign) BOOL isAdVideo;
- (id)initWithFrame:(CGRect)frame
        momentModel:(ArticleMomentModel *)model
articleMomentManager:(ArticleMomentManager *)manager
         sourceType:(ArticleMomentSourceType)sourceType;

- (id)initWithFrame:(CGRect)frame
        momentModel:(ArticleMomentModel *)model
articleMomentManager:(ArticleMomentManager *)manager
         sourceType:(ArticleMomentSourceType)sourceType
replyMomentCommentModel:(ArticleMomentCommentModel *)replyMomentCommentModel
   showWriteComment:(BOOL)show;

//视频评论点击入口
- (id)initWithFrame:(CGRect)frame
          commentId:(int64_t)commentId
        momentModel:(ArticleMomentModel *)momentModel
           delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate
   showWriteComment:(BOOL)show
    fromVideoDetail:(BOOL)fromVideoDetail
        fromMessage:(BOOL)fromMessage;

- (void)insertLocalMomentCommentModel:(TTCommentDetailReplyCommentModel *)model;

- (ExploreMomentListCellHeaderItem *)getDetailViewHeaderItem;
+ (void)configGlobalCustomWidth:(CGFloat)width;

@end
