//
//  FHUGCCellManager.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCCellManager.h"
#import "FHUGCRecommendCell.h"
#import "FHUGCBannerCell.h"
#import "FHUGCHotTopicCell.h"
#import "FHUGCVideoCell.h"
#import "FHUGCSmallVideoCell.h"
#import "FHUGCVoteDetailCell.h"
#import "FHUGCHotCommunityCell.h"
#import "FHNeighbourhoodQuestionCell.h"
#import "FHNeighbourhoodCommentCell.h"
#import "FHUGCLynxBannerCell.h"
#import "FHLynxManager.h"
#import "FHUGCRecommendCircleCell.h"
#import "FHUGCEncyclopediasCell.h"
#import "FHUGCLynxCommonCell.h"
#import "FHArticleCell.h"
#import "FHUGCPostCell.h"
#import "FHUGCAnswerCell.h"
#import "FHUGCQuestionCell.h"
#import "FHHouseDeatilRGCImageCell.h"
#import "FHHouseDeatilRGCVideoCell.h"
#import "FHUGCFullScreenVideoCell.h"
#import "FHUGCShortVideoListCell.h"
#import "FHOldHouseDeatilRGCImageCell.h"
#import "FHOldHouseDeatilRGCVideoCell.h"

//布局类
#import "FHBaseLayout.h"
#import "FHArticleLayout.h"
#import "FHPostLayout.h"
#import "FHVideoLayout.h"
#import "FHAnswerLayout.h"
#import "FHFullScreenVideoLayout.h"
#import "FHSmallVideoLayout.h"

@interface FHUGCCellManager ()

@property(nonatomic, strong) NSArray *supportCellTypeList;

@end

@implementation FHUGCCellManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSupportCellTypeList];
    }
    return self;
}

- (void)initSupportCellTypeList {
    self.supportCellTypeList = @[
                                @"FHUGCPostCell",
                                @"FHArticleCell",
                                @"FHUGCRecommendCell",
                                @"FHUGCLynxBannerCell",
                                @"FHUGCBannerCell",
                                @"FHUGCHotTopicCell",
                                @"FHUGCVideoCell",
                                @"FHUGCSmallVideoCell",
                                @"FHUGCVoteDetailCell",
                                @"FHUGCHotCommunityCell",
                                @"FHNeighbourhoodQuestionCell",
                                @"FHNeighbourhoodCommentCell",
                                @"FHUGCRecommendCircleCell",
                                @"FHUGCEncyclopediasCell",
                                @"FHUGCLynxCommonCell",
                                @"FHHouseDeatilRGCImageCell",
                                @"FHHouseDeatilRGCVideoCell",
                                @"FHUGCAnswerCell",
                                @"FHUGCQuestionCell",
                                @"FHUGCFullScreenVideoCell",
                                @"FHUGCShortVideoListCell",
                                @"FHOldHouseDeatilRGCVideoCell",
                                @"FHOldHouseDeatilRGCImageCell"
                                //可扩展
                                 ];
}

- (void)registerAllCell:(UITableView *)tableView {
    for (NSString *cellIdentifier in self.supportCellTypeList) {
        [tableView registerClass:NSClassFromString(cellIdentifier) forCellReuseIdentifier:cellIdentifier];
    }
}

- (Class)cellClassFromCellViewType:(FHUGCFeedListCellSubType)cellType data:(nullable id)data {
    //这里这样写是为了以后一个key可能对应不同cell的变化
    switch (cellType) {
        case FHUGCFeedListCellSubTypePost:
            return [FHUGCPostCell class];
            
        case FHUGCFeedListCellSubTypeArticle:
            return [FHArticleCell class];
            
        case FHUGCFeedListCellSubTypeUGCRecommend:
            return [FHUGCRecommendCell class];
            
        case FHUGCFeedListCellSubTypeUGCBanner:
            return [[FHLynxManager sharedInstance] checkChannelTemplateIsAvalable:kFHLynxUGCOperationChannel templateKey:[FHLynxManager defaultJSFileName]] ? [FHUGCLynxBannerCell class] : [FHUGCBannerCell class];
            
        case FHUGCFeedListCellSubTypeUGCHotTopic:
            return [FHUGCHotTopicCell class];
            
        case FHUGCFeedListCellSubTypeUGCVideo:
            return [FHUGCVideoCell class];
            
        case FHUGCFeedListCellSubTypeUGCSmallVideo:
            return [FHUGCSmallVideoCell class];
            
        case FHUGCFeedListCellSubTypeUGCVoteDetail:
            return [FHUGCVoteDetailCell class];
            
        case FHUGCFeedListCellSubTypeUGCHotCommunity:
            return [FHUGCHotCommunityCell class];
            
        case FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion:
            return [FHNeighbourhoodQuestionCell class];
            
        case FHUGCFeedListCellSubTypeUGCNeighbourhoodComments:
            return [FHNeighbourhoodCommentCell class];
            
        case FHUGCFeedListCellSubTypeUGCRecommendCircle:
            return [FHUGCRecommendCircleCell class];
            
        case FHUGCFeedListCellSubTypeUGCEncyclopedias:
            return [FHUGCEncyclopediasCell class];
            
        case FHUGCFeedListCellSubTypeUGCLynx:
            return [FHUGCLynxCommonCell class];
            
        case FHUGCFeedListCellSubTypeUGCBrokerImage:
            return [FHHouseDeatilRGCImageCell class];
            
        case FHUGCFeedListCellSubTypeUGCBrokerVideo:
            return [FHHouseDeatilRGCVideoCell class];
            
        case FHUGCFeedListCellSubTypeAnswer:
            return [FHUGCAnswerCell class];
            
        case FHUGCFeedListCellSubTypeQuestion:
            return [FHUGCQuestionCell class];
            
        case FHUGCFeedListCellSubTypeFullVideo:
            return [FHUGCFullScreenVideoCell class];
        case FHUGCFeedListCellSubTypeSmallVideoList:
            return [FHUGCShortVideoListCell class];
            
        case FHUGCFeedListCellSubTypeOldHouseUGCBrokerImage:
            return [FHOldHouseDeatilRGCImageCell class];
            
        case FHUGCFeedListCellSubTypeOldHouseUGCBrokerVideo:
            return [FHOldHouseDeatilRGCVideoCell class];
            
        default:
            break;
    }
    
    return [FHUGCPostCell class];
}

+ (Class)cellLayoutClassFromCellViewType:(FHUGCFeedListCellSubType)cellType cellModel:(FHFeedUGCCellModel *)cellModel {
    //这里这样写是为了以后一个key可能对应不同cell的变化
    switch (cellType) {
        case FHUGCFeedListCellSubTypePost:
            if([cellModel.cellLayoutStyle isEqualToString:@"10001"]){
                return nil;
            }
            return [FHPostLayout class];
            
        case FHUGCFeedListCellSubTypeArticle:
            return [FHArticleLayout class];
//
//        case FHUGCFeedListCellSubTypeUGCRecommend:
//            return [FHUGCRecommendCell class];
//
//        case FHUGCFeedListCellSubTypeUGCBanner:
//            return [[FHLynxManager sharedInstance] checkChannelTemplateIsAvalable:kFHLynxUGCOperationChannel templateKey:[FHLynxManager defaultJSFileName]] ? [FHUGCLynxBannerCell class] : [FHUGCBannerCell class];
//
//        case FHUGCFeedListCellSubTypeUGCHotTopic:
//            return [FHUGCHotTopicCell class];
//
        case FHUGCFeedListCellSubTypeUGCVideo:
            return [FHVideoLayout class];

        case FHUGCFeedListCellSubTypeUGCSmallVideo:
            if([cellModel.cellLayoutStyle isEqualToString:@"10001"]){
                return nil;
            }
            return [FHSmallVideoLayout class];
//
//        case FHUGCFeedListCellSubTypeUGCVoteDetail:
//            return [FHUGCVoteDetailCell class];
//
//        case FHUGCFeedListCellSubTypeUGCHotCommunity:
//            return [FHUGCHotCommunityCell class];
//
//        case FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion:
//            return [FHNeighbourhoodQuestionCell class];
//
//        case FHUGCFeedListCellSubTypeUGCNeighbourhoodComments:
//            return [FHNeighbourhoodCommentCell class];
//
//        case FHUGCFeedListCellSubTypeUGCRecommendCircle:
//            return [FHUGCRecommendCircleCell class];
//
//        case FHUGCFeedListCellSubTypeUGCEncyclopedias:
//            return [FHUGCEncyclopediasCell class];
//
//        case FHUGCFeedListCellSubTypeUGCLynx:
//            return [FHUGCLynxCommonCell class];
//
//        case FHUGCFeedListCellSubTypeUGCBrokerImage:
//            return [FHHouseDeatilRGCImageCell class];
//
//        case FHUGCFeedListCellSubTypeUGCBrokerVideo:
//            return [FHHouseDeatilRGCVideoCell class];
//
        case FHUGCFeedListCellSubTypeAnswer:
            return [FHAnswerLayout class];
//
//        case FHUGCFeedListCellSubTypeQuestion:
//            return [FHUGCQuestionCell class];
//
        case FHUGCFeedListCellSubTypeFullVideo:
            return [FHFullScreenVideoLayout class];
//        case FHUGCFeedListCellSubTypeSmallVideoList:
//            return [FHUGCShortVideoListCell class];
            
        default:
            break;
    }
    
    return nil;
}

+ (SSImpressionModelType)impressModelTypeWithCellType:(FHUGCFeedListCellType)cellType {
    SSImpressionModelType type = SSImpressionModelTypeNone;
    switch (cellType) {
        case FHUGCFeedListCellTypeArticle:
            type = SSImpressionModelTypeGroup;
            break;
        case FHUGCFeedListCellTypeUGC:
            type = SSImpressionModelTypeThread;
            break;
        case FHUGCFeedListCellTypeUGCSmallVideo:
        case FHUGCFeedListCellTypeUGCSmallVideo2:
            type = SSImpressionModelTypeUGCVideo;
            break;
        case FHUGCFeedListCellTypeAnswer:
            type = SSImpressionModelTypeFeedAwswerItem;
            break;
        case FHUGCFeedListCellTypeQuestion:
            type = SSImpressionModelTypeFeedQuestionItem;
            break;
        case FHUGCFeedListCellTypeArticleComment:
        case FHUGCFeedListCellTypeArticleComment2:
            type = SSImpressionModelTypeFeedCommentItem;
            break;
        case FHUGCFeedListCellTypeUGCVoteInfo:
            type = SSImpressionModelTypeFeedVoteItem;
            break;
        case FHUGCFeedListCellTypeUGCEncyclopedias:
            type = SSImpressionModelTypeFeedHouseKnowledgeItem;
            break;
            
        default:
            break;
    }
    
    return type;
}

@end

