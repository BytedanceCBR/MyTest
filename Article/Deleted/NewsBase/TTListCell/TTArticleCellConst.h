//
//  TTArticleCellConst.h
//  Article
//
//  Created by 杨心雨 on 16/8/18.
//
//

// MARK: 间距
/** 顶部间距 */
extern CGFloat kPaddingTop();

/** 顶部间距(置顶样式) */
extern CGFloat kPaddingStickTop();

/** 顶部间距(U11样式) */
extern CGFloat kPaddingUFTop();

/** 底部间距 */
extern CGFloat kPaddingBottom();

/** 底部间距(置顶样式) */
extern CGFloat kPaddingStickBottom();

/** 底部间距(u11样式) */
extern CGFloat kPaddingUFBottom();

/** 左部间距 */
extern CGFloat kPaddingLeft();

/** 右部间距 */
extern CGFloat kPaddingRight();

/*功能区顶部文案和头像间距*/
extern CGFloat kPaddingTopLabelToAavatarView();

/** 功能区底部间距 */
extern CGFloat kPaddingFunctionBottom();

/** 标题与更多间距(横向) */
extern CGFloat kPaddingTitleToMore();

/** 标签与标题间距(横向) */
extern CGFloat kPaddingTagToTitle();

/** 标题与摘要间距(纵向) */
extern CGFloat kPaddingTitleToAbstract();

/** 标题与图片(视频)间距(横向) */
extern CGFloat kPaddingTitleToPic();

/** 图片(视频)顶部间距 */
extern CGFloat kPaddingPicTop();

/** 图片（评论cell）顶部间距 */
extern CGFloat KUFPaddingCommentPicTop();

/** 标题(摘要)与评论间距(纵向) */
extern CGFloat kPaddingTitleOrAbstractToComment();

/** 图片(视频)与评论间距(纵向) */
extern CGFloat kPaddingPicToComment();

/** 信息栏顶部间距 */
extern CGFloat kPaddingInfoTop();

/** 创意通投顶部间距 */
extern CGFloat kPaddingActionADTop();

/** 信息栏保护间距 */
extern CGFloat kPaddingInfoConstTop();

// MARK: - Cell
/** 背景色 */
extern NSString* kCellBackgroundColor();

// MARK: - 功能区控件
/** 喜欢与来源间距 */
extern CGFloat kFunctionViewPaddingLikeToSource();

/** 来源图片与来源间距 */
extern CGFloat kFunctionViewPaddingSourceImageToSource();

/** 来源图片和来源间距 */
extern CGFloat kUFPaddingSourceImageToSource();

/** 来源大图和来源间距 */
extern CGFloat kUFS2PaddingSourceImageToSource();

/** 喜欢字号 */
extern CGFloat kLikeViewFontSize();

/** 喜欢字体颜色 */
extern NSString* kLikeViewTextColor();

/** 来源图片边长 */
extern CGFloat kSourceViewImageSide();

/** U11来源图片边长 */
extern CGFloat kUFSourceViewImageSide();

/** 来源图片底部间距 */
extern CGFloat kUFSourceViewBottomPadding();

/** 来源图片背景色 */
extern NSString* kSourceViewImageBackgroundColor();

/** 来源图片描边色 */
extern NSString* kSourceViewImageBorderColor();

/** 来源字号 */
extern CGFloat kSourceViewFontSize();

/** u11来源字号 */
extern CGFloat kUFSourceLabelFontSize();

/** 来源字体颜色 */
extern NSString* kSourceViewTextColor();

extern NSString* kVerifiedContentSeprateLineColor();

/** 认证信息字号 */
extern CGFloat kVerifiedContentLabelFontSize();

/** 认证信息字体颜色 */
extern NSString* kVerifiedContentLabelTextColor();

/** 认证信息已读字体颜色 */
extern NSString* kVerifiedContentLabelHasReadTextColor();

/** 来源高亮字体颜色 */
extern NSString* kSourceViewHighlightedTextColor();

// MARK: - 更多控件
/** 更多控件边长 */
extern CGFloat kMoreViewSide();

/** 更多控件扩展 */
extern CGFloat kMoreViewExpand();

extern CGFloat kMoreViewTopPadding();

extern CGFloat kMoreViewRightPadding();

// MARK: - 标题控件
/** 标题字号 */
extern CGFloat kTitleViewFontSize();

/** 标题字号(置顶样式) */
extern CGFloat kTitleViewStickFontSize();

/** 标题字体颜色 */
extern NSString* kTitleViewTextColor();

extern NSString* kTitleViewHasReadTextColor();

/** 标题行高 */
extern CGFloat kTitleViewLineHeight();

/** 标题行高(置顶样式) */
extern CGFloat kTitleViewStickLineHeight();

/** 标题行数 */
extern NSInteger kTitleViewLineNumber();

/** 标题行数(无摘要右小图) */
extern NSInteger kTitleViewSpecialLineNumber();

// MARK: - 摘要控件
/** 摘要字号 */
extern CGFloat kAbstractViewFontSize();

/** 摘要字体颜色 */
extern NSString* kAbstractViewTextColor();

/** 摘要已读字体颜色 */
extern NSString* kAbstractViewHadReadTextColor();

/** 摘要行高 */
extern CGFloat kAbstractViewLineHeight();

/** 摘要行数 */
extern NSInteger kAbstractViewLineNumber();

// MARK: - 图片(视频)控件
/** 图片(视频)内部间距 */
extern CGFloat kPicViewPaddingInner();

extern CGFloat kSquareViewPaddingInner();

/** 图片(视频)背景色 */
extern NSString* kPicViewBackgroundColor();

/** 图片(视频)描边色 */
extern NSString* kPicViewBorderColor();

/** 信息视图右边距 */
extern CGFloat kPicMessageViewPaddingRight();

extern CGFloat kPicMessageViewPaddingRightVideo();

extern CGFloat kPicMessageViewPaddingRightPhoto();
/** 信息视图下边距 */
extern CGFloat kPicMessageViewPaddingBottom();

/** 信息视图内部水平边距 */
extern CGFloat kPicMessageViewPaddingHorizontal();

/** 信息视图图片与文字间距 */
extern CGFloat kPicMessageViewPaddingImageToLabel();

/** 信息视图固定高度 */
extern CGFloat kPicMessageViewHeight();

/** 信息视图标准宽度 */
extern CGFloat kPicMessageViewWidth();

/** 信息视图圆角半径 */
extern CGFloat kPicMessageViewCornerRadius();

/** 信息视图背景色 */
extern NSString* kPicMessageViewBackgroundColor();

/** 信息视图文字字号 */
extern CGFloat kPicMessageViewFontSize();

/** 信息视图文字颜色 */
extern NSString* kPicMessageViewTextColor();

// MARK: - 评论控件
/** 评论字号 */
extern CGFloat kCommentViewFontSize();

/** 评论字体颜色 */
extern NSString* kCommentViewTextColor();

/** 评论已读字体颜色 */
extern NSString* kCommentViewHasReadTextColor();

/** 评论用户字体颜色 */
extern NSString* kCommentViewUserTextColor();

/** 评论用户字体高亮颜色 */
extern NSString* kCommentViewUserTextHighlightedColor();

/** 评论行高 */
extern CGFloat kCommentViewLineHeight();

/** 评论行数 */
extern NSInteger kCommentViewLineNumber();

// MARK: - 信息栏控件
extern CGFloat kInfoViewHeight();

extern CGFloat kInfoViewFontSize();

// MARK: - 标签控件
/** 标签字体大小 */
extern CGFloat kTagViewFontSize();

/** 标签单字宽度 */
extern CGFloat kTagViewOneWordWidth();

/** 标签双字宽度 */
extern CGFloat kTagViewTwoWordsWidth();

/** 标签水平间距 */
extern CGFloat kTagViewPaddingHorizontal();

/** 标签高度 */
extern CGFloat kTagViewHeight();

/** 标签圆角 */
extern CGFloat kTagViewCornerRadius();

/** 标签红色字 */
extern NSString* kTagViewTextColorRed();

/** 标签红描边 */
extern NSString* kTagViewLineColorRed();

/** 标签蓝色字 */
extern NSString* kTagViewTextColorBlue();

/** 标签蓝描边 */
extern NSString* kTagViewLineColorBlue();

//MARK: - 底部Action控件
extern CGFloat kPaddingTopOfActionView();

extern CGFloat kActionViewHeight();

extern NSString* kActionViewCommentButtonTextColor();

extern CGFloat kPaddingBetweenDiggButtonAndCommentBUtton();

extern NSString* kActionViewTimeLabelColor();

// MARK: - 底部分割线
extern NSString* kBottomLineViewBackgroundColor();

// MARK: - 功能菜单
/** 帖子标题行数 */
extern NSInteger kThreadTitleLineNumber();

/** 帖子内容行数(文章样式) */
extern NSInteger kThreadStyle1ContentLineNumber();

/** 帖子内容行数(帖子样式) */
extern NSInteger kThreadStyle2ContentLineNumber();

/** */
extern NSInteger kThreadCommentLineNumber();

/** 视频cell标题字号 */
extern CGFloat kVideoCellTitleFontSize();

extern CGFloat kRedPacketSubSubscribeButtonWidth();

/** u11关注按钮宽度 */
extern CGFloat kUFSubscribeButtonWidth();

/** u11关注按钮高度 */
extern CGFloat kUFSubscribeButtonHeight();

/** u11关注按钮右边距 */
extern CGFloat kUFSubscribeButtonRightPadding();

/** u11关注按钮字号 */
extern CGFloat kUFSubscribeButtonTitleFontSize();

/** u11加v的icon的大小，需要传入user_auth_info */
extern CGSize kUFVerifiedImageViewSize(NSString *userAuthInfo);

/** u11竖向分隔线高度 */
extern CGFloat kUFSeprateLineHeight();

/** u11加v的左右间距 */
extern CGFloat kUFVerifiedImageViewPadding();

/** u11推荐理由左侧间距 */
extern CGFloat kUFRecommendLabelLeftPadding();

/** u11品牌露出间距 */
extern CGFloat kUFIconsShowingPadding();

/** 竖向分割线左右间距*/
extern CGFloat kUFSeprateLinePadding();

/** u11顶踩功能区高度 */
extern CGFloat kUFFunctionViewHeight();

/** u11信息栏距离标题的间距 */
extern CGFloat kUFPaddingSourceImageToTitle();

/** u11大图与顶踩功能区间距 */
extern CGFloat kUFPaddingPicBottom();

/** u11顶和评论字号 */
extern CGFloat kUFFunctionViewFontSize();

/** u11播放按钮边长 */
extern CGFloat kUFPlayButtonSide();

/** u11ugc动态cell上，评论内容字号 */
extern CGFloat kUFCommentContentFontSize();

/** u11ugc动态cell上，评论内容行高 */
extern CGFloat kUFCommentContentLineHeight();

/** u11ugc动态cell上，评论内容行数 */
extern NSInteger kUFCommentContentLineNumber();

/** u11ugc动态cell上，新闻内容下的背景高度 */
extern CGFloat kUFBackgroundViewHeight();

/** u11ugc动态cell上，左图边长 */
extern CGFloat kUFLeftPicViewSide();

/** u11ugc动态cell上，左图与背景的左边间距 */
extern CGFloat kUFLeftPicViewLeftPadding();

/** u11ugc动态cell上，左图与背景的左边间距 */
extern CGFloat kUFLeftPicViewTopPadding();

/** u11ugc动态cell上，左图与右边标题的左边间距 */
extern CGFloat kUFLeftPicViewRightPadding();

/** u11ugc动态cell上，标题与背景的右边的间距 */
extern CGFloat kUFTitleRightPaddingToBack();

/** u11ugc动态cell上，标题的字号 */
extern CGFloat kUFDongtaiTitleFontSize();

/** u11ugc动态cell上，标题的字号 */
extern CGFloat kUFS1DongtaiTitleFontSize();

/** u11ugc动态cell上，标题的行高 */
extern CGFloat kUFDongtaiTitleLineHeight();

/** u11ugc动态cell上，标题的行高 */
extern CGFloat kUFS1DongtaiTitleLineHeight();

/** u11ugc动态cell上，标题的行数 */
extern NSInteger kUFDongtaiTitleLineNumber();

/** u11分割条的高度 */
extern CGFloat kUFSeprateViewHeight();

/* u11帖子正文字号 */
extern CGFloat kUFThreadContentFontSize();

/** u11帖子正文行高 */
extern CGFloat kUFThreadContentLineHeight();

/** u11帖子地理位置字号 */
extern CGFloat kUFThreadLocationFontSize();

/** u11帖子地理位置顶部间距 */
extern CGFloat kUFThreadLocationTopPadding();

/** u11帖子地理位置高度 */
extern CGFloat kUFThreadLocationHeight();

/** u11帖子地理位置左边距 */
extern CGFloat kUFThreadLocationLeftPadding();

/** u11帖子功能区头部间距 */
extern CGFloat kUFThreadFunctionTopPadding();

/** u11帖子webpage上边距 */
extern CGFloat kUFThreadWebpageTopPadding();

/** u11帖子webpage高度 */
extern CGFloat kUFThreadWebpageHeight();

/** u11帖子webpage标题字体大小 */
extern CGFloat kUFThreadWebpageTitleFontSize();

/** u11帖子webpage描述字体大小 */
extern CGFloat kUFThreadWebpageDescribeFontSize();

/** u11帖子转发内容顶部间距 */
extern CGFloat kUFThreadForwardItemTopPadding();

/** u11帖子转发内容内部垂直间距 */
extern CGFloat kUFThreadForwardItemInnerVerticalPadding();

/** u11转发内容被删除label顶部间距 */
extern CGFloat kUFThreadForwardedItemStatusLabelTopPadding();

/** u11转发内容被删除label高度 */
extern CGFloat kUFThreadForwardedItemStatusLabelHeight();
    
/** u11S1不感兴趣按钮右边距 */
extern CGFloat kUFS1ThreadUnterestRightPadding();

/** u11S1不感兴趣按钮大小 */
extern CGSize kUFS1ThreadUnterestButtonSize();

/** u11S1关注按钮与不感兴趣按钮之间的间距 */
extern CGFloat kUFS1FollowBtnPaddingToUnInterestBtn();

/** u11S1互动数据的字体大小 */
extern CGFloat kUFS1InteractionInfoFontSize();

/** u11S1互动数据左边距 */
extern CGFloat kUFS1InteractionInfoLeftPadding();

/** u11S1互动数据与定位信息的间距 */
extern CGFloat kUFS1InteractionInfoTopPaddingLocationLabel();

/** u11S1点赞区域与上层的间距 */
extern CGFloat kUFS1ActionRegionTopPadding();

/** u11S1点赞区域高度 */
extern CGFloat kUFS1ActionRegionHeight();

/** u11S1点赞区域中间间距线的高度 */
extern CGFloat kUFS1ActionRegionCenterSeparateViewHeight();

/** u11S1点赞按钮的高度 */
extern CGFloat kUFS1DiggButtonHeight();

/** u11S1点赞按钮的宽度 */
extern CGFloat kUFS1DiggButtonWidth();

/** u11S1评论按钮的高度 */
extern CGFloat kUFS1CommentButtonHeight();

/** u11S1评论按钮的宽度 */
extern CGFloat kUFS1CommentButtonWidth();

/** u11S1大图与文字区间距 */
extern CGFloat kUFS1PaddingPicBottom();

/** u11S2信息栏人名与认证信息上下间距 */
extern CGFloat kUFS2VerifiedLabelTopPadding();

/** u11S2加v的左右间距 */
extern CGFloat kUFS2VerifiedImageViewPadding();

/** U11S2来源图片边长 */
extern CGFloat kUFS2SourceViewImageSide();

/** U11S2名字的上边距 */
extern CGFloat kUFS2NameLabelTopPadding();

/** U11S2信息栏距离内容的间距 */
extern CGFloat kUFS2PaddingSourceImageToContent();

/** 微头条图片之间的间距 */
extern CGFloat kUFW1PaddingImageView();

extern CGFloat kUFWenDaButtonWidth();

extern CGFloat kUFWenDaButtonHeight();

extern CGFloat kUFWenDaSourceLabelFontSize();

extern CGFloat kUFWenDaSourceLabelLeftPadding();


 
/** */
extern CGFloat kUFSourceLabelFontSize();

// MARK: - Other
@interface TTCellSetting : NSObject

+ (instancetype)shareSetting;
- (NSInteger)titleSpecial;
- (NSInteger)title;
- (NSInteger)abstract;
- (NSInteger)topic;
- (NSInteger)comment;
- (NSInteger)topicComment;
- (NSInteger)topicTitle;
- (NSInteger)topicContent;

@end
