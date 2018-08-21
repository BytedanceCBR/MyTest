//
//  ExploreWidgetImpressionManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-16.
//
//

#import <Foundation/Foundation.h>

@interface ExploreWidgetImpressionManager : NSObject


- (void)startRecordItems:(NSArray *)items;
- (void)endRecord;
- (void)save;
@end
