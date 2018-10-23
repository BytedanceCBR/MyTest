//
//  TTWendaCellHelper.h
//  Article
//
//  Created by wangqi.kaisa on 2017/7/13.
//
//

#import <Foundation/Foundation.h>
#import "TTCellBridge.h"

/*
 * 7.13  在feed展示问答cell的帮助类
 */

@class ExploreOrderedData;

@interface TTWendaCellHelper : NSObject <TTCellDataHelper>

+ (void)registerCellViewAndCellDataHelper;

+ (nullable ExploreOrderedData *)verifyWithWendaOrderedData:(nullable id)orderedData;

@end
