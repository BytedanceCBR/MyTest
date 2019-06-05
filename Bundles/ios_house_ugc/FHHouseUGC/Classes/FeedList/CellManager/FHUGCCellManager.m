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
#import "FHUGCTwoImageCell.h"
#import "FHArticlePureTitleCell.h"
#import "FHArticleSingleImageCell.h"
#import "FHArticleMultiImageCell.h"

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
                                @"FHUGCTwoImageCell",
                                @"FHArticlePureTitleCell",
                                @"FHArticleSingleImageCell",
                                @"FHArticleMultiImageCell",
                                
                                
                                //可扩展
                                 ];
}

- (void)registerAllCell:(UITableView *)tableView {
    for (NSString *cellIdentifier in self.supportCellTypeList) {
        [tableView registerClass:NSClassFromString(cellIdentifier) forCellReuseIdentifier:cellIdentifier];
    }
}

- (Class)cellClassFromCellViewType:(FHUGCFeedListCellType)cellType data:(nullable id)data {
    //这里这样写是为了以后一个key可能对应不同cell的变化
    switch (cellType) {
            
        case FHUGCFeedListCellTypePureTitle:
            return [FHUGCPureTitleCell class];
            
        case FHUGCFeedListCellTypeSingleImage:
            return [FHUGCSingleImageCell class];
            
        case FHUGCFeedListCellTypeTwoImage:
            return [FHUGCTwoImageCell class];
            
        case FHUGCFeedListCellTypeMultiImage:
            return [FHUGCMultiImageCell class];
            
        case FHUGCFeedListCellTypeArticlePureTitle:
            return [FHArticlePureTitleCell class];
            
        case FHUGCFeedListCellTypeArticleSingleImage:
            return [FHArticleSingleImageCell class];
            
        case FHUGCFeedListCellTypeArticleMultiImage:
            return [FHArticleMultiImageCell class];

        default:
            break;
    }
    
    return [FHUGCPureTitleCell class];
}

@end
