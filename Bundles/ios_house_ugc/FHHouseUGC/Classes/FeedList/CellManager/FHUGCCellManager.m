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

        default:
            break;
    }
    
    return [FHUGCPureTitleCell class];
}

@end
