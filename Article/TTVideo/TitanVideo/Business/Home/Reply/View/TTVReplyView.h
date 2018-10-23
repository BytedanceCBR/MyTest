//
//  TTVReplyView.h
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "SSViewBase.h"
#import "SSAttributeLabel.h"
#import "SSThemed.h"
#import "TTUserInfoView.h"
#import "ArticleAvatarView.h"
#import "ExploreAvatarView.h"
#import "TTGroupModel.h"
#import "TTUserInfoView.h"
#import "TTCommentDetailReplyCommentModel.h"
#import "TTVCommentModelProtocol.h"
#import "ExploreDetailToolbarView.h"
#import "SSLoadMoreCell.h"

typedef NS_ENUM(NSUInteger, TTVReplyViewLoadMoreCellTriggerSource) {
    TTVReplyViewLoadMoreCellTriggerSourceCellWillDisplay,
    TTVReplyViewLoadMoreCellTriggerSourceCellDidSelect
};

@protocol TTVReplyModelProtocol, TTVReplyListCellDelegate;
@class TTVReplyViewModel, TTVReplyView;

@protocol TTVReplyViewDelegate <NSObject>

- (void)replyView:(TTVReplyView *)replyView commentButtonClicked:(id)sender;

- (void)replyView:(TTVReplyView *)replyView userInfoDiggButtonClicked:(id)sender;

- (void)replyView:(TTVReplyView *)replyView loadMoreCellTrigger:(TTVReplyViewLoadMoreCellTriggerSource)triggerSource;

@end

@interface TTVReplyView : SSViewBase

@property(nonatomic, strong)UITableView * commentListView;
@property(nonatomic, strong)ExploreDetailToolbarView *toolBar;
@property (nonatomic, strong)SSLoadMoreCell * loadMoreCell;

@property (nonatomic, weak) id <TTVReplyViewDelegate> delegate;
@property (nonatomic, copy) dispatch_block_t dismissBlock;
@property (nonatomic, copy) void (^updateMomentCountBlock)(NSInteger count, NSInteger increment);
@property (nonatomic, copy) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, assign)BOOL showComment;
@property (nonatomic, assign)BOOL enterFromClickComment; //通过点击评论按钮进入，目前UGC在用
@property (nonatomic, assign)BOOL hasDeleteReplyPermission; //回复区是否可以显示删除按钮，目前UGC在用
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSDictionary *extraTrackDict;
@property (nonatomic, assign) BOOL isBanEmoji;

//视频评论点击入口
- (id)initWithFrame:(CGRect)frame
          viewModel:(TTVReplyViewModel *)viewModel
   showWriteComment:(BOOL)show
       cellDelegate:(id <TTVReplyListCellDelegate>)delegate;

+ (void)configGlobalCustomWidth:(CGFloat)width;

- (void)reloadListViewData;
@end
