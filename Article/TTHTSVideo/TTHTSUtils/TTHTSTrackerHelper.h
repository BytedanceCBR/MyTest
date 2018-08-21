//
//  TTHTSTrackerHelper.h
//  Article
//
//  Created by 王双华 on 2017/5/26.
//
//

#import <Foundation/Foundation.h>

@class ExploreOrderedData;

@interface TTHTSTrackerHelper : NSObject

+ (void)trackUnInterestButtonClickedWithExploreOrderData:(ExploreOrderedData *)orderedData extraParams:(NSDictionary *)extraParams;

+ (void)trackDislikeViewOKBtnClickedWithExploreOrderData:(ExploreOrderedData *)orderedData extraParams:(NSDictionary *)extraParams;

@end
