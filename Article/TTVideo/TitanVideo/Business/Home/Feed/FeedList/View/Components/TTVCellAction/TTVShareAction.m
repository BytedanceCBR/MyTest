//
//  TTVShareAction.m
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVShareAction.h"
#import "TTActivityShareManager.h"
#import "TTVideoCommon.h"
#import "TTUIResponderHelper.h"

extern BOOL ttvs_isVideoCellShowShareEnabled(void);

@implementation TTVShareActionEntity


@end

@interface TTVShareAction ()
@end

@implementation TTVShareAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTShareKey;
    }
    return self;
}

- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType
{
    NSNumber *ad_id = self.entity.adID;
    NSString *group_id = self.entity.groupId;

    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeVideoList];
    NSString *label = [TTVideoCommon videoListlabelNameForShareActivityType:itemType];
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    if ([ad_id longLongValue]) {
        extValueDic[@"ext_value"] = ad_id;
    }
    if (!isEmptyString(self.entity.videoSubjectID)) {
        extValueDic[@"video_subject_id"] = self.entity.videoSubjectID;
    }
    if (ttvs_isVideoCellShowShareEnabled()) {
        extValueDic[@"bar"] = @"button_seat";
    }
    wrapperTrackEventWithCustomKeys(tag, label, group_id, @"video", extValueDic);

}

- (void)execute:(TTActivityType)type
{
    UIViewController *presentingViewController = nil;
    if (self.getPresentingViewControllerOfShare) {
        presentingViewController = self.getPresentingViewControllerOfShare(self.entity.responder);
    } else {
        presentingViewController = [TTUIResponderHelper topViewControllerFor:self.entity.responder];
    }
    BOOL isfullScreen = NO;
    if ([self.activityActionManager.clickSource isEqualToString:@"player_more"] || [self.activityActionManager.clickSource isEqualToString:@"player_share"]) {
        isfullScreen = YES;
    }
    NSString *adId = nil;
    if ([self.entity.adID longLongValue] > 0) {
        adId = [NSString stringWithFormat:@"%@", self.entity.adID];
    }
    [self.activityActionManager performActivityActionByType:type inViewController:presentingViewController sourceObjectType:TTShareSourceObjectTypeVideoList uniqueId:self.entity.groupId adID:adId platform:TTSharePlatformTypeOfMain groupFlags:@(self.entity.groupFlags) isFullScreenShow:isfullScreen];
}

@end
