//
//  TTCellWendaHelper.m
//  Article
//
//  Created by xuzichao on 2017/7/7.
//
//

#import "TTCellWendaHelper.h"
#import "ExploreOrderedData.h"
#import "WDNativeListBaseCell.h"

@implementation TTCellWendaHelper

+ (Class)cellClassFromData:(id)data {
    if (data) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        //先处理视频频道大图广告样式
        if (orderedData.cellType == ExploreOrderedWenDaCategoryBaseCell) {
            return [WDNativeListBaseCell class];
        }
    }
    
    return nil;
    
}

+ (void)registerCellViewAndCellDataHelper {
    [[TTCellBridge sharedInstance] registerCellDataClass:[ExploreOrderedData class] cellDataHelperClass:self];
}

@end
