//
//  ExploreWidgetFetchListManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-11.
//
//

#import <Foundation/Foundation.h>


#define kExploreWidgetMaxItemCount (([UIScreen mainScreen].bounds.size.height <= 480)? 3 : 4)

@protocol ExploreWidgetFetchListManagerDelegate;

@interface ExploreWidgetFetchListManager : NSObject

@property(nonatomic, assign, readonly)BOOL isLoading;

@property(nonatomic, retain)NSArray * itemModels;

@property(nonatomic, weak)id<ExploreWidgetFetchListManagerDelegate>delegate;

- (void)fetchRequest;

- (void)tryFetchRequest;

@end

@protocol ExploreWidgetFetchListManagerDelegate <NSObject>

- (void)widgetLoadDataFinish:(ExploreWidgetFetchListManager *)manager;
- (void)widgetLoadDataFailed:(ExploreWidgetFetchListManager *)manager;

@end
