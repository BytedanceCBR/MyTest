//
//  TTWendaCellViewModel.h
//  Article
//
//  Created by wangqi.kaisa on 2017/7/27.
//
//

#import <Foundation/Foundation.h>
#import "ExploreCellBase.h"

/*
 * 7.27  在feed展示的问答cell类中的实际内容展示view所对应的vm类
 * 8.4   做高度缓存，被迫引入一些UI，这样原则上是错误的；之后应该会引入一个新的用于计算和缓存高度和布局的类
 * 8.29  区分feed频道和关注频道
 */

typedef NS_ENUM(NSInteger, TTWendaCellViewType)
{
    TTWendaCellViewTypeQuestionPureTitle,      //无图模式
    TTWendaCellViewTypeQuestionRightImage,     //右图模式
    TTWendaCellViewTypeQuestionThreeImage,     //三图模式
};

@class TTWenda;
@class TTWendaCellViewModel;
@class ExploreOrderedData;

@interface TTWendaCellViewModelManager : NSObject

+ (instancetype)sharedInstance;

- (TTWendaCellViewModel *)getCellBaseModelFromOrderedData:(ExploreOrderedData *)orderedData;

@end

@interface TTWendaCellViewModel : NSObject

@property (nonatomic, strong)  TTWenda *wenda;

@property (nonatomic, assign, readonly)  TTWendaCellViewType cellShowType;

@property (nonatomic, copy, readonly)   NSString *uniqueId;

@property (nonatomic, copy, readonly)   NSString *userId;
@property (nonatomic, copy, readonly)   NSString *avatarUrl;
@property (nonatomic, copy, readonly)   NSString *username;
@property (nonatomic, copy, readonly)   NSString *actionTitle;
@property (nonatomic, copy, readonly)   NSString *introInfo;
@property (nonatomic, copy, readonly)   NSString *userAuthInfo;
@property (nonatomic, copy, readonly)   NSString *userDecoration;

@property (nonatomic, copy, readonly)   NSString *questionTitle;
@property (nonatomic, copy, readonly)   NSString *answerId;
@property (nonatomic, copy, readonly)   NSString *questionId;

@property (nonatomic, copy, readonly)   NSString *secondLineContent;
@property (nonatomic, copy, readonly)   NSString *bottomContent;

@property (nonatomic, strong, readonly) TTImageInfosModel *questionImageModel;
@property (nonatomic, strong, readonly) NSArray *threeImageModels;
@property (nonatomic, strong, readonly) NSArray *dislikeWords;

@property (nonatomic, assign, readonly) BOOL isFollowed;
@property (nonatomic, assign, readonly) BOOL isFollowButtonHidden;

// 是否为有效数据
@property (nonatomic, assign, readonly) BOOL isInvalidData;

@property (nonatomic, assign) BOOL showBottomLine;

@property (nonatomic, assign) BOOL needCalculateLayout; // 是否需要计算：首次／用户调整字体／日夜间模式切换／iPad旋转屏幕／推人卡片展开收起

// layout
@property (nonatomic, assign, readonly) CGFloat cellCacheHeight;
@property (nonatomic, assign, readonly) CGFloat contentLabelHeight;
@property (nonatomic, assign, readonly) CGFloat isThreeLineInRightImage;

+ (TTWendaCellViewModel *)getCellBaseModelFromOrderedData:(ExploreOrderedData *)orderedData;

+ (CGFloat)feedQuestionAbstractContentFontSize;

- (void)calculateLayoutIfNeedWithOrderedData:(ExploreOrderedData *)orderedData cellWidth:(CGFloat)cellWidth listType:(ExploreOrderedDataListType)listType;

- (NSString *)secondLineContentIsFollowChannel:(BOOL)isFollowChannel;

- (void)enterUserInfoPage;

- (void)enterAnswerQuestionPage;

- (void)enterAnswerListPage;

@end
