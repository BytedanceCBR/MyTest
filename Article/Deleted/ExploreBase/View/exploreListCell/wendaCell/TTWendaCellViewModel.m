//
//  TTWendaCellViewModel.m
//  Article
//
//  Created by wangqi.kaisa on 2017/7/27.
//
//

#import "TTWendaCellViewModel.h"
#import "TTVerifyIconHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTWenda.h"
//#import "TTPersonModel.h"
#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
#import "TTRoute.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <AKWDPlugin/WDTrackerHelper.h>
#import "TTKitchenHeader.h"
#import <TTImpression/TTRelevantDurationTracker.h>
#import <TTBaseLib/TTDeviceHelper.h>

@interface TTWendaCellViewModelManager ()

@property (nonatomic, strong) NSMutableDictionary *viewModelDict;

@end

@implementation TTWendaCellViewModelManager

+ (instancetype)sharedInstance
{
    static TTWendaCellViewModelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTWendaCellViewModelManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.viewModelDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (TTWendaCellViewModel *)getCellBaseModelFromOrderedData:(ExploreOrderedData *)orderedData {
    if (isEmptyString(orderedData.uniqueID)) {
        return nil;
    }
    NSString *key = [NSString stringWithFormat:@"%@", orderedData.uniqueID];
    TTWendaCellViewModel *viewModel = [self.viewModelDict objectForKey:key];
    if (viewModel) {
        return viewModel;
    }
    viewModel = [TTWendaCellViewModel getCellBaseModelFromOrderedData:orderedData];
    [self.viewModelDict setObject:viewModel forKey:key];
    return viewModel;
}

@end

@interface TTWendaCellViewModel ()

@property (nonatomic, strong) ExploreOrderedData *orderedData;

@property (nonatomic, assign)  TTWendaCellViewType cellShowType;

@property (nonatomic, copy)   NSString *uniqueId;

@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, copy)   NSString *avatarUrl;
@property (nonatomic, copy)   NSString *username;
@property (nonatomic, copy)   NSString *actionTitle;
@property (nonatomic, copy)   NSString *introInfo;
@property (nonatomic, copy)   NSString *userAuthInfo;
@property (nonatomic, copy)   NSString *userDecoration;

@property (nonatomic, copy)   NSString *questionTitle;
@property (nonatomic, copy)   NSString *answerId;
@property (nonatomic, copy)   NSString *questionId;

@property (nonatomic, copy)   NSString *secondLineContent;
@property (nonatomic, copy)   NSString *bottomContent;
@property (nonatomic, copy)   NSString *diggContent;
@property (nonatomic, copy)   NSString *commentContent;
@property (nonatomic, copy)   NSString *forwardContent;

@property (nonatomic, copy)   NSString *userSchema;
@property (nonatomic, copy)   NSString *writeAnswerSchema;
@property (nonatomic, copy)   NSString *answerListSchema;
@property (nonatomic, copy)   NSString *answerDetailSchema;
@property (nonatomic, copy)   NSString *commentDetailSchema;


@property (nonatomic, strong) TTImageInfosModel *questionImageModel;
@property (nonatomic, strong) NSArray *threeImageModels;

@property (nonatomic, strong) NSArray *dislikeWords;

@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isFollowButtonHidden;

@property (nonatomic, assign) BOOL isInvalidData;

@property (nonatomic, assign) double createTime;

@property (nonatomic, assign) CGFloat cellWidth; // 上次计算缓存高度时所用的宽度
@property (nonatomic, assign) CGFloat cellCacheHeight; // 上次计算所得到的高度
@property (nonatomic, assign) CGFloat contentLabelHeight;  // 上次计算所得到的主体内容文字高度
@property (nonatomic, assign) CGFloat isThreeLineInRightImage;  // 左文右图情况下是否三行文字
//@property (nonatomic, assign) BOOL needCalculateLayout; // 是否需要计算：首次／用户调整字体／日夜间模式切换／iPad旋转屏幕／推人卡片展开收起

@end

@implementation TTWendaCellViewModel

+ (TTWendaCellViewModel *)getCellBaseModelFromOrderedData:(ExploreOrderedData *)orderedData {
    TTWendaCellViewModel *baseModel = [[TTWendaCellViewModel alloc] initWithOrderedData:orderedData];
    return baseModel;
}

+ (CGFloat)feedQuestionAbstractContentFontSize {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 20.f;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 19.f;
    } else {
        fontSize = 17.f;
    }
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize];
}

- (void)dealloc {
    [self removeNotification];
}

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData {
    if (self = [super init]) {
        
        self.orderedData = orderedData;
        self.wenda = orderedData.ttWenda;
        
        self.uniqueId = self.wenda.groupID;
        
        self.avatarUrl = self.wenda.userEntity.avatarURLString;
        self.username = self.wenda.userEntity.name;
        if ([self.username isEqualToString:@"(null)"]) {
            self.username = @"";
        }
        self.userSchema = self.wenda.userSchema;
        self.userId = self.wenda.userEntity.userID;
        self.userAuthInfo = self.wenda.userEntity.userAuthInfo;
        self.userDecoration = self.wenda.userEntity.userDecoration;
        if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:self.userAuthInfo]) {
            NSString *verifiedContent = [TTVerifyIconHelper verifyContentOfVerifyInfo:self.userAuthInfo];
            if (!isEmptyString(verifiedContent)) {
                self.introInfo = verifiedContent;
            }
        }
        
        self.isFollowButtonHidden = self.wenda.userEntity.isFollowing;         // 最初的值
        if ([self.userId isEqualToString:[TTAccountManager userID]] || isEmptyString(self.userId)) {
            self.isFollowButtonHidden = YES;
        }
        
        self.dislikeWords = self.wenda.filterWords;
        
        if (self.wenda.wendaFeedType == TTWendaFeedCellTypeQuestion) {
        
            self.actionTitle = self.wenda.recommendReason;
            
            self.createTime = self.wenda.questionEntity.createTime.doubleValue;
            
            self.answerListSchema = self.wenda.questionEntity.listSchema;
            self.writeAnswerSchema = self.wenda.questionEntity.postAnswerSchema;
            
            self.questionTitle = self.wenda.questionEntity.title;
            self.questionId = self.wenda.questionEntity.qid;
            
            self.cellShowType = TTWendaCellViewTypeQuestionPureTitle;
            NSInteger imageCount = self.wenda.questionEntity.content.thumbImageList.count;
            
            if (self.wenda.questionImageType == 1 && imageCount > 0) {
                self.cellShowType = TTWendaCellViewTypeQuestionRightImage;
                self.questionImageModel = self.wenda.questionEntity.content.thumbImageList.firstObject;
            }
            else if (self.wenda.questionImageType == 2 && imageCount > 2) {
                self.cellShowType = TTWendaCellViewTypeQuestionThreeImage;
                self.threeImageModels = self.wenda.questionEntity.content.thumbImageList;
            }
        }
        
        self.isInvalidData = (isEmptyString(self.questionTitle) || [self.questionTitle isEqualToString:@"(null)"]);
        
        [self addNotification];
        
    }
    return self;
}

- (void)calculateLayoutIfNeedWithOrderedData:(ExploreOrderedData *)orderedData cellWidth:(CGFloat)cellWidth listType:(ExploreOrderedDataListType)listType {
    
    if (self.cellWidth != cellWidth) {
        self.cellWidth = cellWidth;
        self.needCalculateLayout = YES;
    }
    
    // 在这里计算高度和布局
    if (self.needCalculateLayout) {
        
        if (self.isInvalidData) {
            self.cellCacheHeight = 0;
            self.needCalculateLayout = NO;
            return;
        }
        
        CGFloat totalHeight = [self calculateUserInfoViewLayout];
        CGFloat contentHeaderPadding = [TTDeviceUIUtils tt_padding:3.0];
        totalHeight += contentHeaderPadding;
        
        if (self.cellShowType == TTWendaCellViewTypeQuestionPureTitle) {
            totalHeight += [self calculateContentLabelLayout];
            totalHeight += [TTDeviceUIUtils tt_padding:14.0];
            totalHeight += [self calculateBottomLabelLayout];
            totalHeight += [TTDeviceUIUtils tt_padding:14.0];
            totalHeight += [TTDeviceHelper ssOnePixel];
        }
        else if (self.cellShowType == TTWendaCellViewTypeQuestionRightImage) {
            CGFloat contentLabelHeight = [self calculateContentLabelLayout];
            CGFloat rightImageHeight = [self calculateRightImageLayout].height;
            if (self.isThreeLineInRightImage) {
                if (contentLabelHeight > rightImageHeight) {
                    totalHeight += contentLabelHeight;
                    totalHeight += [TTDeviceUIUtils tt_padding:14.0];
                }
                else {
                    totalHeight += rightImageHeight;
                    totalHeight += [TTDeviceUIUtils tt_padding:10.0];
                }
                totalHeight += [self calculateBottomLabelLayout];
                totalHeight += [TTDeviceUIUtils tt_padding:14.0];
                totalHeight += [TTDeviceHelper ssOnePixel];
            }
            else {
                totalHeight += rightImageHeight;
                totalHeight += [TTDeviceUIUtils tt_padding:14.0];
                totalHeight += [TTDeviceHelper ssOnePixel];
            }
        }
        else if (self.cellShowType == TTWendaCellViewTypeQuestionThreeImage) {
            totalHeight += [self calculateContentLabelLayout];
            totalHeight += [TTDeviceUIUtils tt_padding:5.0];
            totalHeight += [self calculateThreeImageLayout].height;
            totalHeight += [TTDeviceUIUtils tt_padding:14.0];
            totalHeight += [self calculateBottomLabelLayout];
            totalHeight += [TTDeviceUIUtils tt_padding:14.0];
            totalHeight += [TTDeviceHelper ssOnePixel];
        }
        
        self.cellCacheHeight = totalHeight;
        self.needCalculateLayout = NO;
    }
}

- (CGFloat)calculateUserInfoViewLayout {
    CGFloat headerHeight = [TTDeviceUIUtils tt_padding:15.0] + 36.0 + [TTDeviceUIUtils tt_padding:8.0];
    return headerHeight;
}

- (CGFloat)calculateContentLabelLayout {
    CGFloat contentLabelHeight = 0;
    CGFloat contentWidth = self.cellWidth - 15*2;
    if (self.cellShowType == TTWendaCellViewTypeQuestionPureTitle) {
        CGFloat fontSize = [TTWendaCellViewModel feedQuestionAbstractContentFontSize];
        contentLabelHeight = [WDLayoutHelper heightOfText:self.questionTitle
                                                 fontSize:fontSize
                                                lineWidth:contentWidth
                                               lineHeight:fontSize
                                         maxNumberOfLines:2];
        CGFloat lineSpacePadding = 6;
        contentLabelHeight += (contentLabelHeight / fontSize - 1) * lineSpacePadding;
    }
    else if (self.cellShowType == TTWendaCellViewTypeQuestionRightImage) {
        CGFloat fontSize = [TTWendaCellViewModel feedQuestionAbstractContentFontSize];
        CGFloat contentLabelWidth = contentWidth - [self calculateRightImageLayout].width - [TTDeviceUIUtils tt_padding:12];
        contentLabelHeight = [WDLayoutHelper heightOfText:self.questionTitle
                                                 fontSize:fontSize
                                                lineWidth:contentLabelWidth
                                               lineHeight:fontSize
                                         maxNumberOfLines:3];
        BOOL isThreeLine = (contentLabelHeight / fontSize) > 2;
        self.isThreeLineInRightImage = isThreeLine;
        CGFloat lineSpacePadding = isThreeLine ? 7 : 6;
        contentLabelHeight += (contentLabelHeight / fontSize - 1) * lineSpacePadding;
    }
    else if (self.cellShowType == TTWendaCellViewTypeQuestionThreeImage) {
        CGFloat fontSize = [TTWendaCellViewModel feedQuestionAbstractContentFontSize];
        contentLabelHeight = [WDLayoutHelper heightOfText:self.questionTitle
                                                 fontSize:fontSize
                                                lineWidth:contentWidth
                                               lineHeight:fontSize
                                         maxNumberOfLines:2];
        CGFloat lineSpacePadding = 6;
        contentLabelHeight += (contentLabelHeight / fontSize - 1) * lineSpacePadding;
    }
    self.contentLabelHeight = contentLabelHeight + 3;
    return self.contentLabelHeight - 2;
}

- (CGSize)calculateRightImageLayout {
    CGFloat mediumImageHeight = [TTDeviceUIUtils tt_padding:74];
    CGFloat mediumImageWidth = [TTDeviceUIUtils tt_padding:113];
    return CGSizeMake(mediumImageWidth, mediumImageHeight);
}

- (CGSize)calculateThreeImageLayout {
    CGSize mediumImageSize = [self calculateRightImageLayout];
    CGFloat threeImageWidth = (self.cellWidth - 15*2 - 6)/3;
    CGFloat threeImageHeight = ceilf(threeImageWidth * mediumImageSize.height / mediumImageSize.width);
    return CGSizeMake(threeImageWidth, threeImageHeight);
}

- (CGFloat)calculateBottomLabelLayout {
    CGFloat bottomLabelHeight = 12;
    return bottomLabelHeight;
}

- (CGFloat)calculateActionViewLayout {
    CGFloat actionViewHeight = 37;
    return actionViewHeight;
}

- (void)enterUserInfoPage {
    if (!isEmptyString(self.userSchema)) {
        NSString *groupId = self.questionId;
        NSString *result = [WDTrackerHelper schemaTrackForPersonalHomeSchema:self.userSchema categoryName:self.orderedData.categoryID fromPage:@"list_wenda" groupId:groupId profileUserId:self.userId];
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:result]];
    }
}

- (void)enterAnswerQuestionPage {
    if (!isEmptyString(self.writeAnswerSchema)) {
        NSString *schema = self.writeAnswerSchema;
        schema = [schema stringByAppendingString:@"&source=channel_write_answer"];
        [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:schema] userInfo:nil];
    }
}

- (void)enterAnswerDetailPage {
    self.wenda.hasRead = @(YES);
    [self.wenda save];
    if (!isEmptyString(self.answerDetailSchema)) {
        [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:self.answerDetailSchema] userInfo:nil];
        [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
    }
}

- (void)enterAnswerDetailPageFromComment {
    self.wenda.hasRead = @(YES);
    [self.wenda save];
    if (!isEmptyString(self.commentDetailSchema)) {
        [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:self.commentDetailSchema] userInfo:nil];
        [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
    }
}

- (void)enterAnswerListPage {
    self.wenda.hasRead = @(YES);
    [self.wenda save];
    if (!isEmptyString(self.answerListSchema)) {
        [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:self.answerListSchema] userInfo:nil];
        [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
    }
}

- (NSString *)secondLineContentIsFollowChannel:(BOOL)isFollowChannel {
    if (isFollowChannel) {
        return [self secondLineContentInFollowChannel];
    }
    return [self secondLineContentInFeedChannel];
}

- (NSString *)secondLineContentInFeedChannel {
    NSString *secondLine = @"";
    if (!isEmptyString(self.introInfo)) {
        if (self.isFollowed && self.isFollowButtonHidden) {
            secondLine = [NSString stringWithFormat:@"%@ · %@",@"已关注",self.introInfo];
        }
        else {
            secondLine = self.introInfo;
        }
    }
    else {
        if (self.isFollowed && self.isFollowButtonHidden) {
            secondLine = @"已关注";
        }
    }
    return secondLine;
}

- (NSString *)secondLineContentInFollowChannel {
    NSString *secondLine = @"";
    NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:self.createTime];
    if (!isEmptyString(self.introInfo)) {
        secondLine = [NSString stringWithFormat:@"%@ · %@",publishTime,self.introInfo];
    }
    else {
        secondLine = publishTime;
    }
    return secondLine;
}

- (NSString *)bottomContent {
    NSString *bottom = [NSString stringWithFormat:@"%@回答  %@收藏", [TTBusinessManager formatCommentCount:[self.wenda.questionEntity.allAnsCount longLongValue]], [TTBusinessManager formatCommentCount:[self.wenda.questionEntity.followCount longLongValue]]];
    return bottom;
}

- (BOOL)isFollowed {
    return self.wenda.userEntity.isFollowing;
}

- (BOOL)showBottomLine {
    return !self.orderedData.nextCellHasTopPadding;
}

#pragma mark - Notificatoin

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeChangeNotification:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingFontSizeChanged:)
                                                 name:kSettingFontSizeChangedNotification
                                               object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)themeChangeNotification:(NSNotification *)notification {
    self.needCalculateLayout = YES;
}

- (void)settingFontSizeChanged:(NSNotification *)notification {
    self.needCalculateLayout = YES;
}

@end
