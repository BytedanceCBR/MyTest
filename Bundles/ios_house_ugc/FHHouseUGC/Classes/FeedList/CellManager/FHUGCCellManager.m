//
//  FHUGCCellManager.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCCellManager.h"

#import "FHUGCPureTitleCell.h"
#import "FHUGCSingleImageCell.h"
#import "FHUGCMultiImageCell.h"
#import "FHArticlePureTitleCell.h"
#import "FHArticleSingleImageCell.h"
#import "FHArticleMultiImageCell.h"
#import "FHUGCRecommendCell.h"
#import "FHUGCBannerCell.h"
#import "FHUGCHotTopicCell.h"
#import "FHUGCVoteCell.h"
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
                                @"FHUGCPureTitleCell",
                                @"FHUGCSingleImageCell",
                                @"FHUGCMultiImageCell",
                                @"FHArticlePureTitleCell",
                                @"FHArticleSingleImageCell",
                                @"FHArticleMultiImageCell",
                                @"FHUGCRecommendCell",
                                @"FHUGCLynxBannerCell",
                                @"FHUGCBannerCell",
                                @"FHUGCHotTopicCell",
                                @"FHUGCVoteCell",
                                @"FHUGCVideoCell",
                                @"FHUGCSmallVideoCell",
                                @"FHUGCVoteDetailCell",
                                @"FHUGCHotCommunityCell",
                                @"FHNeighbourhoodQuestionCell",
                                @"FHNeighbourhoodCommentCell",
                                @"FHUGCRecommendCircleCell",
                                @"FHUGCEncyclopediasCell",
                                @"FHUGCLynxCommonCell",
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
            
        case FHUGCFeedListCellSubTypePureTitle:
            return [FHUGCPureTitleCell class];
            
        case FHUGCFeedListCellSubTypeSingleImage:
            return [FHUGCSingleImageCell class];
            
        case FHUGCFeedListCellSubTypeMultiImage:
            return [FHUGCMultiImageCell class];
            
        case FHUGCFeedListCellSubTypeArticlePureTitle:
            return [FHArticlePureTitleCell class];
            
        case FHUGCFeedListCellSubTypeArticleSingleImage:
            return [FHArticleSingleImageCell class];
            
        case FHUGCFeedListCellSubTypeArticleMultiImage:
            return [FHArticleMultiImageCell class];
            
        case FHUGCFeedListCellSubTypeUGCRecommend:
            return [FHUGCRecommendCell class];

        case FHUGCFeedListCellSubTypeUGCBanner:
            return [[FHLynxManager sharedInstance] checkChannelTemplateIsAvalable:kFHLynxUGCOperationChannel templateKey:[FHLynxManager defaultJSFileName]] ? [FHUGCLynxBannerCell class] : [FHUGCBannerCell class];
            
        case FHUGCFeedListCellSubTypeUGCHotTopic:
            return [FHUGCHotTopicCell class];
            
        case FHUGCFeedListCellSubTypeUGCVote:
            return [FHUGCVoteCell class];
            
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
        default:
            break;
    }
    
    
    
    return [FHUGCPureTitleCell class];
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
