//
//  WDMoreListCellViewModel.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/22.
//
//

#import "WDMoreListCellViewModel.h"
#import "WDAnswerEntity.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import <TTRoute/TTRoute.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTImage/TTImageInfosModel.h>
#import "WDCommonLogic.h"
#import "WDFollowDefines.h"
#import "WDListCellDataModel.h"
#import "WDMoreListCellLayoutModel.h"
#import "WDListViewModel.h"

@interface WDMoreListCellViewModel ()

@property (nonatomic, assign) BOOL isInvalidData;

@property (nonatomic, assign) BOOL isFollowButtonHidden;

@end

@implementation WDMoreListCellViewModel

- (instancetype)initWithDataModel:(WDListCellDataModel *)dataModel {
    if (self = [super init]) {
        self.dataModel = dataModel;
        self.ansEntity = dataModel.answerEntity;
        self.isFollowButtonHidden = self.ansEntity.user.isFollowing;
        NSString *authorUid = self.ansEntity.user.userID;
        if ([authorUid isEqualToString:[TTAccountManager userID]] || isEmptyString(authorUid)) {
            self.isFollowButtonHidden = YES;
        }
        self.isInvalidData =isEmptyString(self.ansEntity.contentAbstract.text);
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

#pragma mark - Tracker

- (NSDictionary *)commentButtonTappedTrackDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
    [dict setValue:@"answer_list" forKey:@"position"];
    [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
    return dict;
}

- (NSDictionary *)forwardButtonTappedTrackDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
    [dict setValue:@"answer_list" forKey:@"position"];
    [dict setValue:@"weitoutiao" forKey:@"platform"];
    [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
    return dict;
}

- (NSDictionary *)diggButtonTappedTrackDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
    [dict setValue:@"answer_list" forKey:@"position"];
    [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
    return dict;
}

- (NSDictionary *)followButtonTappedTrackDict {
    NSString *severSource = [NSString stringWithFormat:@"%ld",WDFriendFollowNewSourceWendaListCell];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"answer_list_answer_cell" forKey:@"source"];
    [dict setValue:@"answer_list" forKey:@"position"];
    [dict setValue:@"from_group" forKey:@"follow_type"];
    [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
    [dict setValue:self.ansEntity.user.userID forKey:@"to_user_id"];
    [dict setValue:severSource forKey:@"sever_source"];
    return dict;
}

- (void)cellDidSelectedWithGdExtJson:(NSDictionary *)gdExtJson {
    if (isEmptyString(self.ansEntity.answerSchema)) {
        return;
    }
    
    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.ansEntity.answerSchema] userInfo:nil];
    [self sendTrackWithLabel:@"fold_answer"];
}

- (void)sendTrackWithLabel:(NSString *)label
{
    if (isEmptyString(label)) {
        return;
    }
    [TTTracker event:kWDWendaListViewControllerUMEventName label:label];
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
