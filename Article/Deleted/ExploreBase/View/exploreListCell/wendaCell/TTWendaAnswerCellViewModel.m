//
//  TTWendaAnswerCellViewModel.m
//  Article
//
//  Created by wangqi.kaisa on 2017/10/12.
//

#import "TTWendaAnswerCellViewModel.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import "ExploreOrderedData+TTBusiness.h"
#import "TTWenda.h"
#import "WDPersonModel.h"
#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
#import "TTVerifyIconHelper.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import <AKWDPlugin/WDTrackerHelper.h>
#import <TTAccountSDK/TTAccount.h>
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import <TTImpression/TTRelevantDurationTracker.h>
#import "TTUGCDefine.h"
#import "TTKitchenHeader.h"
#import "TTUGCDefine.h"

@interface TTWendaAnswerCellLayoutModelManager ()<TTAccountMulticastProtocol>

@property (nonatomic, strong) NSMutableDictionary *layoutModelDict;

@end

@implementation TTWendaAnswerCellLayoutModelManager

+ (instancetype)sharedInstance
{
    static TTWendaAnswerCellLayoutModelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTWendaAnswerCellLayoutModelManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layoutModelDict = [NSMutableDictionary dictionary];
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (TTWendaAnswerCellLayoutModel *)getCellBaseModelFromOrderedData:(ExploreOrderedData *)orderedData {
    if (isEmptyString(orderedData.uniqueID)) {
        return nil;
    }
    NSString *key = [NSString stringWithFormat:@"%@", orderedData.uniqueID];
    TTWendaAnswerCellLayoutModel *layoutModel = [self.layoutModelDict objectForKey:key];
    if (layoutModel) {
        return layoutModel;
    }
    layoutModel = [TTWendaAnswerCellLayoutModel getCellLayoutModelFromOrderedData:orderedData];
    [self.layoutModelDict setObject:layoutModel forKey:key];
    return layoutModel;
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogin {
    [self.layoutModelDict removeAllObjects];
}

@end

@interface TTWendaAnswerCellLayoutModel()

@property (nonatomic, strong) TTWendaAnswerCellViewModel *viewModel;

@property (nonatomic, assign) TTWendaAnswerLayoutType answerLayoutType;

@property (nonatomic, assign) CGFloat cellWidth; // 上次计算缓存高度时所用的宽度
@property (nonatomic, assign) CGFloat cellCacheHeight; // 上次计算所得到的高度
@property (nonatomic, assign) CGFloat contentLabelHeight;  // 上次计算所得到的主体内容文字高度
@property (nonatomic, assign) CGFloat questionLabelHeight;  // 上次计算所得到的问题描述文字高度
@property (nonatomic, assign) CGFloat quoteViewHeight;
@property (nonatomic, assign) CGFloat actionViewHeight;
@property (nonatomic, assign) CGFloat bottomLabelHeight;
@property (nonatomic, assign) CGFloat imagesBgViewHeight;
@property (nonatomic, strong) NSArray<NSValue *> *imageViewRects;
@property (nonatomic, assign) NSInteger answerLinesCount;
@property (nonatomic, assign) NSInteger displayImageCount;
@property (nonatomic, assign) NSInteger maxImageCount;
@property (nonatomic, assign) BOOL isFollowButtonHidden;
@property (nonatomic, assign) BOOL isBottomLabelAndLineHidden;

@end

@implementation TTWendaAnswerCellLayoutModel

+ (TTWendaAnswerCellLayoutModel *)getCellLayoutModelFromOrderedData:(ExploreOrderedData *)orderedData {
    TTWendaAnswerCellLayoutModel *baseModel = [[TTWendaAnswerCellLayoutModel alloc] initWithOrderedData:orderedData];
    return baseModel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData {
    if (self = [super init]) {
        self.viewModel = [[TTWendaAnswerCellViewModel alloc] initWithOrderedData:orderedData];
        self.maxImageCount = 3;
        self.isFollowButtonHidden = self.viewModel.isInitialFollowed;
        self.answerLayoutType = self.viewModel.orderedData.ttWenda.answerLayoutType;
        [self addNotification];
    }
    return self;
}

- (BOOL)showTopSepView {
    return !self.viewModel.orderedData.preCellHasBottomPadding;
}

- (BOOL)showBottomSepView {
    return !self.viewModel.orderedData.nextCellHasTopPadding;
}

#pragma mark - Calculate layout

- (void)calculateLayoutIfNeedWithCellWidth:(CGFloat)cellWidth {
    if (self.cellWidth != cellWidth) {
        self.cellWidth = cellWidth;
        self.needCalculateLayout = YES;
    }
    if (self.needCalculateLayout) {
        if (self.viewModel.isInvalidData) {
            self.cellCacheHeight = 0;
        }
        else {
            self.cellCacheHeight = (self.answerLayoutType == TTWendaAnswerLayoutTypeUGC) ? [self calculateTotalCellHeightUgcStyle] : [self calculateTotalCellHeightNotUgcStyle];
        }
        self.needCalculateLayout = NO;
    }
}

- (CGFloat)calculateTotalCellHeightNotUgcStyle {
    CGFloat totalHeight = [self calculateUserInfoViewLayout];
    CGFloat contentHeaderPadding = [TTDeviceUIUtils tt_padding:3.0];
    totalHeight += contentHeaderPadding;
    
    if (self.isExpanded) {
        totalHeight += [self calculateRecommendCardViewLayout];
        totalHeight += 8;
    }
    totalHeight += [self calculateContentLabelLayout];
    totalHeight += [TTDeviceUIUtils tt_padding:5.0];
    totalHeight += [self calculateQuoteViewLayout];
    totalHeight += [TTDeviceUIUtils tt_padding:7.0];
    totalHeight += [self calculateBottomLabelLayout];
    totalHeight += [TTDeviceUIUtils tt_padding:7.0];
    totalHeight += [self calculateActionViewLayout];
    
    return totalHeight;
}

- (CGFloat)calculateTotalCellHeightUgcStyle {
    CGFloat totalHeight = [self calculateUserInfoViewLayout];
    
    if (self.isExpanded) {
        totalHeight += [self calculateRecommendCardViewLayout];
        totalHeight += 8;
    }
    totalHeight += [self calculateQuestionLabelLayout];
    totalHeight += [TTDeviceUIUtils tt_padding:3.0];
    totalHeight += [self calculateAnswerLabelLayout];
    if (self.viewModel.hasAnswerImage) {
        totalHeight += [TTDeviceUIUtils tt_padding:9.0];
        totalHeight += [self calculateAnswerImagesViewLayout];
    }
    if ([[TTKitchenMgr sharedInstance] getBOOL:kKCUGCU13ReadNumShowControl]) {
        self.isBottomLabelAndLineHidden = NO;
        totalHeight += [TTDeviceUIUtils tt_padding:7.0];
        totalHeight += [self calculateBottomLabelLayout];
        totalHeight += [TTDeviceUIUtils tt_padding:7.0];
        totalHeight += [self calculateActionViewLayout];
    } else {
        self.isBottomLabelAndLineHidden = YES;
        self.actionViewHeight = 44;
        totalHeight += self.actionViewHeight;
    }
    
    return totalHeight;
}

- (CGFloat)calculateUserInfoViewLayout {
    CGFloat headerHeight = [TTDeviceUIUtils tt_padding:15.0] + 36.0 + [TTDeviceUIUtils tt_padding:8.0];
    return headerHeight;
}

- (CGFloat)calculateRecommendCardViewLayout {
    if (self.isExpanded) {
        return WDPadding(224);
    }
    return 0;
}

- (CGFloat)calculateQuestionLabelLayout {
    CGFloat contentLabelHeight = 0;
    CGFloat contentWidth = self.cellWidth - [self horizontalPadding]*2;
    CGFloat fontSize = [TTWendaAnswerCellLayoutModel feedQuestionTitleContentFontSize];
    CGFloat lineHeight = [TTWendaAnswerCellLayoutModel feedQuestionTitleContentLineHeight];
    contentLabelHeight = [WDLayoutHelper heightOfText:self.viewModel.questionShowTitle
                                             fontSize:fontSize
                                            lineWidth:contentWidth
                                           lineHeight:lineHeight
                                     maxNumberOfLines:2];
    NSInteger lineCount = (contentLabelHeight / lineHeight);
    self.questionLabelHeight = lineCount * lineHeight;
    return self.questionLabelHeight;
}

- (CGFloat)calculateAnswerLabelLayout {
    CGFloat contentWidth = self.cellWidth - [self horizontalPadding]*2;
    CGFloat fontSize = [TTWendaAnswerCellLayoutModel feedAnswerTitleContentFontSize];
    CGFloat lineHeight = [TTWendaAnswerCellLayoutModel feedAnswerTitleContentLineHeight];
    CGFloat contentLabelHeight = [WDLayoutHelper heightOfText:self.viewModel.answerTitle
                                                     fontSize:fontSize
                                                    lineWidth:contentWidth
                                                   lineHeight:lineHeight
                                             maxNumberOfLines:0];
    NSInteger lineCount = (contentLabelHeight / lineHeight);
    if (self.viewModel.isInFollowChannel) {
        if (lineCount <= self.viewModel.orderedData.ttWenda.answerTextMaxLines) {
            self.answerLinesCount = 0;
        }
        else {
            self.answerLinesCount = self.viewModel.orderedData.ttWenda.answerTextDefaultLines;
        }
    }
    else {
        if (lineCount <= 6) {
            self.answerLinesCount = 0;
        }
        else {
            self.answerLinesCount = 3;
        }
    }
    if (self.answerLinesCount != 0) {
        contentLabelHeight = [WDLayoutHelper heightOfText:self.viewModel.answerTitle
                                                 fontSize:fontSize
                                                lineWidth:contentWidth
                                               lineHeight:lineHeight
                                         maxNumberOfLines:self.answerLinesCount];
        lineCount = (contentLabelHeight / lineHeight);
    }
    self.contentLabelHeight = lineCount * lineHeight;
    return self.contentLabelHeight;
}

- (CGFloat)calculateContentLabelLayout {
    CGFloat contentLabelHeight = 0;
    CGFloat contentWidth = self.cellWidth - [self horizontalPadding]*2;
    CGFloat fontSize = [TTWendaAnswerCellLayoutModel feedAnswerAbstractContentFontSize];
    CGFloat lineHeight = [TTWendaAnswerCellLayoutModel feedAnswerAbstractContentLineHeight];
    contentLabelHeight = [WDLayoutHelper heightOfText:self.viewModel.answerTitle
                                             fontSize:fontSize
                                            lineWidth:contentWidth
                                           lineHeight:lineHeight
                                     maxNumberOfLines:0];
    NSInteger lineCount = (contentLabelHeight / lineHeight);
    if (self.viewModel.isInFollowChannel) {
        if (lineCount <= 8) {
            self.answerLinesCount = 0;
        }
        else {
            self.answerLinesCount = 6;
        }
    }
    else {
        if (lineCount <= 6) {
            self.answerLinesCount = 0;
        }
        else {
            self.answerLinesCount = 3;
        }
    }
    if (self.answerLinesCount != 0) {
        contentLabelHeight = [WDLayoutHelper heightOfText:self.viewModel.answerTitle
                                                 fontSize:fontSize
                                                lineWidth:contentWidth
                                               lineHeight:lineHeight
                                         maxNumberOfLines:self.answerLinesCount];
        lineCount = (contentLabelHeight / lineHeight);
    }
    
    CGFloat lineSpacePadding = [TTWendaAnswerCellLayoutModel feedAnswerAbstractContentLineSpace];
    contentLabelHeight += (contentLabelHeight / lineHeight - 1) * lineSpacePadding;
    BOOL isOverTwoLine = lineCount > 2;
    if (isOverTwoLine) {
        contentLabelHeight += (lineCount - 1);
    }
    self.contentLabelHeight = contentLabelHeight + 3;
    return self.contentLabelHeight - 2;
}

- (CGFloat)calculateAnswerImagesViewLayout {
    // 图片显示规则
    // 单图：横，竖 375*X 竖长 375*400 横长 375*125
    // 2，4图：（屏幕宽-3）／2 1:1
    // 1，3，5，6，7，8，9图：（屏幕宽-3*2）／3 1:1
    // 单图规则来自“UGCU13CellLayoutModel”类
    CGFloat space = 3;
    NSInteger fullCount = self.viewModel.answerEntity.thumbImageList.count;
    NSInteger displayCount = MIN(fullCount, self.maxImageCount);
    CGSize imageSize;
    CGFloat positionX = 0;
    CGFloat positionY = 0;
    if (displayCount <= 0) { // 无图
        self.imagesBgViewHeight = 0;
        return self.imagesBgViewHeight;
    }
    else if (displayCount == 1) {
        TTImageInfosModel *largeImageModel = self.viewModel.answerEntity.largeImageList.firstObject;
        CGFloat largeImageWidth = MAX(largeImageModel.width, 1.f);
        CGFloat largeImageHeight = MAX(largeImageModel.height, 1.f);
        double ratio = (double) largeImageModel.height / (double) largeImageModel.width;
        if (ratio < 125.f / 375.f) { // 通栏显示125:375图, 超出的部分裁掉（裁右侧部分）, 且右下角显示横图标志
            imageSize = CGSizeMake(self.cellWidth, largeImageModel.height);
        } else if (ratio >= 125.f / 375.f && ratio <= 400.f / 375.f) { // 按原图比例通栏显示
            imageSize = CGSizeMake(self.cellWidth, (self.cellWidth * largeImageHeight / largeImageWidth));
        } else if (ratio > 400.f / 375.f && ratio <= 750.f / 375.f) { // 通栏显示400:375图, 超出的部分裁掉（智能裁图／裁上下，留中间）
            imageSize = CGSizeMake(self.cellWidth, (self.cellWidth * 400.f / 375.f));
        } else { // 通栏显示400：375图, 超出的部分裁掉（裁下方部分）, 且右上角显示长图标志
            imageSize = CGSizeMake(self.cellWidth, (self.cellWidth * 400.f / 375.f));
        }
    }
    else if (displayCount == 2 || displayCount == 4) {
        CGFloat imageWidth = (self.cellWidth - space) / 2;
        CGFloat imageHeight = imageWidth;
        imageSize = CGSizeMake(imageWidth, imageHeight);
    }
    else {
        CGFloat imageWidth = (self.cellWidth - space*2) / 3;
        CGFloat imageHeight = imageWidth;
        imageSize = CGSizeMake(imageWidth, imageHeight);
    }
    
    NSMutableArray<NSValue *> *rects = [NSMutableArray arrayWithCapacity:displayCount];
    for (NSUInteger i = 0; i < displayCount; i++) {
        CGRect rect = CGRectMake(positionX, positionY, imageSize.width, imageSize.height);
        if (CGRectGetMaxX(rect) > self.cellWidth) {
            positionX = 0;
            positionY = CGRectGetMaxY(rect) + space;
            rect = CGRectMake(positionX, positionY, imageSize.width, imageSize.height);
        }
        positionX = CGRectGetMaxX(rect) + space;
        [rects addObject:[NSValue valueWithCGRect:rect]];
    }
    self.displayImageCount = displayCount;
    self.imageViewRects = rects;
    self.imagesBgViewHeight = positionY + imageSize.height;
    return self.imagesBgViewHeight;
}

- (CGFloat)calculateQuoteViewLayout {
    self.quoteViewHeight = 70;
    return self.quoteViewHeight;
}

- (CGFloat)calculateBottomLabelLayout {
    self.bottomLabelHeight = (self.answerLayoutType == TTWendaAnswerLayoutTypeUGC) ? 18 : 12;
    return self.bottomLabelHeight;
}

- (CGFloat)calculateActionViewLayout {
    self.actionViewHeight = 37;
    return self.actionViewHeight;
}

- (CGFloat)horizontalPadding {
    if (self.viewModel.isInFollowChannel) {
        return 14;
    }
    return 15;
}

+ (CGFloat)feedQuestionTitleContentFontSize {
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 17.f : 15.f;
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize];
}

+ (CGFloat)feedQuestionTitleContentLineHeight {
    CGFloat lineHeight = [TTDeviceHelper isScreenWidthLarge320] ? 24.f : 21.f;
    return [WDUIHelper wdUserSettingTransferWithLineHeight:lineHeight];
}

+ (CGFloat)feedAnswerTitleContentFontSize {
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 17.f : 15.f;
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize];
}

+ (CGFloat)feedAnswerTitleContentLineHeight {
    CGFloat lineHeight = [TTDeviceHelper isScreenWidthLarge320] ? 24.f : 21.f;
    return [WDUIHelper wdUserSettingTransferWithLineHeight:lineHeight];
}

+ (CGFloat)feedAnswerAbstractContentFontSize {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 18.f;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 17.f;
    } else {
        fontSize = 15.f;
    }
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize];
}

+ (CGFloat)feedAnswerAbstractContentLineHeight {
    return [TTWendaAnswerCellLayoutModel feedAnswerAbstractContentFontSize];
}

+ (CGFloat)feedAnswerAbstractContentLineSpace {
    CGFloat lineHeight = floorf([TTWendaAnswerCellLayoutModel feedAnswerAbstractContentFontSize] * 1.4);
    CGFloat lineSpace = [WDUIHelper wdUserSettingTransferWithLineHeight:lineHeight] - [TTWendaAnswerCellLayoutModel feedAnswerAbstractContentLineHeight];
    lineSpace = MIN(8, lineSpace);
    return lineSpace;
}

#pragma mark - Notificatoin

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingFontSizeChanged:)
                                                 name:kSettingFontSizeChangedNotification
                                               object:nil];
}

- (void)settingFontSizeChanged:(NSNotification *)notification {
    self.needCalculateLayout = YES;
}

@end

@interface TTWendaAnswerCellViewModel()

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) TTWenda *wenda;
@property (nonatomic, strong) WDQuestionEntity *questionEntity;
@property (nonatomic, strong) WDAnswerEntity *answerEntity;
@property (nonatomic, strong) WDPersonModel *userEntity;
@property (nonatomic, strong) WDForwardStructModel* repostParams;

@property (nonatomic, copy) NSString *uniqueId;

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, copy) NSString *introInfo;
@property (nonatomic, copy) NSString *userAuthInfo;
@property (nonatomic, copy) NSString *userDecoration;
@property (nonatomic, copy) NSString *reason;

@property (nonatomic, copy) NSString *questionTitle;
@property (nonatomic, copy) NSString *questionShowTitle;
@property (nonatomic, copy) NSString *answerTitle;
@property (nonatomic, copy) NSString *answerId;
@property (nonatomic, copy) NSString *questionId;

@property (nonatomic, copy) NSString *userSchema;
@property (nonatomic, copy) NSString *writeAnswerSchema;
@property (nonatomic, copy) NSString *answerListSchema;
@property (nonatomic, copy) NSString *answerDetailSchema;
@property (nonatomic, copy) NSString *commentDetailSchema;

@property (nonatomic, strong) TTImageInfosModel *questionImageModel;
@property (nonatomic, strong) NSArray *dislikeWords;

@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isInitialFollowed;

@property (nonatomic, assign) BOOL hasAnswerImage;
@property (nonatomic, assign) BOOL tapImageJump;

@property (nonatomic, assign) double createTime;

@property (nonatomic, assign) BOOL isInvalidData;

@property (nonatomic, assign) BOOL isInUGCStory;

@property (nonatomic, assign) BOOL isInFollowChannel;

@end

@implementation TTWendaAnswerCellViewModel

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData {
    if (self = [super init]) {
        self.orderedData = orderedData;
        self.wenda = orderedData.ttWenda;
        self.questionEntity = orderedData.ttWenda.questionEntity;
        self.answerEntity = orderedData.ttWenda.answerEntity;
        self.userEntity = orderedData.ttWenda.userEntity;
        self.repostParams = orderedData.ttWenda.repostParams;
        self.uniqueId = orderedData.ttWenda.groupID;
        self.avatarUrl = orderedData.ttWenda.userEntity.avatarURLString;
        self.username = orderedData.ttWenda.userEntity.name;
        if ([self.username isEqualToString:@"(null)"]) {
            self.username = @"";
        }
        self.userSchema = orderedData.ttWenda.userSchema;
        self.userId = orderedData.ttWenda.userEntity.userID;
        self.userAuthInfo = orderedData.ttWenda.userEntity.userAuthInfo;
        self.userDecoration = orderedData.ttWenda.userEntity.userDecoration;
        
        if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:self.userAuthInfo]) {
            NSString *verifiedContent = [TTVerifyIconHelper verifyContentOfVerifyInfo:self.userAuthInfo];
            if (!isEmptyString(verifiedContent)) {
                self.introInfo = verifiedContent;
            }
        }
        
        self.isInitialFollowed = orderedData.ttWenda.userEntity.isFollowing;         // 最初的值
        if ([self.userId isEqualToString:[TTAccountManager userID]] || isEmptyString(self.userId)) {
            self.isInitialFollowed = YES;
        }
        
        self.dislikeWords = orderedData.ttWenda.filterWords;
        self.actionTitle = orderedData.ttWenda.recommendReason;
        self.createTime = orderedData.ttWenda.answerEntity.createTime.doubleValue;
        
        self.answerDetailSchema = orderedData.ttWenda.answerEntity.answerSchema;
        self.answerListSchema = orderedData.ttWenda.questionEntity.listSchema;
        self.commentDetailSchema = orderedData.ttWenda.commentSchema;
        
        self.answerTitle = orderedData.ttWenda.answerEntity.abstract;
        self.answerId = orderedData.ttWenda.answerEntity.ansid;
        self.questionTitle = orderedData.ttWenda.questionEntity.title;
        self.questionShowTitle = [NSString stringWithFormat:@"问题：%@",self.questionTitle];
        self.questionId = orderedData.ttWenda.questionEntity.qid;
        
        if (orderedData.ttWenda.questionEntity.content.thumbImageList.count > 0) {
            self.questionImageModel = orderedData.ttWenda.questionEntity.content.thumbImageList.firstObject;
        }
        
        self.hasAnswerImage = (self.answerEntity.thumbImageList.count > 0);
        
        self.isInUGCStory = [orderedData.categoryID isEqualToString:kStoryCategoryID];
        
        self.isInFollowChannel = [orderedData.categoryID isEqualToString:kTTFollowCategoryID];
        
        if (self.isInFollowChannel) {
            self.tapImageJump = self.wenda.answerImageJumpType ? !self.wenda.answerImageJumpType.boolValue : 0;
        }
        else {
            self.tapImageJump = self.wenda.answerImageJumpType ? !self.wenda.answerImageJumpType.boolValue : 1;
        }
        
        self.isInvalidData = (isEmptyString(self.answerTitle) || [self.answerTitle isEqualToString:@"(null)"]);
    }
    return self;
}

#pragma mark - Content

- (BOOL)isFollowed {
    return self.userEntity.isFollowing;
}

- (BOOL)hasRead {
    return self.wenda.hasRead.boolValue;
}

- (NSString *)secondLineContent {
    if (self.isInFollowChannel) {
        return [self secondLineContentInFollowChannel];
    } else if (self.isInUGCStory) {
        return [self secondLineContentInUGCStory];
    } else {
        return [self secondLineContentInFeedChannel];
    }
}

- (NSString *)secondLineContentInFeedChannel {
    NSString *secondLine = @"";
    if (!isEmptyString(self.introInfo)) {
        if (self.isFollowed && self.isInitialFollowed) {
            secondLine = [NSString stringWithFormat:@"%@ · %@",@"已关注",self.introInfo];
        }
        else {
            secondLine = self.introInfo;
        }
    }
    else {
        if (self.isFollowed && self.isInitialFollowed) {
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

- (NSString *)secondLineContentInUGCStory {
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
    return [NSString stringWithFormat:@"%@阅读",[TTBusinessManager formatCommentCount:[self.answerEntity.readCount longLongValue]]];
}

- (NSString *)diggContent {
    NSString *digg = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:[self.answerEntity.diggCount longLongValue]]];
    if (isEmptyString(digg) || [digg isEqualToString:@"0"]) {
        digg = @"赞";
    }
    return digg;
}

- (NSString *)commentContent {
    NSString *comment = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:[self.answerEntity.commentCount longLongValue]]];
    if (isEmptyString(comment) || [comment isEqualToString:@"0"]) {
        comment = @"评论";
    }
    return comment;
}

- (NSString *)forwardContent {
    NSString *forward = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:[self.answerEntity.forwardCount longLongValue]]];
    if (isEmptyString(forward) || [forward isEqualToString:@"0"]) {
        forward = @"转发";
    }
    return forward;
}

#pragma mark - Action

- (void)afterDiggAnswer {
    self.answerEntity.diggCount = @([self.answerEntity.diggCount longLongValue] + 1);
    self.answerEntity.isDigg = YES;
    [self.answerEntity save];
}

- (void)afterCancelDiggAnswer {
    self.answerEntity.diggCount = (self.answerEntity.diggCount.longLongValue >= 1) ? @(self.answerEntity.diggCount.longLongValue - 1) : @0;
    self.answerEntity.isDigg = NO;
    [self.answerEntity save];
}

- (void)afterForwardAnswerToUGCIsComment:(BOOL)isComment {
    if (isComment) {
        self.answerEntity.commentCount = @([self.answerEntity.commentCount longLongValue] + 1);
    }
    self.answerEntity.forwardCount = @([self.answerEntity.forwardCount longLongValue] + 1);
    [self.answerEntity save];
}

- (void)updateNewFollowStateWithValue:(BOOL)isFollowing {
    if (self.isFollowed == isFollowing) {
        return;
    }
    self.userEntity.isFollowing = isFollowing;
    [self.wenda save];
}

- (void)enterUserInfoPage {
    if (!isEmptyString(self.userSchema)) {
        NSString *groupId = self.answerId;
        NSString *result = [WDTrackerHelper schemaTrackForPersonalHomeSchema:self.userSchema categoryName:self.orderedData.categoryID fromPage:@"list_wenda" groupId:groupId profileUserId:self.userId];
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:result]];
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

#pragma mark - Tracker

- (void)trackFollowButtonClicked {
    [self eventV3:@"rt_follow" extra:@{@"follow_type":@"from_group"} userIDKey:@"to_user_id"];
}

- (void)trackCancelFollowButtonClicked {
    [self eventV3:@"rt_unfollow" extra:@{@"follow_type":@"from_group"} userIDKey:@"to_user_id"];
}

- (void)trackDiggButtonClicked {
    [self eventV3:@"rt_like" extra:@{@"is_follow":[NSString stringWithFormat:@"%u", self.isFollowed]}];
}

- (void)trackCancelDiggButtonClicked {
    [self eventV3:@"rt_unlike" extra:@{@"is_follow":[NSString stringWithFormat:@"%u", self.isFollowed]}];
}

- (void)trackCommentButtonClicked {
    [self eventV3:@"click_comment" extra:@{@"is_follow":[NSString stringWithFormat:@"%u", self.isFollowed]}];
}

- (void)trackForwardButtonClicked {
    [self eventV3:@"rt_share_to_platform" extra:@{@"share_platform":@"weitoutiao",
                                                            @"is_follow":[NSString stringWithFormat:@"%u", self.isFollowed]}];
}

- (void)trackThumbImageFullScreenShowClick {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"33" forKey:@"gtype"];
    if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        [params setValue:@"click_headline" forKey:@"enter_from"];
    }
    else{
        [params setValue:@"click_category" forKey:@"enter_from"];
    }
    [params setValue:self.orderedData.categoryID forKey:@"category_name"];
    [params setValue:@"wenda" forKey:@"article_type"];
    [params setValue:[NSString stringWithFormat:@"%u", self.isFollowed] forKey:@"is_follow"];
    [params setValue:self.orderedData.uniqueID forKey:@"group_id"];
    [params setValue:self.questionId forKey:@"qid"];
    [params setValue:self.answerId forKey:@"ansid"];
    [params setValue:self.orderedData.logPb forKey:@"log_pb"];
    [params setValue:self.orderedData.categoryID forKey:@"source"];
    [TTTrackerWrapper eventV3:@"cell_click_picture" params:params];
}

- (void)eventV3:(NSString *)event extra:(NSDictionary *)extra {
    [self eventV3:event extra:extra userIDKey:nil];
}

- (void)eventV3:(NSString *)event extra:(NSDictionary *)extra userIDKey:(NSString *)userIDKey {
    NSMutableDictionary *params = nil;
    if ([extra count] > 0) {
        params = [NSMutableDictionary dictionaryWithDictionary:extra];
    }
    else{
        params = [NSMutableDictionary dictionary];
    }
    
    if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        [params setValue:@"click_headline" forKey:@"enter_from"];
    }
    else{
        [params setValue:@"click_category" forKey:@"enter_from"];
    }
    [params setValue:self.orderedData.categoryID forKey:@"category_name"];
    [params setValue:self.orderedData.uniqueID forKey:@"group_id"];
    [params setValue:self.questionId forKey:@"qid"];
    [params setValue:self.answerId forKey:@"ansid"];
    if (!isEmptyString(userIDKey)){
        [params setValue:self.userId forKey:userIDKey];
    }
    else{
        [params setValue:self.userId forKey:@"user_id"];
    }
    [TTTrackerWrapper eventV3:event params:params];
}

@end


