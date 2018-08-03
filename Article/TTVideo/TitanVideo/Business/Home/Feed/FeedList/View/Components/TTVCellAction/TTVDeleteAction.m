//
//  TTVDeleteAction.m
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVDeleteAction.h"
#import "TTNetworkManager.h"
#import "TTVPlayVideo.h"
#import "UIView+supportFullScreen.h"
@implementation TTVDeleteActionEntity

@end

@interface TTVDeleteAction ()
@end

@implementation TTVDeleteAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTActivityTypeDetele;
    }
    return self;
}

- (void)execute:(TTActivityType)type
{
    if (type != self.type) {
        return;
    }

    NSString *userId = self.entity.userId;
    NSString *group_id = self.entity.groupId;
    NSString *item_id = self.entity.itemId;

    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:item_id forKey:@"item_id"];
    [extraDict setValue:@"click_video" forKey:@"source"];
    [extraDict setValue:@(1) forKey:@"aggr_type"];
    [extraDict setValue:@(1) forKey:@"type"];
    wrapperTrackEventWithCustomKeys(@"list_share", @"delete_ugc", group_id, nil, extraDict);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:userId forKey:@"user_id"];
    [params setValue:item_id forKey:@"item_id"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting deleteUGCMovieURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSInteger errorCode = 0;
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            errorCode = [(NSDictionary *)jsonObj tt_integerValueForKey:@"error_code"];
        }
        NSString *tip;
        if (error || errorCode != 0) {
            tip = NSLocalizedString(@"操作失败", nil);
            [TTVDeleteAction showShareIndicatorViewWithTip:tip andImage:[UIImage themedImageNamed:@"close_popup_textpage"] dismissHandler:nil];
        } else {
            tip = NSLocalizedString(@"操作成功", nil);
            BOOL isFullScreen = [TTVPlayVideo currentPlayingPlayVideo].player.context.isFullScreen;
            if (isFullScreen){
                [[TTVPlayVideo currentPlayingPlayVideo] exitFullScreen:NO completion:nil];
            }
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];

            if (group_id) {
                //给feed发通知
#warning todop
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTVideoDetailViewControllerDeleteVideoArticle" object:nil userInfo:@{@"uniqueID":group_id}];
                //从数据库中删除
            }
        }
    }];
}

+ (void)showShareIndicatorViewWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler
{
    BOOL isFullScreen = [TTVPlayVideo currentPlayingPlayVideo].player.context.isFullScreen;
    TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:indicatorImage dismissHandler:handler];
    [indicateView addTransFormIsFullScreen:isFullScreen];
    indicateView.autoDismiss = YES;
    [indicateView showFromParentView:[[indicateView class] defaultParentView]];
    [indicateView changeFrameIsFullScreen:isFullScreen];
}

@end

