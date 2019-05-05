//
//  TTVVideoDetailCollectService.m
//  Article
//
//  Created by pei yun on 2017/4/21.
//
//

#import "TTVVideoDetailCollectService.h"
#import "ExploreItemActionManager.h"
#import "NewsDetailLogicManager.h"
#import "TTAccountManager.h"
#import "Article+TTADComputedProperties.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"
#import <libextobjc/extobjc.h>
#import "TTUIResponderHelper.h"
#import "NSDictionary+TTGeneratedContent.h"
#import <TTSettingsManager/TTSettingsManager.h>

extern NSInteger ttsettings_favorDetailActionType(void);
extern NSArray *ttsettings_favorDetailActionTick(void);
extern NSInteger ttuserdefaults_favorCount(void);
extern void ttuserdefaults_setFavorCount(NSInteger);

@interface TTVVideoDetailCollectService ()

@property (nonatomic, strong) ExploreItemActionManager *itemAction;
@property (nonatomic, strong) Article *article;

@end

@implementation TTVVideoDetailCollectService

- (NSNumber *)currentADID
{
    return @([[self.article adModel].ad_id longLongValue]);
}

- (void)changeFavoriteButtonClicked:(double)readPct viewController:(UIViewController *)viewController 
{
    [self changeFavoriteButtonClicked:readPct viewController:viewController withButtonSeat:nil];
}

- (void)changeFavoriteButtonClicked:(double)readPct viewController:(UIViewController *)viewController withButtonSeat:(NSString *)iconSeat
{
    NSAssert(_originalArticle != nil, @"article must be not nil");
    if (!_itemAction) {
        self.itemAction = [[ExploreItemActionManager alloc] init];
    }
    if (self.article == nil) {
        self.article = [self.originalArticle ttv_convertedArticle];
    }

    [self favorFunc:self.gdExtJSONDict trackEventTag:@"detail" viewController:viewController source:@"video_detail_favor" buttonSeat:iconSeat];

}
// 收藏吊起弹窗的抽取方法,前两个传入的参数主要用于图集和视频的详情页的区分，第三个参数为要显示的viewController，第四个参数为source来源
- (void)favorFunc:(NSDictionary *)param trackEventTag:(NSString *)tag viewController:(UIViewController *)viewController source:(NSString *)source buttonSeat:(NSString *)btnSeat
{
    if (!_article.userRepined) {
//        [TTLogManager logEvent:@"click_favourite_button" context:nil screenName:kDetailScreen];
        NSMutableDictionary *extraDic;
        if (param){
            extraDic = [NSMutableDictionary dictionaryWithDictionary:param];
        }else{
            extraDic = [NSMutableDictionary dictionary];
        }

        [extraDic setValue:@"video" forKey:@"article_type"];
        [extraDic setValue:[self.article.userInfo ttgc_contentID] forKey:@"author_id"];
            
        [NewsDetailLogicManager trackEventTag:tag label:@"favorite_button" value:@([self article].uniqueID) extValue:[self currentADID]  fromID:nil params:[extraDic copy] groupModel:_article.groupModel];
        
        TTAccountLoginAlertTitleType type = TTAccountLoginAlertTitleTypeFavor;
        NSInteger favorCount = ttuserdefaults_favorCount();
        
        if (ttsettings_favorDetailActionType() == 0) {
            // 策略0: 不需要登录
            // 收藏操作都会正常进行,进行原来的收藏操作
            [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
        } else if (ttsettings_favorDetailActionType() == 1) {
            // 策略1: 强制登录，需要客户端判断用户的登录状态
            if ([TTAccountManager isLogin]) {
                // 如果用户已经登录，不出现弹窗，收藏操作会正常进行
                [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
            } else if (![TTAccountManager isLogin]) {
                // 用户处于未登录状态，需要进行强制登录，用户不登录的话无法使用后续功能
                [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        // 如果登录成功，后续功能会照常进行
                        // 进行收藏操作
                        [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
                    } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                        // 如果退出登录，登录不成功，则后续功能不会进行
                        // 添加收藏失败的统计埋点
                        //                        [NewsDetailLogicManager trackEventTag:tag label:@"favorite_fail" value:[self article].uniqueID extValue:[self currentADID] fromID:nil params:param groupModel:_article.groupModel];
                    } else if (type == TTAccountAlertCompletionEventTypeTip) {
                        [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:viewController] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                            if (state == TTAccountLoginStateLogin) {
                                // 如果登录成功，则进行收藏过程
                                [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
                            } else if (state == TTAccountLoginStateCancelled) {
                                // 添加收藏失败的统计埋点
                                //                                [NewsDetailLogicManager trackEventTag:tag label:@"favorite_fail" value:[self article].uniqueID extValue:[self currentADID] fromID:nil params:param groupModel:_article.groupModel];
                            }
                        }];
                    }
                }];
            }
        } else if (ttsettings_favorDetailActionType() == 2) {
            // 策略2: 非强制登录，需要客户端判断用户的登录状态
            if ([TTAccountManager isLogin]) {
                // 如果用户已登录，不出现弹窗，收藏操作会正常进行
                [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
            } else if (![TTAccountManager isLogin]) {
                // 用户处于未登录状态，进行非强制登录弹窗
                // 非强制登录的逻辑，根据当前详情页的点击收藏的次数进行弹窗判断的逻辑
                // 得到当前详情页的点击收藏的次数，进行判断
                favorCount++;
                BOOL countEqual = NO;
                for (NSNumber *tmp in ttsettings_favorDetailActionTick()) {
                    if (favorCount == tmp.integerValue) {
                        countEqual = YES;
                        // 如果等于某次非强制登录弹窗的次数，则进行弹窗
                        [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                            if (type == TTAccountAlertCompletionEventTypeDone) {
                                // 显示弹窗后，才进行收藏过程
                                [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
                            } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                                // 显示弹窗后，才进行收藏过程
                                [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
                            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:viewController] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                                    if (state == TTAccountLoginStateLogin) {
                                        // 如果登录成功，则进行收藏过程
                                        [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
                                    } else if (state == TTAccountLoginStateCancelled) {
                                        // 显示弹窗后，才进行收藏过程
                                        [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
                                    }
                                }];
                            }
                        }];
                        // 找到相等次数时，break跳出循环
                        break;
                    }
                }
                if (!countEqual) {
                    // 如果不是符合的次数，则直接进行订阅操作过程
                    [self didFavor:param trackEventTag:tag buttonSeat:btnSeat];
                }
            }
            // 将点击订阅数持久化进NSUSerDefaults
            ttuserdefaults_setFavorCount(favorCount);
        }
    } else {
        // 取消订阅
//        [TTLogManager logEvent:@"click_unfavourite_button" context:nil screenName:kDetailScreen];
        NSMutableDictionary *extraDic;
        if (param){
            extraDic = [NSMutableDictionary dictionaryWithDictionary:param];
        }else{
            extraDic = [NSMutableDictionary dictionary];
        }
        [extraDic setValue:@"video" forKey:@"article_type"];
        [extraDic setValue:[self.article.userInfo ttgc_contentID] forKey:@"author_id"];
        [NewsDetailLogicManager trackEventTag:@"detail" label:@"unfavorite_button" value:@(_article.uniqueID) extValue:[self currentADID] fromID:nil params:[extraDic copy] groupModel:_article.groupModel];
        [self didUnFavorWithButtonSeat:btnSeat];

    }
}

// 点击收藏的操作
- (void)didFavor:(NSDictionary *)param trackEventTag:(NSString *)tag buttonSeat:(NSString *)btnSeat{
    @weakify(self);
    [_itemAction favoriteForOriginalData:_article adID:[self currentADID] finishBlock:^(id userInfo ,NSError * error) {
        @strongify(self);
        NSString *uniqueIDStr = [NSString stringWithFormat:@"%lld", self.article.uniqueID];
        SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCollectChanged:uniqueIDStr:), ttv_message_feedCollectChanged:YES uniqueIDStr:uniqueIDStr);
    }];
    if(_article.userRepined)
    {
        self.originalArticle.userRepined = _article.userRepined;
        [self showTipMsg:NSLocalizedString(@"收藏成功", nil) icon:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] buttonSeat:btnSeat];
    }
    // 收藏成功，统计打点 favorite_success
    [NewsDetailLogicManager trackEventTag:tag label:@"favorite_success" value:@([self article].uniqueID) extValue:[self currentADID] fromID:nil params:param groupModel:_article.groupModel];
}

// 点击取消收藏的操作
- (void)didUnFavorWithButtonSeat:(NSString *)btnSeat {
    @weakify(self);
    [_itemAction unfavoriteForOriginalData:_article adID:[self currentADID] finishBlock:^(id userInfo ,NSError * error) {
        @strongify(self);
        NSString *uniqueIDStr = [NSString stringWithFormat:@"%lld", self.article.uniqueID];
        SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCollectChanged:uniqueIDStr:), ttv_message_feedCollectChanged:NO uniqueIDStr:uniqueIDStr);
    }];
    if (!_article.userRepined)
    {
        self.originalArticle.userRepined = _article.userRepined;
        [self showTipMsg:NSLocalizedString(@"取消收藏", nil) icon:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] buttonSeat:btnSeat];
    }
    
}

- (void)showTipMsg:(NSString *)tip icon:(UIImage *)image
{
    [self showTipMsg:tip icon:image buttonSeat:nil];    
}

- (void)showTipMsg:(NSString *)tip icon:(UIImage *)image buttonSeat:(NSString *)btnSeat
{
    if (_delegate && [_delegate respondsToSelector:@selector(detailCollectService:showTipMsg:icon:buttonSeat:)]) {
        [_delegate detailCollectService:self showTipMsg:tip icon:image buttonSeat:btnSeat];
    }
}
    

@end
