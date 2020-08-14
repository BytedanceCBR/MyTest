//
//  FHUGCFeedDetailJumpManager.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/5/9.
//

#import "FHUGCFeedDetailJumpManager.h"
#import "TTStringHelper.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHUGCVideoCell.h"
#import "FHUGCFullScreenVideoCell.h"
#import "TTVFeedCellSelectContext.h"
#import "FHUserTracker.h"
#import "TTAccountManager.h"
#import "TTURLUtils.h"
#import "TSVShortVideoDetailExitManager.h"
#import "FHUGCSmallVideoCell.h"
#import "TSVShortVideoDetailExitManager.h"
#import "HTSVideoPageParamHeader.h"
#import "AWEVideoConstants.h"

@interface FHUGCFeedDetailJumpManager ()

@end

@implementation FHUGCFeedDetailJumpManager

- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    [self jumpToDetail:cellModel showComment:showComment enterType:enterType extraDic:nil];
}

- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType extraDic:(NSDictionary *)extraDic {
    if(cellModel.cellType == FHUGCFeedListCellTypeArticle || cellModel.cellType == FHUGCFeedListCellTypeQuestion){
        if(cellModel.hasVideo){
            //视频
            [self jumpToVideoDetail:cellModel showComment:showComment enterType:enterType extraDic:extraDic];
        }else{
            //文章
            [self jumpToArticleDetail:cellModel showComment:showComment enterType:enterType extraDic:extraDic];
        }
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGC){
        //帖子
        [self jumpToPostDetail:cellModel showComment:showComment enterType:enterType extraDic:extraDic];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner || cellModel.cellType == FHUGCFeedListCellTypeUGCBanner2){
        //运营位
        [self jumpToBannerDetail:cellModel extraDic:extraDic];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCEncyclopedias){
        //百科问答
        [self jumpToEncyclopediasDetail:cellModel extraDic:extraDic];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeArticleComment || cellModel.cellType == FHUGCFeedListCellTypeArticleComment2){
        //文章评论
        [self jumpToArticleCommentDetail:cellModel showComment:showComment enterType:enterType extraDic:extraDic];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeAnswer){
        //问答回答
        [self jumpToAnswerDetail:cellModel showComment:showComment enterType:enterType extraDic:extraDic];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVote){
        //投票pk
        [self jumpToVotePKDetail:cellModel value:0 extraDic:extraDic];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo){
        //小视频
        [self jumpToSmallVideoDetail:cellModel showComment:showComment enterType:enterType extraDic:extraDic];
    }  else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVoteInfo) {
        // 新投票
        [self jumpToNewVoteDetail:cellModel showComment:showComment enterType:enterType extraDic:extraDic];
    }
}

#pragma mark - 各种题材跳转
//文章详情页
- (void)jumpToArticleDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType extraDic:(NSDictionary *)extraDic {
    BOOL canOpenURL = NO;
    if (!canOpenURL && !isEmptyString(cellModel.openUrl)) {
        NSURL *url = [TTStringHelper URLWithURLString:cellModel.openUrl];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            canOpenURL = YES;
            [[UIApplication sharedApplication] openURL:url];
        }
        else if([[TTRoute sharedRoute] canOpenURL:url]){
            canOpenURL = YES;
            //优先跳转openurl
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
            tracerDic[@"origin_from"] = cellModel.tracerDic[@"origin_from"] ?: @"be_null";
            tracerDic[@"enter_from"] = cellModel.tracerDic[@"page_type"] ?: @"be_null";
            tracerDic[@"category_name"] = cellModel.tracerDic[@"category_name"] ?: @"be_null";
            tracerDic[@"enter_type"] = enterType ? enterType : @"be_null";
            tracerDic[@"rank"] = cellModel.tracerDic[@"rank"];
            tracerDic[@"group_source"] = cellModel.tracerDic[@"group_source"];
            if(!isEmptyString(cellModel.community.socialGroupId)){
                tracerDic[@"social_group_id"] = cellModel.community.socialGroupId;
            }
            if(cellModel.tracerDic[@"concern_id"]){
                tracerDic[@"concern_id"] = cellModel.tracerDic[@"concern_id"];
            }
            if(extraDic){
                [tracerDic addEntriesFromDictionary:extraDic];
            }
            dict[@"tracer"] = tracerDic;
            
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }else{
        NSURL *openUrl = [NSURL URLWithString:cellModel.detailScheme];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

//视频详情页
- (void)jumpToVideoDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType extraDic:(NSDictionary *)extraDic {
    if(cellModel.isVideoJumpDetail){
        //跳转到视频详情页
        if(self.currentCell){
            TTVFeedCellSelectContext *context = [[TTVFeedCellSelectContext alloc] init];
            context.refer = self.refer;
            context.categoryId = cellModel.categoryId;
            context.clickComment = showComment;
            context.enterType = enterType;
            context.enterFrom = cellModel.tracerDic[@"page_type"] ?: @"be_null";
            
            if([self.currentCell isKindOfClass:[FHUGCVideoCell class]]){
                FHUGCVideoCell *cell = (FHUGCVideoCell *)self.currentCell;
                [cell didSelectCell:context];
            }else if([self.currentCell isKindOfClass:[FHUGCFullScreenVideoCell class]]){
                FHUGCFullScreenVideoCell *cell = (FHUGCFullScreenVideoCell *)self.currentCell;
                [cell didSelectCell:context];
            }
        }else if (cellModel.openUrl) {
            NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
        }
    }else{
        //跳转到轮播页
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"currentVideo"] = cellModel.originContent;
        
        NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
        tracerDic[@"origin_from"] = cellModel.tracerDic[@"origin_from"] ?: @"be_null";
        tracerDic[@"enter_from"] = cellModel.tracerDic[@"page_type"] ?: @"be_null";
        tracerDic[@"category_name"] = cellModel.tracerDic[@"category_name"] ?: @"be_null";
        tracerDic[@"enter_type"] = enterType ? enterType : @"be_null";
        tracerDic[@"rank"] = cellModel.tracerDic[@"rank"];
        tracerDic[@"group_source"] = cellModel.tracerDic[@"group_source"];
        if(!isEmptyString(cellModel.community.socialGroupId)){
            tracerDic[@"social_group_id"] = cellModel.community.socialGroupId;
        }
        if(cellModel.tracerDic[@"concern_id"]){
            tracerDic[@"concern_id"] = cellModel.tracerDic[@"concern_id"];
        }
        if(extraDic){
            [tracerDic addEntriesFromDictionary:extraDic];
        }
        dict[@"tracer"] = tracerDic;
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_video_feed_list"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

//帖子详情页
- (void)jumpToPostDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType extraDic:(NSDictionary *)extraDic {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 埋点
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"origin_from"] = cellModel.tracerDic[@"origin_from"];
    traceParam[@"enter_from"] = cellModel.tracerDic[@"page_type"];
    traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
    traceParam[@"element_from"] = cellModel.tracerDic[@"element_from"];
    traceParam[@"from_gid"] = cellModel.tracerDic[@"from_gid"];
    traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
    traceParam[@"log_pb"] = cellModel.logPb;
    if(!isEmptyString(cellModel.community.socialGroupId)){
        traceParam[@"social_group_id"] = cellModel.community.socialGroupId;
    }
    if(cellModel.tracerDic[@"concern_id"]){
        traceParam[@"concern_id"] = cellModel.tracerDic[@"concern_id"];
    }
    traceParam[@"category_name"] = cellModel.tracerDic[@"category_name"]?:@"be_null";
    if(extraDic){
        [traceParam addEntriesFromDictionary:extraDic];
    }
    dict[@"tracer"] = traceParam;
    
    dict[@"data"] = cellModel;
    dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
    dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
    dict[@"thread_detail_source"] = @"ugc_thread";
    dict[@"tid"] = cellModel.groupId;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    FHFeedUGCContentModel *contentModel = cellModel.originData;
    NSString *routeUrl = @"sslocal://thread_detail";
    if (contentModel && [contentModel isKindOfClass:[FHFeedUGCContentModel class]]) {
        NSString *schema = contentModel.schema;
        if (schema.length > 0) {
            routeUrl = schema;
        }
    }
    
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

//运营位
- (void)jumpToBannerDetail:(FHFeedUGCCellModel *)cellModel extraDic:(NSDictionary *)extraDic {
    NSMutableDictionary *guideDict = [NSMutableDictionary dictionary];
    guideDict[@"origin_from"] = cellModel.tracerDic[@"origin_from"];
    guideDict[@"page_type"] = cellModel.tracerDic[@"page_type"];
    guideDict[@"description"] = cellModel.desc;
    guideDict[@"item_title"] = cellModel.title;
    guideDict[@"item_id"] = cellModel.groupId;
    guideDict[@"rank"] = cellModel.tracerDic[@"rank"];
    if(extraDic){
        [guideDict addEntriesFromDictionary:extraDic];
    }
    TRACK_EVENT(@"banner_click", guideDict);
    //根据url跳转
    NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:guideDict];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

//百科问答
- (void)jumpToEncyclopediasDetail:(FHFeedUGCCellModel *)cellModel extraDic:(NSDictionary *)extraDic {
    NSMutableDictionary *guideDict = [NSMutableDictionary dictionary];
    guideDict[@"origin_from"] = cellModel.tracerDic[@"origin_from"];
    guideDict[@"page_type"] = cellModel.tracerDic[@"page_type"];
    guideDict[@"description"] = cellModel.desc;
    guideDict[@"item_title"] = cellModel.title;
    guideDict[@"item_id"] = cellModel.groupId;
    guideDict[@"log_pb"] = cellModel.logPb;
    guideDict[@"rank"] = cellModel.tracerDic[@"rank"];
    if(extraDic){
        [guideDict addEntriesFromDictionary:extraDic];
    }
    TRACK_EVENT(@"card_click", guideDict);
    //根据url跳转
    NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:guideDict];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

//文章评论
- (void)jumpToArticleCommentDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType extraDic:(NSDictionary *)extraDic {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"origin_from"] = cellModel.tracerDic[@"origin_from"] ?: @"be_null";
    traceParam[@"enter_from"] = cellModel.tracerDic[@"page_type"] ?: @"be_null";
    traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
    traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
    traceParam[@"log_pb"] = cellModel.logPb;
    traceParam[@"category_name"] = cellModel.tracerDic[@"category_name"]?:@"be_null";
    if(!isEmptyString(cellModel.community.socialGroupId)){
        traceParam[@"social_group_id"] = cellModel.community.socialGroupId;
        dict[@"social_group_id"] = cellModel.community.socialGroupId;
    }
    if(cellModel.tracerDic[@"concern_id"]){
        traceParam[@"concern_id"] = cellModel.tracerDic[@"concern_id"];
    }
    if(cellModel.fromGid){
        traceParam[@"from_gid"] = cellModel.fromGid;
    }
    if(cellModel.fromGroupSource){
        traceParam[@"from_group_source"] = cellModel.fromGroupSource;
    }
    if(extraDic){
        [traceParam addEntriesFromDictionary:extraDic];
    }
    dict[@"tracer"] = traceParam;
    dict[@"data"] = cellModel;
    dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

//问答回答
- (void)jumpToAnswerDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType extraDic:(NSDictionary *)extraDic {
    NSMutableDictionary *dict = @{@"is_jump_comment":@(showComment)}.mutableCopy;
    NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
    tracerDic[@"origin_from"] = cellModel.tracerDic[@"origin_from"] ?: @"be_null";
    tracerDic[@"enter_from"] = cellModel.tracerDic[@"page_type"] ?: @"be_null";
    tracerDic[@"category_name"] = cellModel.tracerDic[@"category_name"] ?: @"be_null";
    tracerDic[@"element_from"] = cellModel.tracerDic[@"element_from"];
    tracerDic[@"enter_type"] = enterType ? enterType : @"be_null";
    tracerDic[@"rank"] = cellModel.tracerDic[@"rank"];
    if(!isEmptyString(cellModel.community.socialGroupId)){
        tracerDic[@"social_group_id"] = cellModel.community.socialGroupId;
    }
    if(cellModel.tracerDic[@"concern_id"]){
        tracerDic[@"concern_id"] = cellModel.tracerDic[@"concern_id"];
    }
    if(cellModel.fromGid){
        tracerDic[@"from_gid"] = cellModel.fromGid;
    }
    if(cellModel.fromGroupSource){
        tracerDic[@"from_group_source"] = cellModel.fromGroupSource;
    }
    if(extraDic){
        [tracerDic addEntriesFromDictionary:extraDic];
    }
    dict[@"tracer"] = tracerDic;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
    if(showComment && cellModel.commentSchema.length > 0){
        openUrl = [NSURL URLWithString:cellModel.commentSchema];
    }
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

//投票pk
- (void)jumpToVotePKDetail:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value extraDic:(NSDictionary *)extraDic {
    [self trackVoteClickOptions:cellModel value:value];
    if([TTAccountManager isLogin] || !cellModel.vote.needUserLogin){
        if(cellModel.vote.openUrl){
            NSString *urlStr = cellModel.vote.openUrl;
            if(value > 0){
                NSString *append = [TTURLUtils queryItemAddingPercentEscapes:[NSString stringWithFormat:@"&vote=%d",value]];
                urlStr = [urlStr stringByAppendingString:append];
            }
            
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        }
    }else{
        [self gotoLogin:cellModel value:value];
    }
}

//小视频
- (void)jumpToSmallVideoDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType extraDic:(NSDictionary *)extraDic {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    WeakSelf;
    TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
        StrongSelf;
        CGRect imageFrame = [self selectedSmallVideoFrame];
        imageFrame.origin = CGPointZero;
        return imageFrame;
    } updateTargetViewBlock:^UIView *{
        StrongSelf;
        return [self currentSelectSmallVideoView];
    }];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
    [info setValue:exitManager forKey:HTSVideoDetailExitManager];
    if (showComment) {
        [info setValue:@(1) forKey:AWEVideoShowComment];
    }
    if(cellModel.tracerDic){
        NSMutableDictionary *tracerDic = [cellModel.tracerDic mutableCopy];
        tracerDic[@"page_type"] = @"small_video_detail";
        tracerDic[@"enter_from"] = cellModel.tracerDic[@"page_type"];
        tracerDic[@"enter_type"] = enterType ? enterType : @"be_null";
        tracerDic[@"rank"] = cellModel.tracerDic[@"rank"];
        if(!isEmptyString(cellModel.community.socialGroupId)){
            tracerDic[@"social_group_id"] = cellModel.community.socialGroupId;
        }
        if(cellModel.tracerDic[@"concern_id"]){
            tracerDic[@"concern_id"] = cellModel.tracerDic[@"concern_id"];
        }
        if(extraDic){
            [tracerDic addEntriesFromDictionary:extraDic];
        }
        [info setValue:tracerDic forKey:@"extraDic"];
    }
    
    NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:TTRouteUserInfoWithDict(info)];
}

//投票
- (void)jumpToNewVoteDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType extraDic:(NSDictionary *)extraDic {
    NSMutableDictionary *dict = @{@"begin_show_comment":@(showComment)}.mutableCopy;
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"origin_from"] = cellModel.tracerDic[@"origin_from"];
    traceParam[@"enter_from"] = cellModel.tracerDic[@"page_type"];
    traceParam[@"category_name"] = cellModel.tracerDic[@"category_name"]?:@"be_null";
    traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
    traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
    traceParam[@"log_pb"] = cellModel.logPb;
    if(cellModel.tracerDic[@"concern_id"]){
        traceParam[@"concern_id"] = cellModel.tracerDic[@"concern_id"];
    }
    if(extraDic){
        [traceParam addEntriesFromDictionary:extraDic];
    }
    dict[@"data"] = cellModel;
    dict[@"tracer"] = traceParam;
    if(!isEmptyString(cellModel.community.socialGroupId)){
        dict[@"social_group_id"] = cellModel.community.socialGroupId;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

//圈子详情页
- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    if(cellModel.community.socialGroupId){
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = cellModel.community.socialGroupId;
        
        dict[@"tracer"] = @{
            @"origin_from":cellModel.tracerDic[@"origin_from"] ?: @"be_null",
            @"enter_from":cellModel.tracerDic[@"page_type"] ?: @"be_null",
            @"enter_type":@"click",
            @"rank":cellModel.tracerDic[@"rank"] ?: @"be_null",
            @"log_pb":cellModel.logPb ?: @"be_null"
        };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        //跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

#pragma mark - 相关功能

- (void)gotoLogin:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value  {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = cellModel.tracerDic[@"page_type"];
    params[@"enter_type"] = @"click";
    params[@"need_pop_vc"] = @(YES);
    params[@"from_ugc"] = @(YES);
   
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(cellModel.vote.openUrl){
                        NSString *urlStr = cellModel.vote.openUrl;
                        if(value > 0){
                            NSString *append = [TTURLUtils queryItemAddingPercentEscapes:[NSString stringWithFormat:@"&vote=%d",value]];
                            urlStr = [urlStr stringByAppendingString:append];
                        }
                        
                        NSURL *url = [NSURL URLWithString:urlStr];
                        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                    }
                });
            }
        }
    }];
}

- (UIView *)currentSelectSmallVideoView {
    if (self.currentCell && [self.currentCell isKindOfClass:[FHUGCSmallVideoCell class]]) {
        FHUGCSmallVideoCell *smallVideoCell = self.currentCell;
        return smallVideoCell.videoImageView;
    }
    return nil;
}

- (CGRect)selectedSmallVideoFrame {
    UIView *view = [self currentSelectSmallVideoView];
    if (view) {
        CGRect frame = [view convertRect:view.bounds toView:nil];
        return frame;
    }
    return CGRectZero;
}

#pragma mark - 埋点相关

- (void)trackVoteClickOptions:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"log_pb"] = cellModel.logPb;
    if(value == [cellModel.vote.leftValue integerValue]){
        dict[@"click_position"] = @"1";
    }else if(value == [cellModel.vote.rightValue integerValue]){
        dict[@"click_position"] = @"2";
    }else{
        dict[@"click_position"] = @"vote_content";
    }
    TRACK_EVENT(@"click_options", dict);
}

@end
