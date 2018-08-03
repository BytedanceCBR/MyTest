//
//  TTVFeedListVideoBottomContainerView.h
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import "TTVFeedListBaseBottomContainerView.h"
#import "ExploreActionButton.h"
#import "TTAlphaThemedButton.h"
#import "TTVideoShareThemedButton.h"
#import "TTFollowThemeButton.h"
#import <TTDiggButton.h>
typedef void (^recommendViewShowActionTypeBlock) (BOOL clickArrow);

@interface TTVFeedListVideoBottomContainerView : TTVFeedListBaseBottomContainerView

@property (nonatomic, strong) ArticleVideoActionButton *commentButton; //评论按钮
@property (nonatomic, strong) ArticleVideoActionButton *shareButton; //分享按钮
@property (nonatomic, strong) TTDiggButton             *digButton;   //点赞按钮

//列表页展开分享
@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) SSThemedButton *shareTitleButton; //文字分享按钮
@property (nonatomic, strong) TTVideoShareThemedButton *firstShareButton; //第一个分享渠道
@property (nonatomic, strong) TTVideoShareThemedButton *secondShareButton; //第二个分享渠道
@property (nonatomic, assign) BOOL isShowShareView;  //标记shareview是否展示
@property (nonatomic, copy) recommendViewShowActionTypeBlock recommendViewShowActionType;

- (void)openShareView;
- (void)videoBottomContainerViewSetIsShowShareView;

@end
