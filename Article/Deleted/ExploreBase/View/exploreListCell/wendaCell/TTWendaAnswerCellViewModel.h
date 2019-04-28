//
//  TTWendaAnswerCellViewModel.h
//  Article
//
//  Created by wangqi.kaisa on 2017/10/12.
//

#import <Foundation/Foundation.h>

/*
 * 10.12  在feed展示的问答回答cell类中的实际内容展示view所对应的vm类
 *        做高度缓存，被迫引入一些UI，这样原则上是错误的；之后应该会引入一个新的用于计算和缓存高度和布局的类
 *        要区分feed频道和关注频道
 * 11.10  行数按UGC标准做修改：首页，默认行数n=3，最大行数m=6；关注频道，默认行数n=6，最大行数m=8。不超过最大行数，显示默认行数（最后+...全文），否则全部显示。
 * 12.15  处理user模型为空的情况
 * 12.18  上面文字行数m,n由服务端下发：defaultlines & maxlines
 *        点击答案图片是进全屏显示还是进详情页由服务端控制
 *        点赞／转发按钮位置，文字大小由服务端（settings下发）字段控制
 * 12.19  做如果主体内容未获得则不展示的优化
 * 12.21  点击小图关注频道默认进预览，推荐默认进详情
 * 1.24   在story中隐藏dislike按钮
 * 1.31   切换账号时清空之前的layoutDict，主要是为了解决followButton是否显示问题
 */

/*
 *关注逻辑：
 * 未关注时：展示关注按钮，头像旁不展示关注与否相关文案；点击切换状态，文案不更新；跳转个人页面切换状态，文案不更新，按钮切换状态
 * 已关注时：不展示关注按钮，头像旁展示已关注文案；跳转个人页面切换状态，文案更新，按钮隐藏依旧
 * 也就是按钮展示时，更新按钮状态；按钮不展示时，更新文案内容
 * 展示按钮时：
 * 未关注点击按钮，成功后展开推荐用户卡片；dislike按钮变sanjiao按钮；点击可切换展开收起状态
 * 已关注点击按钮，成功后收起推荐用户卡片；sanjiao按钮变dislike按钮
 * 此处需要直接修改按钮状态，避免等待通知后闪动一下
 */

@class WDPersonModel;
@class WDAnswerEntity;
@class WDQuestionEntity;
@class ExploreOrderedData;
@class TTWendaAnswerCellViewModel;
@class TTWendaAnswerCellLayoutModel;
@class WDForwardStructModel;

typedef NS_ENUM(NSInteger, TTWendaAnswerLayoutType)
{
    TTWendaAnswerLayoutTypeNotUGC = 0,
    TTWendaAnswerLayoutTypeUGC = 1,
};

@interface TTWendaAnswerCellLayoutModelManager : NSObject

+ (instancetype)sharedInstance;

- (TTWendaAnswerCellLayoutModel *)getCellBaseModelFromOrderedData:(ExploreOrderedData *)orderedData;

@end

@interface TTWendaAnswerCellLayoutModel: NSObject

@property (nonatomic, strong, readonly) TTWendaAnswerCellViewModel *viewModel;

@property (nonatomic, assign, readonly) TTWendaAnswerLayoutType answerLayoutType;

@property (nonatomic, assign, readonly) CGFloat cellCacheHeight;
@property (nonatomic, assign, readonly) CGFloat contentLabelHeight;
@property (nonatomic, assign, readonly) CGFloat questionLabelHeight;
@property (nonatomic, assign, readonly) CGFloat quoteViewHeight;
@property (nonatomic, assign, readonly) CGFloat actionViewHeight;
@property (nonatomic, assign, readonly) CGFloat bottomLabelHeight;
@property (nonatomic, assign, readonly) CGFloat imagesBgViewHeight;
@property (nonatomic, strong, readonly) NSArray<NSValue *> *imageViewRects;
@property (nonatomic, assign, readonly) NSInteger answerLinesCount;
@property (nonatomic, assign, readonly) NSInteger displayImageCount;
@property (nonatomic, assign, readonly) NSInteger maxImageCount;
@property (nonatomic, assign, readonly) BOOL isFollowButtonHidden;

@property (nonatomic, assign, readonly) BOOL isBottomLabelAndLineHidden;

@property (nonatomic, assign) BOOL isExpanded;

@property (nonatomic, assign) BOOL needCalculateLayout; // 是否需要计算：首次／用户调整字体／iPad旋转屏幕／推人卡片展开收起

+ (TTWendaAnswerCellLayoutModel *)getCellLayoutModelFromOrderedData:(ExploreOrderedData *)orderedData;

- (void)calculateLayoutIfNeedWithCellWidth:(CGFloat)cellWidth;

- (BOOL)showTopSepView;

- (BOOL)showBottomSepView;

- (CGFloat)horizontalPadding;

+ (CGFloat)feedQuestionTitleContentFontSize;

+ (CGFloat)feedQuestionTitleContentLineHeight;

+ (CGFloat)feedAnswerTitleContentFontSize;

+ (CGFloat)feedAnswerTitleContentLineHeight;

+ (CGFloat)feedAnswerAbstractContentFontSize;

+ (CGFloat)feedAnswerAbstractContentLineHeight;

+ (CGFloat)feedAnswerAbstractContentLineSpace;

@end

@interface TTWendaAnswerCellViewModel : NSObject

@property (nonatomic, strong, readonly) ExploreOrderedData *orderedData;
@property (nonatomic, strong, readonly) WDQuestionEntity *questionEntity;
@property (nonatomic, strong, readonly) WDAnswerEntity *answerEntity;
@property (nonatomic, strong, readonly) WDPersonModel *userEntity;
@property (nonatomic, strong, readonly) WDForwardStructModel* repostParams;

@property (nonatomic, copy, readonly) NSString *uniqueId;

@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *avatarUrl;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *actionTitle;
@property (nonatomic, copy, readonly) NSString *introInfo;
@property (nonatomic, copy, readonly) NSString *userAuthInfo;
@property (nonatomic, copy, readonly) NSString *userDecoration;
@property (nonatomic, copy, readonly) NSString *reason;

@property (nonatomic, copy, readonly) NSString *questionTitle;
@property (nonatomic, copy, readonly) NSString *questionShowTitle;
@property (nonatomic, copy, readonly) NSString *answerTitle;
@property (nonatomic, copy, readonly) NSString *answerId;
@property (nonatomic, copy, readonly) NSString *questionId;

@property (nonatomic, strong, readonly) TTImageInfosModel *questionImageModel; 
@property (nonatomic, strong, readonly) NSArray *dislikeWords;

@property (nonatomic, assign, readonly) BOOL hasRead;
@property (nonatomic, assign, readonly) BOOL isFollowed;
@property (nonatomic, assign, readonly) BOOL isInitialFollowed;
@property (nonatomic, assign, readonly) BOOL hasAnswerImage;
@property (nonatomic, assign, readonly) BOOL tapImageJump;

// 是否为有效数据
@property (nonatomic, assign, readonly) BOOL isInvalidData;

// 是否在UGC的Story中
@property (nonatomic, assign, readonly) BOOL isInUGCStory;
// 是否在关注频道中
@property (nonatomic, assign, readonly) BOOL isInFollowChannel;

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData;

- (NSString *)secondLineContent;

- (NSString *)bottomContent;

- (NSString *)diggContent;

- (NSString *)commentContent;

- (NSString *)forwardContent;

- (void)afterDiggAnswer;

- (void)afterCancelDiggAnswer;

- (void)afterForwardAnswerToUGCIsComment:(BOOL)isComment;

- (void)updateNewFollowStateWithValue:(BOOL)isFollowing;

- (void)enterUserInfoPage;

- (void)enterAnswerListPage;

- (void)enterAnswerDetailPage;

- (void)enterAnswerDetailPageFromComment;

- (void)trackFollowButtonClicked;

- (void)trackCancelFollowButtonClicked;

- (void)trackDiggButtonClicked;

- (void)trackCancelDiggButtonClicked;

- (void)trackCommentButtonClicked;

- (void)trackForwardButtonClicked;

- (void)trackThumbImageFullScreenShowClick;

@end
