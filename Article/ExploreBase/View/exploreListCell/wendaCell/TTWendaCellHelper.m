//
//  TTWendaCellHelper.m
//  Article
//
//  Created by wangqi.kaisa on 2017/7/13.
//
//

#import "TTWendaCellHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTWendaQuestionCell.h"
#import "TTWendaAnswerCell.h"
#import "TTWendaQuestionCellView.h"
#import "TTWendaAnswerCellView.h"
#import "WDNativeListBaseCell.h"
#import "TTWenda.h"

@implementation TTWendaCellHelper

+ (void)registerCellViewAndCellDataHelper {
    [[TTCellBridge sharedInstance] registerCellClass:[TTWendaQuestionCell class] cellViewClass:[TTWendaQuestionCellView class]];
    [[TTCellBridge sharedInstance] registerCellClass:[TTWendaAnswerCell class] cellViewClass:[TTWendaAnswerCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellDataClass:[ExploreOrderedData class] cellDataHelperClass:self];
}

+ (ExploreOrderedData *)verifyWithWendaOrderedData:(id)orderedData {
    if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *threadOrderedData = orderedData;
        if ((threadOrderedData.cellType == ExploreOrderedDataCellTypeWendaAnswer || threadOrderedData.cellType == ExploreOrderedDataCellTypeWendaQuestion) && [threadOrderedData.originalData isKindOfClass:[TTWenda class]]) {
            return threadOrderedData;
        }
    }
    return nil;
}

#pragma mark - TTCellDataHelper

+ (Class)cellClassFromData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = data;
        if ([orderedData.originalData isKindOfClass:[TTWenda class]]) {
            if (orderedData.cellType == ExploreOrderedDataCellTypeWendaAnswer) {
                return [TTWendaAnswerCell class];
            }
            else if (orderedData.cellType == ExploreOrderedDataCellTypeWendaQuestion) {
                return [TTWendaQuestionCell class];
            }
        }
        else if (orderedData.cellType == ExploreOrderedWenDaCategoryBaseCell) {
            return [WDNativeListBaseCell class];
        }
    }
    return nil;
}

@end
