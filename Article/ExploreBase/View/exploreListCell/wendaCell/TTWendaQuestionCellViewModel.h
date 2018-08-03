//
//  TTWendaQuestionCellViewModel.h
//  Article
//
//  Created by wangqi.kaisa on 2017/10/12.
//

#import <Foundation/Foundation.h>

/*
 * 10.12  在feed展示的问答提问cell类中的实际内容展示view所对应的vm类
 *        做高度缓存，被迫引入一些UI，这样原则上是错误的；之后应该会引入一个新的用于计算和缓存高度和布局的类
 *        要区分feed频道和关注频道
 * 12.15  处理user模型为空的情况
 * 12.19  做如果主体内容未获得则不展示的优化
 * 1.24   在story中隐藏dislike按钮
 * 1.31   切换账号时清空之前的layoutDict，主要是为了解决followButton是否显示问题
 */

@class WDPersonModel;
@class WDQuestionEntity;
@class ExploreOrderedData;
@class TTWendaQuestionCellViewModel;
@class TTWendaQuestionCellLayoutModel;

typedef NS_ENUM(NSInteger, TTWendaQuestionLayoutType)
{
    TTWendaQuestionLayoutTypeOld = 0,
    TTWendaQuestionLayoutTypeNew = 1,
    TTWendaQuestionLayoutTypeUGC = 2,
};

typedef NS_ENUM(NSInteger, TTWendaQuestionCellViewType)
{
    TTWendaQuestionCellViewTypePureTitle = 0,      //无图模式
    TTWendaQuestionCellViewTypeOneImage,           //单图模式
    TTWendaQuestionCellViewTypeTwoImage,           //双图模式
    TTWendaQuestionCellViewTypeThreeImage,         //三图模式
};

@interface TTWendaQuestionCellLayoutModelManager : NSObject

+ (instancetype)sharedInstance;

- (TTWendaQuestionCellLayoutModel *)getCellBaseModelFromOrderedData:(ExploreOrderedData *)orderedData;

@end

@interface TTWendaQuestionCellLayoutModel: NSObject

@property (nonatomic, strong, readonly) TTWendaQuestionCellViewModel *viewModel;

@property (nonatomic, assign, readonly) TTWendaQuestionLayoutType questionLayoutType;

@property (nonatomic, assign, readonly) CGFloat cellCacheHeight;
@property (nonatomic, assign, readonly) CGFloat contentLabelHeight;
@property (nonatomic, assign, readonly) CGFloat questionImageWidth;
@property (nonatomic, assign, readonly) CGFloat questionImageHeight;
@property (nonatomic, assign, readonly) CGFloat questionDescViewHeight;
@property (nonatomic, assign, readonly) CGFloat bottomLabelHeight;
@property (nonatomic, assign, readonly) CGFloat answerViewHeight;

@property (nonatomic, assign, readonly) BOOL isFollowButtonHidden;

@property (nonatomic, assign, readonly) BOOL isBottomLabelAndLineHidden;

@property (nonatomic, assign) BOOL needCalculateLayout; // 是否需要计算：首次／用户调整字体／iPad旋转屏幕

+ (TTWendaQuestionCellLayoutModel *)getCellLayoutModelFromOrderedData:(ExploreOrderedData *)orderedData;

- (void)calculateLayoutIfNeedWithCellWidth:(CGFloat)cellWidth;

- (BOOL)showTopSepView;

- (BOOL)showBottomSepView;

+ (CGFloat)feedQuestionAbstractContentFontSize;

+ (CGFloat)feedPostQuestionLabelFontSize;

+ (CGFloat)feedPostQuestionLabelLineHeight;

+ (CGFloat)feedQuestionTitleFontSize;

+ (CGFloat)feedQuestionTitleLineHeight;

+ (CGFloat)feedQuestionTitleLayoutLineHeight;

@end

@interface TTWendaQuestionCellViewModel : NSObject

@property (nonatomic, assign, readonly) TTWendaQuestionCellViewType viewType;

@property (nonatomic, strong, readonly) ExploreOrderedData *orderedData;
@property (nonatomic, strong, readonly) WDQuestionEntity *questionEntity;
@property (nonatomic, strong, readonly) WDPersonModel *userEntity;

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
@property (nonatomic, copy, readonly) NSString *questionId;

@property (nonatomic, strong, readonly) NSArray *imageModels;
@property (nonatomic, strong, readonly) NSArray *dislikeWords;

@property (nonatomic, assign, readonly) BOOL hasRead;
@property (nonatomic, assign, readonly) BOOL isFollowed;
@property (nonatomic, assign, readonly) BOOL isInitialFollowed;
@property (nonatomic, assign, readonly) BOOL hasQuestionImage;

// 是否为有效数据
@property (nonatomic, assign, readonly) BOOL isInvalidData;

// 是否在UGC的Story中
@property (nonatomic, assign, readonly) BOOL isInUGCStory;
// 是否在关注频道中
@property (nonatomic, assign, readonly) BOOL isInFollowChannel;

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData;

- (NSString *)secondLineContent;

- (NSString *)bottomContent;

- (void)updateNewFollowStateWithValue:(BOOL)isFollowing;

- (void)enterUserInfoPage;

- (void)enterAnswerListPage;

- (void)enterAnswerQuestionPage;

- (void)trackFollowButtonClicked;

- (void)trackCancelFollowButtonClicked;

- (void)trackAnswerQuestionButtonClicked;

@end


