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
@class ExploreMomentListCellHeaderItem;
extern NSString *const ArticleMomentDetailViewAddMomentNoti;
@interface ArticleMomentDetailView : SSViewBase
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
@property (nonatomic, assign)BOOL enterFromClickComment; //通过点击评论按钮进入，目前UGC在用
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSDictionary *extraTrackDict;
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
//文章评论点击入口
- (id)initWithFrame:(CGRect)frame commentId:(int64_t)commentId momentModel:(ArticleMomentModel *)momentModel delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate showWriteComment:(BOOL)show;
//视频评论点击入口
- (id)initWithFrame:(CGRect)frame commentId:(int64_t)commentId momentModel:(ArticleMomentModel *)momentModel delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate showWriteComment:(BOOL)show fromVideoDetail:(BOOL)fromVideoDetail;
- (void)insertLocalMomentCommentModel:(ArticleMomentCommentModel *)model;
- (ExploreMomentListCellHeaderItem *)getDetailViewHeaderItem;
+ (void)configGlobalCustomWidth:(CGFloat)width;
@end
@class ArticleMomentDetailViewCommentCell;
@protocol ArticleMomentDetailViewCommentCellDelegate <NSObject>
- (void)commentCell:(ArticleMomentDetailViewCommentCell *)cell openComment:(ArticleMomentCommentModel *)model;
- (void)commentCell:(ArticleMomentDetailViewCommentCell *)cell deleteComment:(ArticleMomentCommentModel *)model;
@end
#pragma mark - 评论列表 cell
@interface ArticleMomentDetailViewCommentCell : SSThemedTableViewCell<SSAttributeLabelModelDelegate>
@property(nonatomic, weak)id<ArticleMomentDetailViewCommentCellDelegate>ssDelegate;
@property(nonatomic, strong)TTUserInfoView * nameView;
@property(nonatomic, strong)SSAttributeLabel * descLabel;
@property(nonatomic, strong)ExploreAvatarView * avatarView;
@property(nonatomic, strong)UILabel * timeLabel;
@property(nonatomic, strong)UIView * separatorLineView;
@property(nonatomic, strong)ArticleMomentCommentModel * commentModel;
@property(nonatomic, strong)ArticleMomentModel * replyToMomentModel;
@property(nonatomic, strong)SSThemedButton *replyButton;
@property(nonatomic, strong)UIButton * diggButton;
@property(nonatomic, assign)CGFloat viewWidth;
@property(nonatomic, assign)CGFloat midInterval;
@property(nonatomic, strong)NSArray * menuItems;
@property (nonatomic, strong) TTGroupModel *groupModel;
@property(nonatomic, assign)ArticleMomentSourceType sourceType;
+ (CGFloat)heightForDescLabel:(ArticleMomentCommentModel *)model width:(CGFloat)cellWidth;
+ (CGFloat)heightForCommentModel:(ArticleMomentCommentModel *)model cellWidth:(CGFloat)width;
@end
