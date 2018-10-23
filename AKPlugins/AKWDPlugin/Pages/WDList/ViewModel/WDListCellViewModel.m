//
//  WDListCellViewModel.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/14.
//
//

#import "WDListCellViewModel.h"
#import "WDAnswerEntity.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import <TTRoute/TTRoute.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTImage/TTImageInfosModel.h>
#import "WDCommonLogic.h"
#import "WDListCellDataModel.h"
#import "WDSettingHelper.h"
#import "WDListViewModel.h"

@interface WDListCellViewModel ()

@property (nonatomic, assign) BOOL isInvalidData;

@property (nonatomic, assign) BOOL isFollowButtonHidden;

@property (nonatomic, assign) BOOL isAnswerGetReward;

@property (nonatomic, assign) BOOL hasValidVideo;

@property (nonatomic, strong) WDVideoInfoStructModel *videoModel;

@end

@implementation WDListCellViewModel

- (instancetype)initWithDataModel:(WDListCellDataModel *)dataModel {
    if (self = [super init]) {
        self.dataModel = dataModel;
        self.ansEntity = dataModel.answerEntity;
        self.isFollowButtonHidden = self.ansEntity.user.isFollowing;
        NSString *authorUid = self.ansEntity.user.userID;
        if ([authorUid isEqualToString:[TTAccountManager userID]] || isEmptyString(authorUid)) {
            self.isFollowButtonHidden = YES;
        }
        if ([[WDSettingHelper sharedInstance_tt] isQuestionRewardUserViewShow]) {
            if (self.ansEntity.profitLabel) {
                self.isAnswerGetReward = YES;
            }
        }
        self.videoModel = nil;
        if (self.ansEntity.contentAbstract.video_list.count > 0 ) {
            self.videoModel = self.ansEntity.contentAbstract.video_list.firstObject;
        }
        if (self.videoModel && !isEmptyString(self.videoModel.video_id)) {
            self.hasValidVideo = YES;
        }
        self.isInvalidData = isEmptyString(self.ansEntity.contentAbstract.text) && !self.hasValidVideo;
    }
    return self;
}

#pragma mark - Getter

- (NSString *)secondLineContent {
    NSString *secondLine = @"";
    NSString *userDesc = self.ansEntity.user.userIntro;
    if (!isEmptyString(userDesc)) {
        if (self.ansEntity.user.isFollowing && self.isFollowButtonHidden) {
            secondLine = [NSString stringWithFormat:@"%@ · %@",@"已关注",userDesc];
        } else {
            secondLine = userDesc;
        }
    } else {
        if (self.ansEntity.user.isFollowing && self.isFollowButtonHidden) {
            secondLine = @"已关注";
        }
    }
    return secondLine;
}

- (NSString *)answerContentAbstract {
    NSString *abstract = nil;
    if (self.dataModel.layoutType == WDWendaListLayoutTypeLIGHT_ANSWER) {
        abstract = [self.ansEntity.contentAbstract.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else {
        abstract = [self trimSpaceFromOriginString:self.ansEntity.contentAbstract.text];
    }
    return abstract;
}

- (NSString *)bottomLabelContent {
    NSString *bottom = [NSString stringWithFormat:@"%@赞  %@阅读",[TTBusinessManager formatCommentCount:self.ansEntity.diggCount.longLongValue],[TTBusinessManager formatCommentCount:self.ansEntity.readCount.longLongValue]];
    if (self.dataModel.layoutType == WDWendaListLayoutTypeLIGHT_ANSWER) {
        bottom = [NSString stringWithFormat:@"%@阅读",[TTBusinessManager formatCommentCount:self.ansEntity.readCount.longLongValue]];
    }
    return bottom;
}

- (NSNumber *)diggCount {
    return self.ansEntity.diggCount;
}

- (NSNumber *)commentCount {
    return self.ansEntity.commentCount;
}

- (NSNumber *)forwardCount {
    return self.ansEntity.forwardCount;
}

- (NSString *)diggButtonContent {
    NSString *digg = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:self.ansEntity.diggCount.longLongValue]];
    if (isEmptyString(digg) || [digg isEqualToString:@"0"]) {
        digg = @"赞";
    }
    return digg;
}

- (NSString *)commentButtonContent {
    NSString *comment = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:self.ansEntity.commentCount.longLongValue]];
    if (isEmptyString(comment) || [comment isEqualToString:@"0"]) {
        comment = @"评论";
    }
    return comment;
}

- (NSString *)forwardButtonContent {
    NSString *forward = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:self.ansEntity.forwardCount.longLongValue]];
    if (isEmptyString(forward) || [forward isEqualToString:@"0"]) {
        forward = @"转发";
    }
    return forward;
}

- (NSString *)totalImageCountsContent {
    return [NSString stringWithFormat:@"%ld图",self.ansEntity.contentAbstract.thumb_image_list.count];
}

#pragma mark - Action

- (void)enterAnswerDetailPageFromComment {
    if (!isEmptyString(self.ansEntity.answerCommentSchema)) {
        [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:self.ansEntity.answerCommentSchema] userInfo:nil];
    }
}

- (void)forwardCurrentAnswerToUGC {
    Class aclass = NSClassFromString(@"TTWendaCellForwardUGCHelper");
    id forwardHelper = [[aclass alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([forwardHelper respondsToSelector:@selector(forwardUGCWithAnswerEntity:)]) {
        [forwardHelper performSelector:@selector(forwardUGCWithAnswerEntity:) withObject:self.ansEntity];
    }
#pragma clang diagnostic pop
}

- (void)cellDidSelectedWithGdExtJson:(NSDictionary *)gdExtJson {
    if (isEmptyString(self.ansEntity.answerSchema)) {
        return;
    }
    
    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.ansEntity.answerSchema] userInfo:nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:gdExtJson];
    [dict setValue:@"answer" forKey:@"label"];
    [dict setValue:self.ansEntity.ansid forKey:@"value"];
    [self sendTrackWithDict:dict];
}

- (void)sendTrackWithDict:(NSDictionary *)dictInfo
{
    if (![dictInfo isKindOfClass:[NSDictionary class]] ||
        [dictInfo count] == 0) {
        return;
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dictInfo];
    [dict setValue:kWDWendaListViewControllerUMEventName forKey:@"tag"];
    [dict setValue:@"umeng" forKey:@"category"];
    [TTTracker eventData:dict];
}

#pragma mark - Util

- (NSString *)trimSpaceFromOriginString:(NSString *)originString {
    NSString *string = [originString copy];
    if ([string length] > 0) {
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return string;
}

@end
