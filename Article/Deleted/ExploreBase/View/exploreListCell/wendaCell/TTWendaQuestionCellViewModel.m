//
//  TTWendaQuestionCellViewModel.m
//  Article
//
//  Created by wangqi.kaisa on 2017/10/12.
//

#import "TTWendaQuestionCellViewModel.h"
#import <TTBaseLib/TTBaseMacro.h>
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
#import "WDImageBoxView.h"
#import <TTImpression/TTRelevantDurationTracker.h>
#import "TTKitchenHeader.h"
#import "TTUGCDefine.h"

@interface TTWendaQuestionCellLayoutModelManager ()<TTAccountMulticastProtocol>

@property (nonatomic, strong) NSMutableDictionary *layoutModelDict;

@end

@implementation TTWendaQuestionCellLayoutModelManager

+ (instancetype)sharedInstance
{
    static TTWendaQuestionCellLayoutModelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTWendaQuestionCellLayoutModelManager alloc] init];
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

- (TTWendaQuestionCellLayoutModel *)getCellBaseModelFromOrderedData:(ExploreOrderedData *)orderedData {
    if (isEmptyString(orderedData.uniqueID)) {
        return nil;
    }
    NSString *key = [NSString stringWithFormat:@"%@", orderedData.uniqueID];
    TTWendaQuestionCellLayoutModel *layoutModel = [self.layoutModelDict objectForKey:key];
    if (layoutModel) {
        return layoutModel;
    }
    layoutModel = [TTWendaQuestionCellLayoutModel getCellLayoutModelFromOrderedData:orderedData];
    [self.layoutModelDict setObject:layoutModel forKey:key];
    return layoutModel;
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogin {
    [self.layoutModelDict removeAllObjects];
}

@end

@interface TTWendaQuestionCellLayoutModel()

@property (nonatomic, strong) TTWendaQuestionCellViewModel *viewModel;

@property (nonatomic, assign) TTWendaQuestionLayoutType questionLayoutType;

@property (nonatomic, assign) CGFloat cellWidth; // 上次计算缓存高度时所用的宽度
@property (nonatomic, assign) CGFloat cellCacheHeight; // 上次计算所得到的高度
@property (nonatomic, assign) CGFloat contentLabelHeight;  // 上次计算所得到的主体内容文字高度
@property (nonatomic, assign) CGFloat questionImageWidth;
@property (nonatomic, assign) CGFloat questionImageHeight;
@property (nonatomic, assign) CGFloat questionDescViewHeight;
@property (nonatomic, assign) CGFloat bottomLabelHeight;
@property (nonatomic, assign) CGFloat answerViewHeight;
@property (nonatomic, assign) BOOL isFollowButtonHidden;
@property (nonatomic, assign) BOOL isBottomLabelAndLineHidden;

@end

@implementation TTWendaQuestionCellLayoutModel

+ (TTWendaQuestionCellLayoutModel *)getCellLayoutModelFromOrderedData:(ExploreOrderedData *)orderedData {
    TTWendaQuestionCellLayoutModel *layoutModel = [[TTWendaQuestionCellLayoutModel alloc] initWithOrderedData:orderedData];
    return layoutModel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData {
    if (self = [super init]) {
        self.viewModel = [[TTWendaQuestionCellViewModel alloc] initWithOrderedData:orderedData];
        self.isFollowButtonHidden = self.viewModel.isInitialFollowed;
        self.questionLayoutType = self.viewModel.orderedData.ttWenda.questionLayoutType;
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
            self.cellCacheHeight = (self.questionLayoutType == TTWendaQuestionLayoutTypeUGC) ? [self calculateTotalCellHeightUgcStyle] : [self calculateTotalCellHeightNotUgcStyle];
        }
        self.needCalculateLayout = NO;
    }
}

- (CGFloat)calculateTotalCellHeightNotUgcStyle {
    CGFloat totalHeight = [self calculateUserInfoViewLayout];
    CGFloat contentHeaderPadding = [TTDeviceUIUtils tt_padding:3.0];
    totalHeight += contentHeaderPadding;
    
    totalHeight += [self calculateContentLabelLayout];
    totalHeight += [TTDeviceUIUtils tt_padding:10.0];
    
    if (self.viewModel.viewType == TTWendaQuestionCellViewTypeOneImage) {
        totalHeight += [self calculateSingleQuestionImageLayout];
        totalHeight += [TTDeviceUIUtils tt_padding:10.0];
        
    }
    else if (self.viewModel.viewType == TTWendaQuestionCellViewTypeTwoImage || self.viewModel.viewType == TTWendaQuestionCellViewTypeThreeImage) {
        totalHeight += [self calculateMultipQuestionImageLayout];
        totalHeight += [TTDeviceUIUtils tt_padding:10.0];
    }
    
    totalHeight += [self calculateBottomLabelLayout];
    totalHeight += [TTDeviceUIUtils tt_padding:10.0];
    totalHeight += [self calculateAnswerViewLayout];
    
    return totalHeight;
}

- (CGFloat)calculateTotalCellHeightUgcStyle {
    CGFloat totalHeight = [self calculateUserInfoViewLayout];
    
    totalHeight += [WDUIHelper wdUserSettingTransferWithLineHeight:25.0];
    totalHeight += [TTDeviceUIUtils tt_padding:9.0];
    totalHeight += [self calculateQuestionDescViewLayout];
    if ([[TTKitchenMgr sharedInstance] getBOOL:kKCUGCU13ReadNumShowControl]) {
        self.isBottomLabelAndLineHidden = NO;
        totalHeight += [TTDeviceUIUtils tt_padding:9.0];
        totalHeight += [self calculateBottomLabelLayout];
        totalHeight += [TTDeviceUIUtils tt_padding:10.0];
        totalHeight += [self calculateAnswerViewLayout];
    } else {
        self.isBottomLabelAndLineHidden = YES;
        self.answerViewHeight = 44;
        totalHeight += self.answerViewHeight;
    }
    
    return totalHeight;
}

- (CGFloat)calculateUserInfoViewLayout {
    CGFloat headerHeight = [TTDeviceUIUtils tt_padding:15.0] + 36.0 + [TTDeviceUIUtils tt_padding:8.0];
    return headerHeight;
}

- (CGFloat)calculateContentLabelLayout {
    CGFloat contentLabelHeight = 0;
    CGFloat contentWidth = self.cellWidth - 15*2;
    CGFloat fontSize = [TTWendaQuestionCellLayoutModel feedQuestionAbstractContentFontSize];
    CGFloat lineHeight = fontSize;
    contentLabelHeight = [WDLayoutHelper heightOfText:self.viewModel.questionTitle
                                             fontSize:fontSize
                                            lineWidth:contentWidth
                                           lineHeight:lineHeight
                                     maxNumberOfLines:2];
    CGFloat lineSpacePadding = 7;
    contentLabelHeight += (contentLabelHeight / lineHeight - 1) * lineSpacePadding;
    self.contentLabelHeight = contentLabelHeight + 3;
    return self.contentLabelHeight - 2;
}

- (CGFloat)calculateSingleQuestionImageLayout {
    CGFloat constraintWidth = self.cellWidth - 15*2;
    TTImageInfosModel *firstImageModel = self.viewModel.imageModels.firstObject;
    CGSize size = {firstImageModel.width, firstImageModel.height};
    CGSize resultSize;
    if (firstImageModel.imageType == TTImageFileTypeGIF) {
        resultSize = [WDImageBoxView limitedSizeForGif:size maxLimit:constraintWidth];
    } else {
        resultSize = [WDImageBoxView limitedSizeWithSize:size maxLimit:constraintWidth/2];
    }
    self.questionImageWidth = resultSize.width;
    self.questionImageHeight = resultSize.height;
    return self.questionImageHeight;
}

- (CGFloat)calculateMultipQuestionImageLayout {
    CGFloat constraintWidth = self.cellWidth - 15*2;
    self.questionImageWidth = ceilf((constraintWidth - 6)/3);
    self.questionImageHeight = self.questionImageWidth;
    return self.questionImageHeight;
}

- (CGFloat)calculateBottomLabelLayout {
    self.bottomLabelHeight = (self.questionLayoutType == TTWendaQuestionLayoutTypeUGC) ? 18 : 12;
    return self.bottomLabelHeight;
}

- (CGFloat)calculateAnswerViewLayout {
    self.answerViewHeight = ([KitchenMgr getBOOL:kKCUGCU13ActionRegionLayoutStyle]) ? 38 : 37;
    return self.answerViewHeight;
}

- (CGFloat)calculateQuestionDescViewLayout {
    CGFloat questionViewHeight = 0;
    if (self.viewModel.hasQuestionImage) {
        CGFloat leftImageWidth = [TTDeviceUIUtils tt_padding:128];
        CGFloat leftImageHeight = [TTDeviceUIUtils tt_padding:90];
        self.questionImageWidth = leftImageWidth;
        self.questionImageHeight = leftImageHeight;
        questionViewHeight = leftImageHeight;
    }
    else {
        CGFloat leftImageWidth = [TTDeviceUIUtils tt_padding:51];
        CGFloat leftImageHeight = [TTDeviceUIUtils tt_padding:51];
        self.questionImageWidth = leftImageWidth;
        self.questionImageHeight = leftImageHeight;
        questionViewHeight = [TTDeviceUIUtils tt_padding:74];
    }
    self.questionDescViewHeight = questionViewHeight;
    return questionViewHeight;
}

+ (CGFloat)feedQuestionAbstractContentFontSize {
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

+ (CGFloat)feedPostQuestionLabelFontSize {
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 17.f : 15.f;
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize];
}

+ (CGFloat)feedPostQuestionLabelLineHeight {
    CGFloat lineHeight = [TTDeviceHelper isScreenWidthLarge320] ? 25.f : 22.f;
    return [WDUIHelper wdUserSettingTransferWithLineHeight:lineHeight];
}

+ (CGFloat)feedQuestionTitleFontSize {
    return WDFontSize(16);
}

+ (CGFloat)feedQuestionTitleLineHeight {
    return WDPadding(21);
}

+ (CGFloat)feedQuestionTitleLayoutLineHeight {
    return WDPadding(23);
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

@interface TTWendaQuestionCellViewModel()

@property (nonatomic, assign) TTWendaQuestionCellViewType viewType;

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) TTWenda *wenda;
@property (nonatomic, strong) WDQuestionEntity *questionEntity;
@property (nonatomic, strong) WDPersonModel *userEntity;

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
@property (nonatomic, copy) NSString *questionId;

@property (nonatomic, copy) NSString *userSchema;
@property (nonatomic, copy) NSString *writeAnswerSchema;
@property (nonatomic, copy) NSString *answerListSchema;

@property (nonatomic, strong) NSArray *imageModels;
@property (nonatomic, strong) NSArray *dislikeWords;

@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isInitialFollowed;

@property (nonatomic, assign) BOOL hasQuestionImage;

@property (nonatomic, assign) double createTime;

@property (nonatomic, assign) BOOL isInvalidData;

@property (nonatomic, assign) BOOL isInUGCStory;

@property (nonatomic, assign) BOOL isInFollowChannel;

@end

@implementation TTWendaQuestionCellViewModel

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData {
    if (self = [super init]) {
        self.orderedData = orderedData;
        self.wenda = orderedData.ttWenda;
        self.questionEntity = orderedData.ttWenda.questionEntity;
        self.userEntity = orderedData.ttWenda.userEntity;
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
        self.createTime = orderedData.ttWenda.questionEntity.createTime.doubleValue;
        
        self.answerListSchema = orderedData.ttWenda.questionEntity.listSchema;
        self.writeAnswerSchema = orderedData.ttWenda.questionEntity.postAnswerSchema;
        
        self.questionTitle = self.questionEntity.title;
        self.questionId = orderedData.ttWenda.questionEntity.qid;

        self.imageModels = orderedData.ttWenda.questionEntity.content.thumbImageList;
        NSInteger imageCount = orderedData.ttWenda.questionEntity.content.thumbImageList.count;
        
        self.viewType = TTWendaQuestionCellViewTypePureTitle;
        if (orderedData.ttWenda.questionImageType == 2 && imageCount > 2) {
            self.viewType = TTWendaQuestionCellViewTypeThreeImage;
        } else if (orderedData.ttWenda.questionImageType == 3 && imageCount > 1) {
            self.viewType = TTWendaQuestionCellViewTypeTwoImage;
        } else if (orderedData.ttWenda.questionImageType == 1 && imageCount > 0) {
            self.viewType = TTWendaQuestionCellViewTypeOneImage;
        }
        
        self.hasQuestionImage = (self.imageModels.count > 0);
        
        self.isInUGCStory = [orderedData.categoryID isEqualToString:kStoryCategoryID];
        
        self.isInFollowChannel = [orderedData.categoryID isEqualToString:kTTFollowCategoryID];
        
        self.isInvalidData = (isEmptyString(self.questionTitle) || [self.questionTitle isEqualToString:@"(null)"]);
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
        } else {
            secondLine = self.introInfo;
        }
    } else {
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
    } else {
        secondLine = publishTime;
    }
    return secondLine;
}

- (NSString *)secondLineContentInUGCStory {
    NSString *secondLine = @"";
    NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:self.createTime];
    if (!isEmptyString(self.introInfo)) {
        secondLine = [NSString stringWithFormat:@"%@ · %@",publishTime,self.introInfo];
    } else {
        secondLine = publishTime;
    }
    return secondLine;
}

- (NSString *)bottomContent {
    if (self.wenda.questionLayoutType == TTWendaQuestionLayoutTypeUGC) {
        return [NSString stringWithFormat:@"%@回答", [TTBusinessManager formatCommentCount:[self.questionEntity.allAnsCount longLongValue]]];
    }
    return [NSString stringWithFormat:@"%@回答  %@收藏", [TTBusinessManager formatCommentCount:[self.questionEntity.allAnsCount longLongValue]], [TTBusinessManager formatCommentCount:[self.questionEntity.followCount longLongValue]]];
}

#pragma mark - Action

- (void)updateNewFollowStateWithValue:(BOOL)isFollowing {
    if (self.isFollowed == isFollowing) {
        return;
    }
    self.userEntity.isFollowing = isFollowing;
    [self.wenda save];
}

- (void)enterUserInfoPage {
    if (!isEmptyString(self.userSchema)) {
        NSString *groupId = self.questionId;
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

- (void)enterAnswerQuestionPage {
    if (!isEmptyString(self.writeAnswerSchema)) {
        NSString *schema = self.writeAnswerSchema;
        schema = [schema stringByAppendingString:@"&source=channel_write_answer"];
        [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:schema] userInfo:nil];
    }
}

#pragma mark - Tracker

- (void)trackFollowButtonClicked {
    [self eventV3:@"rt_follow" extra:@{@"follow_type":@"from_group"} userIDKey:@"to_user_id"];
}

- (void)trackCancelFollowButtonClicked {
    [self eventV3:@"rt_unfollow" extra:@{@"follow_type":@"from_group"} userIDKey:@"to_user_id"];
}

- (void)trackAnswerQuestionButtonClicked {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:self.questionId forKey:@"qid"];
    [dict setValue:self.questionEntity.allAnsCount forKey:@"t_ans_num"];
    [dict setValue:self.questionEntity.niceAnsCount forKey:@"r_ans_num"];
    [TTTrackerWrapper eventV3:@"channel_write_answer" params:dict];
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
    if (!isEmptyString(userIDKey)){
        [params setValue:self.userId forKey:userIDKey];
    }
    else{
        [params setValue:self.userId forKey:@"user_id"];
    }
    [TTTrackerWrapper eventV3:event params:params];
}

@end
