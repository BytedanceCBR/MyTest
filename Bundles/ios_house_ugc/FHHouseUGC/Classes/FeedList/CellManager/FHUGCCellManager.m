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
                                @"FHUGCBannerCell",
                                @"FHUGCHotTopicCell",
                                @"FHUGCVoteCell",
                                @"FHUGCVideoCell",
                                @"FHUGCSmallVideoCell",
                                @"FHUGCVoteDetailCell",
                                @"FHUGCHotCommunityCell",
                                @"FHNeighbourhoodQuestionCell",
                                @"FHNeighbourhoodCommentCell",
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
            return [FHUGCBannerCell class];
            
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
        default:
            break;
    }
    
    return [FHUGCPureTitleCell class];
}

+ (SSImpressionModelType)impressModelTypeWithCellType:(FHUGCFeedListCellType)cellType {
    SSImpressionModelType type = SSImpressionModelTypeGroup;
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
            
        default:
            break;
    }
    
    return type;
}

//FHUGCFeedListCellTypeArticle = 0,                      //文章
//FHUGCFeedListCellTypeAnswer = 202,                     //问答答案
//FHUGCFeedListCellTypeQuestion = 203,                   //问答问题
//FHUGCFeedListCellTypeArticleComment = 41,              //文章评论
//FHUGCFeedListCellTypeArticleComment2 = 56,             //文章评论
//FHUGCFeedListCellTypeUGC = 32,                         //帖子
//FHUGCFeedListCellTypeUGCRecommend = 1101,              //小区推荐
//FHUGCFeedListCellTypeUGCBanner = 2002,                 //运营位
//FHUGCFeedListCellTypeUGCBanner2 = 1102,                //运营位
//FHUGCFeedListCellTypeUGCHotTopic = 1104,               //热门话题
//FHUGCFeedListCellTypeUGCVote = 1103,                   //投票pk
//FHUGCFeedListCellTypeUGCSmallVideo = 333,              //小视频
//FHUGCFeedListCellTypeUGCVoteInfo = 1107,



//typedef NS_ENUM(NSUInteger, SSImpressionModelType)
//{
//    SSImpressionModelTypeGroup                  = 1,        //group item
//    SSImpressionModelTypeAD                     = 2,        //ad item
//    SSImpressionModelTypeComment                = 20,       //评论
//    SSImpressionModelTypeMoment                 = 21,       //动态
//    SSImpressionModelTypeSubject                = 99999,    //专题，目前和group发送的状态码一样，但是客户端发送逻辑不同，区分定义
//    SSImpressionModelTypeExploreDetail          = 31,       //文章详情页
//    SSImpressionModelTypeForumList              = 32,       //话题列表
//    SSImpressionModelTypeThread                 = 33,       //话题帖子
//    SSImpressionModelTypeThreadComment          = 34,       //帖子评论
//    SSImpressionModelTypeMomoAD                 = 35,       //陌陌广告
//    SSImpressionModelTypeVideoDetail            = 36,       //视频详情页相关视频
//    SSImpressionModelTypeRelatedItem            = 37,       //详情页相关区域的item
//    SSImpressionModelTypeConcernListItem        = 38,       //关心列表的cell
//    SSImpressionModelTypeWendaListItem          = 39,       //问答回答列表的cell
//    SSImpressionModelTypeWeitoutiaoListItem     = 41,       //微头条列表的cell
//    SSImpressionModelTypeHouShanListItem        = 45,       //火山直播的cell
//    SSImpressionModelTypeLianZaiListItem        = 46,       //小说连载的cell
//    SSImpressionModelTypeLiveListItem           = 48,       //直播cell
//    SSImpressionModelTypeU11CellListItem        = 49,       //U11cell
//    SSImpressionModelTypeU11RecommendUserItem   = 51,       //u11推人
//    SSImpressionModelTypeHuoShanTalentBanner    = 52,       //火山达人频道活动banner
//    SSImpressionModelTypeArticleListItem        = 53,       //文章详情页订阅推荐组件Cell
//    SSImpressionModelTypeVideoListItem          = 54,       //视频详情页订阅推荐组件Cell
//    SSImpressionModelTypeHuoShanVideoInHTSTab   = 55,       //火山小视频tab上的火山cell
//    SSImpressionModelTypeHuoShanVideoInHoriCard = 56,       //水平卡片上的火山cell
//    SSImpressionModelTypeUGCVideo               = 57,       //ugc小视频 火山和抖音
//    SSImpressionModelTypeVideoFloat             = 60,       //视频浮层的cell
//    SSImpressionModelTypeMessageNotification    = 65,       //消息通知的cell
//    SSImpressionModelTypeStory                  = 66,       //story的cell
//    SSImpressionModelTypeU11MomentsRecommendUserItem    = 70,       //u11好友动态推人
//    SSImpressionModelTypeCommentRepostDetail    = 71,       //转发详情页
//    SSImpressionModelTypeUGCRepostCommon        = 73,       //通用转发
//    SSImpressionModelTypeHashtag                = 74,       //feed话题卡片
//    SSImpressionModelTypeShortVideoActivityEntrance     = 76,       //小视频活动入口
//    SSImpressionModelTypeShortVideoActivityBananer      = 77,       //小视频活动banner
//    SSImpressionModelTypeXiguaRecommendItem     = 81,               //西瓜直播入口
//    SSImpressionModelTypeRecommendUserStory     = 82,               //推人Story
//    SSImpressionModelTypeRecommendStoryCover     = 83,               //推人Story
//    SSImpressionModelTypePopularHashtagItem     = 84,               //热门话题
//    SSImpressionModelTypeHotNewsSingleItem       = 85,          //热点要闻 单条样式
//    SSImpressionModelTypeHotNewsSMultiItem       = 86,        //热点要闻  多条样式
//
//    //F项目增加
//    SSImpressionModelTypeFeedAwswerItem              = 1001,        //问答问题
//    SSImpressionModelTypeFeedQuestionItem            = 1002,        //问答回答
//    SSImpressionModelTypeFeedCommentItem             = 1003,        //文章评论
//    SSImpressionModelTypeFeedVoteItem                = 1004,        //UGC投票
//    SSImpressionModelTypeFeedHouseKnowledgeItem      = 1005,        //购房百科
//};

@end
