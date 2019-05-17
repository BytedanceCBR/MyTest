//
//  TTLayOutCellDataHelper.m
//  Article
//
//  Created by 王双华 on 16/10/14.
//
//

#import "TTLayOutCellDataHelper.h"
#import "ExploreCellHelper.h"
#import "Article.h"
#import "Article+TTADComputedProperties.h"
#import "Comment.h"
#import "TTAdFeedModel.h"
#import "ExploreOrderedData+TTAd.h"

#import "SSImpressionModel.h"
#import <TTVerifyKit/TTVerifyIconHelper.h>
#import <TTKitchen/TTKitchenHeader.h>

@implementation TTLayOutCellDataHelper

+ (NSString *)getSourceImageUrlStringForUGCCellWithOrderedData:(ExploreOrderedData *)data
{
    NSString *sourceImageUrl = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        Article *article = [data article];
        if ([article mediaInfo] && [[article mediaInfo] objectForKey:@"avatar_url"]) {
            sourceImageUrl = [article mediaInfo][@"avatar_url"];
        }
        else if ([article userInfo] && [[article userInfo] objectForKey:@"avatar_url"]) {
            sourceImageUrl = [article userInfo][@"avatar_url"];
        }
        if (isEmptyString(sourceImageUrl)) {
            sourceImageUrl = [article sourceAvatar];
        }
    }
    return sourceImageUrl;
}

+ (NSString *)getSourceImageUrlStringForUFCellWithOrderedData:(ExploreOrderedData *)data
{
    NSString *sourceImageUrl = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        Article *article = data.article;
        sourceImageUrl = article.userImgaeURL;
    }
    else if ([data.originalData isKindOfClass:[Comment class]]) {
        Comment *comment = data.comment;
        sourceImageUrl = comment.userAvatarURL;
    }
    return sourceImageUrl;
}

+ (NSString *)getSourceNameStringForUGCCellWithOrderedData:(ExploreOrderedData *)data
{
    NSString *sourceName = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        Article *article = [data article];
        if ([article mediaInfo]) {
            NSDictionary *mediaInfo = [article mediaInfo];
            sourceName = mediaInfo[@"name"];
        }
        if (isEmptyString(sourceName)) {
            sourceName = [article source];
        }
        if (isEmptyString(sourceName)) {
            sourceName = @"佚名";
        }
    }
    return sourceName;
}

+ (NSString *)getSourceNameStringForUFCellWithOrderedData:(ExploreOrderedData *)data
{
    NSString *sourceName = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        sourceName = [[data article] userName];
    }
    if ([data.originalData isKindOfClass:[Comment class]]) {
        sourceName = [[data comment] userName];
    }
    if (isEmptyString(sourceName)) {
        sourceName = @"佚名";
    }
    return sourceName;
}

+ (NSString *)getTitleStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *title = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
       id<TTAdFeedModel> adModel = data.adModel;
        if ([data isUnifyADCell] && [adModel isCreativeAd]) {
            BOOL isApp = adModel.adType == ExploreActionTypeApp;
            title = (isApp ? adModel.descInfo : adModel.title);
        }
        if (isEmptyString(title)) {
            title = [data article].title;
        }
    }
    return title;
}



+ (NSString *)getTitleStringForCommentCellWithOrderedData:(ExploreOrderedData *)data
{
    NSMutableString *title = [NSMutableString stringWithCapacity:30];
    if ([data comment]) {
        Comment *comment = data.comment;
        if (!isEmptyString(comment.source)) {
            [title appendFormat:@"%@: ",comment.source];
        }
        if (!isEmptyString(comment.title)) {
            [title appendString:comment.title];
        }
    }
    return title;
}

+ (NSArray *)getInfoStringWithOrderedData:(ExploreOrderedData *)data hideTimeLabel:(BOOL)hideTimeLabel
{
    NSMutableString *infoStr = [NSMutableString stringWithCapacity:30];
    NSMutableArray *subStringArray = [NSMutableArray arrayWithCapacity:3];
    if ([data.originalData isKindOfClass:[Article class]]) {
        Article *article = data.article;
        
        NSString *paddingStr = [TTDeviceHelper isPadDevice] ? @"   " : @"  ";
        
        NSInteger videoType = 0;
        if ([[article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
            videoType = ((NSNumber *)[article.videoDetailInfo objectForKey:@"video_type"]).integerValue;
        }
        //是否展示直播在线人数
        if (videoType == 1 && [data isShowMediaLiveViewCount]) {
            
            NSInteger count = ((NSNumber *)[article.videoDetailInfo objectForKey:@"video_watch_count"]).integerValue;
            count = MAX(0, count);
            NSString *liveStr = [NSString stringWithFormat:@"累计%@人观看", [TTBusinessManager formatCommentCount:count]];
            [infoStr appendString:liveStr];
            [subStringArray addObject:[infoStr copy]];
            [infoStr appendString:paddingStr];
            
        }
        
        if ([data isShowRecommendReasonLabel] && !isEmptyString(data.recommendReason)) {
            [infoStr appendString:data.recommendReason];
            [subStringArray addObject:[infoStr copy]];
            [infoStr appendString:paddingStr];
        }
        
        if ([data isShowCommentCountLabel]) {
            NSString *commentStr;
            
            if (!isEmptyString(article.infoDesc)) {
                commentStr = article.infoDesc;
            }
            else {
                int count = data.originalData.commentCount;
                count = MAX(0, count);
                commentStr = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:count], NSLocalizedString(@"评论", nil)];
            }
            
            if (!isEmptyString(commentStr)) {
                [infoStr appendString:commentStr];
                [subStringArray addObject:[infoStr copy]];
                [infoStr appendString:paddingStr];
            }
        }
        
        if ([data isShowTimeLabel] && !hideTimeLabel) {
            double time = data.behotTime;
            NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
//            NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
            
//            NSString *publishTime =  [NSString stringWithFormat:@"%@", midnightInterval > 0 ?
//                                      [TTBusinessManager customtimeStringSince1970:time midnightInterval:midnightInterval] :
//                                      [TTBusinessManager customtimeStringSince1970:time]];
            
            if (!isEmptyString(publishTime)) {
                [infoStr appendString:publishTime];
                [subStringArray addObject:[infoStr copy]];
                [infoStr appendString:paddingStr];
            }
        }
    }
    return subStringArray;
}

+ (NSString *)getInfoStringForUnifyADCellWithOrderedData:(ExploreOrderedData *)data
{
    NSMutableString *infoStr = [NSMutableString stringWithCapacity:30];
    NSString *paddingStr = [TTDeviceHelper isPadDevice] ? @"   " : @"  ";
    int cmtCnt = [[data originalData] commentCount];
    NSString *commentStr = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:cmtCnt], NSLocalizedString(@"评论", nil)];
    if ([data isShowComment]) {
        [infoStr appendString:commentStr];
        [infoStr appendString:paddingStr];
    }
    
//    NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
    if ([data behotTime] > 0) {
        NSTimeInterval time = [data behotTime];
        NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
//        NSString *publishTime = (midnightInterval > 0 ? [TTBusinessManager customtimeStringSince1970:time midnightInterval:midnightInterval] : [TTBusinessManager customtimeStringSince1970:time]);
        if (!isEmptyString(publishTime)) {
            [infoStr appendString:publishTime];
        }
    }
    return infoStr;
}


+ (NSString *)getAdLocationStringForUnifyADCellWithOrderData:(ExploreOrderedData *)data WithIndex:(NSInteger)index{
   
    if (!data || !data.article || !data.article.adModel) {
        return nil;
    }
    
    NSString *paddingStr =  @" ";
    
    NSMutableString *loacationStr = [NSMutableString stringWithCapacity:30];
    
    if (index == 0) {
        if (!isEmptyString(data.article.adModel.locationDistrict) ) {
            [loacationStr appendString:data.article.adModel.locationDistrict];
        }
        
        if (!isEmptyString(data.article.adModel.locationStreet)) {
            if (!isEmptyString(loacationStr)) {
                [loacationStr appendString:paddingStr];
            }
            [loacationStr appendString:data.article.adModel.locationStreet];
        }
        
        if (!isEmptyString(data.article.adModel.locationDisdance)) {
            if (!isEmptyString(loacationStr)) {
                [loacationStr appendString:paddingStr];
            }
            [loacationStr appendString:data.article.adModel.locationDisdance];
        }
    }
    
    else if (index == 1){
        
        if (!isEmptyString(data.article.adModel.locationStreet)) {
            [loacationStr appendString:data.article.adModel.locationStreet];
            
            if (!isEmptyString(data.article.adModel.locationDisdance)) {
                if (!isEmptyString(loacationStr)) {
                    [loacationStr appendString:paddingStr];
                }
                
                [loacationStr appendString:data.article.adModel.locationDisdance];
            }
        }
        else {
            
            if (!isEmptyString(data.article.adModel.locationDistrict) ) {
                [loacationStr appendString:data.article.adModel.locationDistrict];
                
                if (!isEmptyString(data.article.adModel.locationDisdance)) {
                    if (!isEmptyString(loacationStr)) {
                        [loacationStr appendString:paddingStr];
                    }
                    
                    [loacationStr appendString:data.article.adModel.locationDisdance];
                }
            }
            
            else if (!isEmptyString(data.article.adModel.locationDisdance)) {
                if (!isEmptyString(loacationStr)) {
                    [loacationStr appendString:paddingStr];
                }
                
                [loacationStr appendString:data.article.adModel.locationDisdance];
            }
        }
        
    }
    
    else if (index == 2){
        
        if (!isEmptyString(data.article.adModel.locationStreet)) {
            
            [loacationStr appendString:data.article.adModel.locationStreet];
        }
        
        else if (!isEmptyString(data.article.adModel.locationDistrict)){
            
            [loacationStr appendString:data.article.adModel.locationDistrict];
        }
        
        else if (!isEmptyString(data.article.adModel.locationDisdance)){
            
            [loacationStr appendString:data.article.adModel.locationDisdance];
        }
    }

    return loacationStr;
}

//当广告为商圈广告时，且有位置信息时，显示位置信息，否则显示评论等信息
+ (BOOL)isAdShowLocation:(ExploreOrderedData *)data{
    if (!data || !data.article || !data.article.adModel) {
        return NO;
    }
    
    if (data.article.adModel.adType == ExploreActionTypeLocationAction || data.article.adModel.adType == ExploreActionTypeLocationForm || data.article.adModel.adType == ExploreActionTypeLocationcounsel) {
        
        if (!isEmptyString([self getAdLocationStringForUnifyADCellWithOrderData:data WithIndex:0])) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isADSubtitleUserInteractive:(ExploreOrderedData *)data{
    
    if (!data || !data.article || !data.article.adModel) {
        return NO;
    }
    
    if (data.article.adModel.adType == ExploreActionTypeLocationAction || data.article.adModel.adType == ExploreActionTypeLocationForm || data.article.adModel.adType == ExploreActionTypeLocationcounsel) {
        
        return YES;
    }
    
    return NO;
}



+ (NSString *)getCommentStringForUnifyADCellWithOrderedData:(ExploreOrderedData *)data
{
    NSMutableString *infoStr = [NSMutableString stringWithCapacity:30];
    int cmtCnt = [[data originalData] commentCount];
    NSString *commentStr = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:cmtCnt], NSLocalizedString(@"评论", nil)];
    if ([data isShowComment]) {
        [infoStr appendString:commentStr];
    }
    return infoStr;
}

+ (NSString *)getInfoStringForUFCellWithOrderedData:(ExploreOrderedData *)data
{
    NSMutableString *infoStr = [NSMutableString stringWithCapacity:30];
    NSString *paddingStr = [TTDeviceHelper isPadDevice] ? @"   " : @"  ";
    if ([data.originalData isKindOfClass:[Article class]]) {
        if ([[data article] hasVideo]){
            NSNumber *playCnt = (NSNumber *)[[data article].videoDetailInfo objectForKey:@"video_watch_count"];
            if ([playCnt longLongValue] < 0) {
                playCnt = [NSNumber numberWithInt:0];
            }
            
            NSString *playStr = nil;
            if ([data isFakePlayCount]) {
                playStr = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:data.article.readCount], NSLocalizedString(@"阅读", nil)];
            }else{
                playStr = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:[playCnt longLongValue]], NSLocalizedString(@"播放", nil)];
            }
            [infoStr appendString:playStr];
            [infoStr appendString:paddingStr];
        }
    }
    else if ([data.originalData isKindOfClass:[Comment class]]){
    }
    return infoStr;
}

+ (NSString *)getUserVerifiedStringWithOrderedData:(ExploreOrderedData *)data
{
    if ([data.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle6) {
        return [self getSecondLineStringWithData:data];
    }
    else if ([data.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle5
             || [data.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle7
             || [data.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle8
             || [data.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle9
             || [data.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle11) {
        return [self getTimeStringAndFollowStatusStringAndUserVerifiedStringOrRecommendReasonStringWithOrderedData:data];
    }
    return [self getSecondLineStringWithData:data];
}

//第二行实际改成了推荐理由
+ (NSString *)getSecondLineStringWithData:(ExploreOrderedData *)data
{
    NSString *infoStr = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        infoStr = [data ugcRecommendReason];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]) {
        infoStr = [data ugcRecommendReason];
    }
    if (isEmptyString(infoStr)) {
        return nil;
    }
    return infoStr;
}

+ (NSString *)getTimeStringAndFollowStatusStringAndUserVerifiedStringOrRecommendReasonStringWithOrderedData:(ExploreOrderedData *)data {
    NSMutableString *result = [NSMutableString string];
    //时间
    NSString * displayTime = [self getTimeStringWithOrderedData:data];
    BOOL showTime = data.isU11ShowTimeItem;
    if (showTime) {
        if (!isEmptyString(displayTime)) {
            [result appendString:displayTime];
        }
    }
    
    //关注状态
    BOOL follow = [self isFollowedWithOrderedData:data];
    BOOL showFollow = data.isU11ShowFollowItem && follow && !data.showFollowButton.boolValue;
    if (showFollow && ![data isU13CellInStoryMode]) { // story流里不显示关注状态
        if (!isEmptyString(result)) {
            [result appendString:@" · "];
        }
        if ([self userIsFollowedByOthersWithOrderedData:data]) {
            [result appendString:NSLocalizedString(@"互相关注", nil)];
        }else{
            [result appendString:NSLocalizedString(@"已关注", nil)];
        }
    }
    
    //认证信息
    NSString *userVerfiedStr = [self getSecondLineStringWithData:data];
    if (!isEmptyString(userVerfiedStr)){
        if (!isEmptyString(result)){
            [result appendString:NSLocalizedString(@" · ", nil)];
        }
        [result appendString:userVerfiedStr];
    }
    
    //如果result是空的，强制显示时间
    if (isEmptyString(result) && !isEmptyString(displayTime)){
        [result appendString:displayTime];
    }
    return result;
}


+ (NSString *)getTimeStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *publishTime = nil;
    double time = data.behotTime;
    if ([data.originalData isKindOfClass:[Article class]]) {
        if ([data article].articlePublishTime > 0) {
            time = [data article].articlePublishTime;
        }
    }
    else if ([data.originalData isKindOfClass:[Comment class]]){
        time = [[[data comment] commentDict] tt_doubleValueForKey:@"create_time"];
    }
    publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
//    if ([data.originalData isKindOfClass:[Article class]]) {
    
//        NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
    
//        publishTime =  [NSString stringWithFormat:@"%@", midnightInterval > 0 ?
//                                  [TTBusinessManager customtimeStringSince1970:time midnightInterval:midnightInterval] :
//                                  [TTBusinessManager customtimeStringSince1970:time]];
//    }
    return publishTime;
}

+ (NSString *)getLikeStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *likeString = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        likeString = [data recommendReason];
    }
    return likeString;
    
}

//第一行推荐理由，现在是动作
+ (NSString *)getRecommendReasonStringWithOrderedData:(ExploreOrderedData *)data
{
    return [data ugcRecommendAction];
}

+ (NSString *)getEntityStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *entityString = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        entityString = [[data article] sourceDesc];
    }
    return entityString;
}

+ (NSString *)getCommentStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *commentString = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        commentString = [[data article] commentContent];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]) {
        commentString = [[data comment] commentContent];
    }
    return commentString;
}

+ (NSString *)getDigNumberStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *digNumber = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        NSNumber *likeCnt = @([[data article] diggCount]);
        if ([data article].userDigg && [likeCnt longLongValue] == 0) {
            likeCnt = [NSNumber numberWithInt:1];
        }
        if ([likeCnt longLongValue] < 0){
            likeCnt = [NSNumber numberWithInt:0];
        }
        digNumber = ([likeCnt longLongValue] > 0 ? [TTBusinessManager formatCommentCount:[likeCnt longLongValue]] : NSLocalizedString(@"赞", nil));
    }
    else if([data.originalData isKindOfClass:[Comment class]]){
        int likeCnt = [[data comment] diggCount];
        if ([data article].userDigg && likeCnt == 0) {
            likeCnt = 1;
        }
        if (likeCnt < 0){
            likeCnt = 0;
        }
        digNumber = (likeCnt > 0 ? [TTBusinessManager formatCommentCount:likeCnt] : NSLocalizedString(@"赞", nil));
    }
    return digNumber;
}

+ (NSString *)getCommentNumberStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *commentNumber = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
         int cmtCnt = [[data article] commentCount];
        commentNumber = (cmtCnt > 0 ? [TTBusinessManager formatCommentCount:cmtCnt] : NSLocalizedString(@"评论", nil));
    }
    else if ([data.originalData isKindOfClass:[Comment class]]) {
        int cmtCnt = [[data comment] commentCount];
        commentNumber = (cmtCnt > 0 ? [TTBusinessManager formatCommentCount:cmtCnt] : NSLocalizedString(@"评论", nil));
    }
    return commentNumber;
}

+ (NSString *)getForwardStringWithOrderedData:(ExploreOrderedData *)data {
    NSString* forwardCount = nil;
    if ([data.originalData isKindOfClass:[Article class]]) { //文章
        int64_t forwardCnt = data.article.actionDataModel.repostCount;
        forwardCount = (forwardCnt > 0 ? [TTBusinessManager formatCommentCount:forwardCnt] : [TTKitchen getString:kKCUGCRepostWordingFeedCellIconTitle]);
    }
    else if ([data.originalData isKindOfClass:[Comment class]]) { //热评
        int64_t forwardCnt = 0;
        if ([[data comment].forwardInfo[@"forward_count"] longLongValue]) {
            forwardCnt = [[data comment].forwardInfo[@"forward_count"] longLongValue];
        }
        forwardCount = (forwardCnt > 0 ? [TTBusinessManager formatCommentCount:forwardCnt] : [TTKitchen getString:kKCUGCRepostWordingFeedCellIconTitle]);
    }
    return forwardCount;
}

+ (NSString *)getTypeStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *typeString = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        if (data.stickStyle != 0) {
            typeString = data.stickLabel;
        }
        else if(data.originalData.userRepined &&
                data.listType != ExploreOrderedDataListTypeFavorite
                && data.listType != ExploreOrderedDataListTypeReadHistory
                && data.listType != ExploreOrderedDataListTypePushHistory) {
            typeString = NSLocalizedString(@"收藏", nil);
        }
        else {
            if (!isEmptyString(data.displayLabel)) {
                typeString = data.displayLabel;
            } else {
                if ((data.tip & 1) > 0)
                {
                    typeString = NSLocalizedString(@"热", nil);
                }
                else if ((data.tip & 2) > 0)
                {
                    typeString = NSLocalizedString(@"荐", nil);
                }
            }
        }

    }
    return typeString;
}

+ (NSString *)getAbstractStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *abstractString = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        abstractString = [[data article] abstract];
    }
    return abstractString;
}

+ (NSString *)getSubscriptStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *subscriptString = nil;
    BOOL subscibed = [[[data article] isSubscribe] boolValue];
    if (subscibed) {
        subscriptString = NSLocalizedString(@"已关注", nil);
    }
    return subscriptString;
}



+ (NSString *)getTimeDurationStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *timeDurationStr = nil;
    long long duration = [data.article.videoDuration longLongValue];

    if (duration > 0) {
        int minute = (int)duration / 60;
        int second = (int)duration % 60;
        timeDurationStr = [NSString stringWithFormat:@"%02i:%02i", minute, second];
    }
    return timeDurationStr;
}

+ (NSString *)getUserAuthInfoWithOrderedData:(ExploreOrderedData *)data
{
    NSString *userAuthInfo = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        userAuthInfo = [[data article] userAuthInfo];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]){
        userAuthInfo = [[data comment] userAuthInfo];
    }
    
    return userAuthInfo;
}

+ (NSString *)getUserDecorationWithOrderedData:(ExploreOrderedData *)data
{
    NSString *userDecoration = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        userDecoration = [[data article] userDecoration];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]){
        userDecoration = [[data comment] userDecoration];
    }
    
    return userDecoration;
}

+ (BOOL)isFollowedWithOrderedData:(ExploreOrderedData *)data
{
    BOOL isFollowed = NO;
    if ([data.originalData isKindOfClass:[Article class]]) {
        isFollowed = [[data article] isFollowed];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]){
        isFollowed = [[data comment] isFollowed];
    }
    return isFollowed;
}

+ (BOOL)userIsFollowedByOthersWithOrderedData:(ExploreOrderedData *)data
{
    BOOL userIsFollowed = NO;
    if ([data.originalData isKindOfClass:[Article class]]) {
        userIsFollowed = [[data article] userIsFollowed];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]) {
        userIsFollowed = [[data comment] userIsFollowed];
    }
    return userIsFollowed;
}

+ (BOOL)shouldShowPlayButtonWithOrderedData:(ExploreOrderedData *)data
{
    BOOL show = NO;
    if ([data.originalData isKindOfClass:[Article class]]) {
        show = [data isListShowPlayVideoButton];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]){
        show = [[[data comment] hasVideo] boolValue];
    }
    return show;
}

+ (void)setFollowed:(BOOL)followed withOrderedData:(ExploreOrderedData *)data
{
    if ([data.originalData isKindOfClass:[Article class]]) {
        [[data article] updateFollowed:followed];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]) {
        [[data comment] setIsFollowed:followed];
    }
}

+ (BOOL)userDiggWithOrderedData:(ExploreOrderedData *)data
{
    BOOL result = NO;
    if ([data.originalData isKindOfClass:[Article class]]) {
        if ([data isUGCCell]){
            result = [[[data article] userLike] boolValue];
        }
        else{
            result = [[data article] userDigg];
        }
    }
    else if([data.originalData isKindOfClass:[Comment class]]){
        result = [[data comment] userDigg];
    }
    return result;
}

+ (NSString *)userIDWithOrderedData:(ExploreOrderedData *)data
{
    NSString *userID = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        userID = [[data article] userIDForAction];
    }
    else if ([data.originalData isKindOfClass:[Comment class]]) {
        userID = [[data comment] userID];
    }
    return userID;
}

+ (NSDictionary *)getLogExtraDictionaryWithOrderedData:(ExploreOrderedData *)data
{
    if (data) {
        NSMutableDictionary * extraDic = [NSMutableDictionary dictionary];
        if ([data isU11Cell]){
            if ([[data originalData] isKindOfClass:[Article class]]) {
                [extraDic setValue:@(SSImpressionModelTypeGroup) forKey:@"gtype"];
                [extraDic setValue:data.cellUIType forKey:@"ctype"];
                [extraDic setValue:@(![[data showFollowButton] boolValue]) forKey:@"follow"];
                [extraDic setValue:[data ugcRecommendAction] forKey:@"recommend_reason"]; //原来上报的就是推荐动作，保持一致
                [extraDic setValue:data.categoryID forKey:@"source"];
            }
            else if ([[data originalData] isKindOfClass:[Comment class]]) {
                Comment *comment = data.comment;
                [extraDic setValue:comment.commentID forKey:@"ext_value"];
                [extraDic setValue:@(SSImpressionModelTypeU11CellListItem) forKey:@"gtype"];
                [extraDic setValue:data.cellUIType forKey:@"ctype"];
                [extraDic setValue:@(![[data showFollowButton] boolValue]) forKey:@"follow"];
                [extraDic setValue:comment.recommendReasonType forKey:@"recommend_reason_type"];
                [extraDic setValue:[data ugcRecommendReason] forKey:@"recommend_reason"];
                [extraDic setValue:data.categoryID forKey:@"source"];
            }
        }
        return extraDic.copy;
    }else {
        return nil;
    }
}

@end

@implementation TTLayOutCellDataHelper (TTAd_feedAdapter)

//当广告为商圈广告时，且有位置信息时，显示位置信息，否则显示评论等信息
+ (BOOL)isAdShowLocation:(ExploreOrderedData *)data{
    if (!data || !data.article || ![data.adModel isCreativeAd]) {
        return NO;
    }
    
    if (data.adModel.adType == ExploreActionTypeLocationAction || data.adModel.adType == ExploreActionTypeLocationForm || data.adModel.adType == ExploreActionTypeLocationcounsel) {
        
        if (!isEmptyString([self getAdLocationStringForUnifyADCellWithOrderData:data WithIndex:0])) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isADSubtitleUserInteractive:(ExploreOrderedData *)data{
    
    if (!data || !data.article || ![data.adModel isCreativeAd]) {
        return NO;
    }
    
    if (data.adModel.adType == ExploreActionTypeLocationAction || data.adModel.adType == ExploreActionTypeLocationForm || data.adModel.adType == ExploreActionTypeLocationcounsel) {
        
        return YES;
    }
    
    return NO;
}

/**
 *  @Server 2017-01-09 策略
 *  1 有source 有subtitle -> subtitle 展示subtitle，  source 展示
 *  2 有source 无subtitle -> subtitle 展示source，  source 不展示
 *  3 无source 有subtitle -> sutitle  展示subtitle，source 无关
 *  *** 生效位置  创意通投的 小图 组图 大图
 *  *** 视频、图片频道 排除该逻辑
 */
+ (BOOL)isAdShowSourece:(ExploreOrderedData *)data {
    if (![data.adModel showActionButton]) {
        return YES;
    }
    if ([data.originalData isKindOfClass:[Article class]]) {
        Article *article = data.article;
        if (article.subtitle == nil && data.raw_ad.sub_title == nil) { //subtitle
            return NO;
        }
    }
    return YES;
}

+ (NSString *)getAdLocationStringForUnifyADCellWithOrderData:(ExploreOrderedData *)data WithIndex:(NSInteger)index{
    
    if (!data || !data.article || ![data.adModel isCreativeAd]) {
        return nil;
    }
    
    NSString *paddingStr =  @"・";
    
    NSMutableString *loacationStr = [NSMutableString stringWithCapacity:30];
    
    if (index == 0) {
        if (!isEmptyString(data.adModel.locationDistrict) ) {
            [loacationStr appendString:data.adModel.locationDistrict];
        }
        
        if (!isEmptyString(data.adModel.locationStreet)) {
            if (!isEmptyString(loacationStr)) {
                [loacationStr appendString:paddingStr];
            }
            [loacationStr appendString:data.adModel.locationStreet];
        }
        
        if (!isEmptyString(data.adModel.locationDisdance)) {
            if (!isEmptyString(loacationStr)) {
                [loacationStr appendString:paddingStr];
            }
            [loacationStr appendString:data.adModel.locationDisdance];
        }
    }
    
    else if (index == 1){
        
        if (!isEmptyString(data.adModel.locationStreet)) {
            [loacationStr appendString:data.adModel.locationStreet];
            
            if (!isEmptyString(data.adModel.locationDisdance)) {
                if (!isEmptyString(loacationStr)) {
                    [loacationStr appendString:paddingStr];
                }
                
                [loacationStr appendString:data.adModel.locationDisdance];
            }
        }
        else {
            
            if (!isEmptyString(data.adModel.locationDistrict) ) {
                [loacationStr appendString:data.adModel.locationDistrict];
                
                if (!isEmptyString(data.adModel.locationDisdance)) {
                    if (!isEmptyString(loacationStr)) {
                        [loacationStr appendString:paddingStr];
                    }
                    
                    [loacationStr appendString:data.adModel.locationDisdance];
                }
            }
            
            else if (!isEmptyString(data.adModel.locationDisdance)) {
                if (!isEmptyString(loacationStr)) {
                    [loacationStr appendString:paddingStr];
                }
                
                [loacationStr appendString:data.adModel.locationDisdance];
            }
        }
        
    }
    
    else if (index == 2){
        
        if (!isEmptyString(data.adModel.locationStreet)) {
            
            [loacationStr appendString:data.adModel.locationStreet];
        }
        
        else if (!isEmptyString(data.adModel.locationDistrict)){
            
            [loacationStr appendString:data.adModel.locationDistrict];
        }
        
        else if (!isEmptyString(data.adModel.locationDisdance)){
            
            [loacationStr appendString:data.adModel.locationDisdance];
        }
    }
    
    return loacationStr;
}

+ (NSString *)getADSourceStringWithOrderedDada:(ExploreOrderedData *)data
{
    NSString *adSourceStr = nil;
    id<TTAdFeedModel> adModel = data.adModel;
    if ([adModel isCreativeAd]) {
        if ([adModel adType] == ExploreActionTypeApp) {
            adSourceStr = [adModel appName];
        } else {
            adSourceStr = [adModel source];
        }
    }
    if (isEmptyString(adSourceStr)) {
        adSourceStr = data.article.source;
    }
    return adSourceStr;
}

+ (NSString *)getInfoStringForUnifyADCellWithOrderedData:(ExploreOrderedData *)data
{
    NSMutableString *infoStr = [NSMutableString stringWithCapacity:30];
    NSString *paddingStr = [TTDeviceHelper isPadDevice] ? @"   " : @"  ";
    int cmtCnt = [[data originalData] commentCount];
    NSString *commentStr = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:cmtCnt], NSLocalizedString(@"评论", nil)];
    if ([data isShowComment]) {
        [infoStr appendString:commentStr];
        [infoStr appendString:paddingStr];
    }
    
    //    NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
    if ([data behotTime] > 0) {
        NSTimeInterval time = [data behotTime];
        NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
        //        NSString *publishTime = (midnightInterval > 0 ? [TTBusinessManager customtimeStringSince1970:time midnightInterval:midnightInterval] : [TTBusinessManager customtimeStringSince1970:time]);
        if (!isEmptyString(publishTime)) {
            [infoStr appendString:publishTime];
        }
    }
    return infoStr;
}

+ (NSString *)getCommentStringForUnifyADCellWithOrderedData:(ExploreOrderedData *)data
{
    NSMutableString *infoStr = [NSMutableString stringWithCapacity:30];
    int cmtCnt = [[data originalData] commentCount];
    NSString *commentStr = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:cmtCnt], NSLocalizedString(@"评论", nil)];
    if ([data isShowComment]) {
        [infoStr appendString:commentStr];
    }
    return infoStr;
}

+ (NSString *)getSubtitleStringWithOrderedData:(ExploreOrderedData *)data
{
    NSString *subtitle = nil;
    if ([data.originalData isKindOfClass:[Article class]]) {
        subtitle = data.adModel.sub_title;
        Article *article = data.article;
        if (isEmptyString(subtitle)) { //subtitle 存在Article级别，不仅仅为广告而存在
            subtitle = article.subtitle;
        }
        if (isEmptyString(subtitle)) {
            subtitle = [self getADSourceStringWithOrderedDada:data];
        }
    }
    return subtitle;
}

+ (NSString *)getTitleStyle1WithOrderedData:(ExploreOrderedData *)data {
    id<TTAdFeedModel> adModel = data.adModel;
    NSString *title = nil;
    if ([adModel isCreativeAd]) {
        BOOL call2Action = ([[adModel type] isEqualToString:@"action"]);
        title = (call2Action ? adModel.title : adModel.descInfo);
    }
    if(isEmptyString(title)) {
        title = data.article.title;
    }
    return title;
}

+ (NSString *)getTitleStyle2WithOrderedData:(ExploreOrderedData *)data {
    id<TTAdFeedModel> adModel = data.adModel;
    BOOL isApp = (adModel.adType == ExploreActionTypeApp);
    NSString *title = (isApp ? adModel.descInfo : adModel.title);
    if (isEmptyString(title)){//普通大图时
        title = [data article].title;
    }
    return title;
}


@end
