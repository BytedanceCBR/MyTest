//
//  TTCommentDetailService.m
//  Article
//
//  Created by pei yun on 2017/11/23.
//

#import "TTCommentDetailService.h"
#import "ArticleURLSetting.h"
#import "TTNetworkManager.h"
#import "NSDictionary+TTAdditions.h"


@implementation TTCommentDetailService

- (void)loadCommentDetailWithCommentID:(NSString *)commentID modifyTime:(NSNumber *)modifyTime finished:(void(^)(TTCommentDetailModel *model, NSError *error))finished
{
    if (!finished) {
        NSAssert(NO, @"finished block must not be nil");
        return;
    }
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:commentID forKey:@"comment_id"];
    [param setValue:@"5" forKey:@"source"];
    [param setValue:modifyTime forKey:@"modify_time"];
    [param setValue:@([TTUIResponderHelper screenResolution].width) forKey:@"screen_width"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting commentDetailURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        TTCommentDetailModel *model = [[TTCommentDetailModel alloc] initWithDictionary:jsonObj[@"data"] error:nil];
        if (error || !model) {
            finished(nil, error);
            return;
        }
        model.banEmojiInput = [jsonObj tt_boolValueForKey:@"ban_face"];
        model.banForwardToWeitoutiao = @(![jsonObj tt_boolValueForKey:@"show_repost_entrance"]);
        model.show_repost_weitoutiao_entrance = [jsonObj tt_boolValueForKey:@"show_repost_weitoutiao_entrance"];
        finished(model, nil);
    }];
}

@end
