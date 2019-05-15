//
//  ArticleBaseListView.m
//  Article
//
//  Created by Yu Tianhang on 13-2-22.
//
//

#import "ArticleBaseListView.h"

@interface ArticleBaseListView()
@end

@implementation ArticleBaseListView
@synthesize currentCategory, delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kClearCacheFinishedNotification object:nil];
    self.currentCategory = nil;
    self.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cacheCleared:) name:kClearCacheFinishedNotification object:nil];

    }
    return self;
}

- (void)cacheCleared:(NSNotification*)notification
{
    // could be extended
}

- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType
{
    self.currentCategory = category;
    self.isCurrentDisplayView = display;
}

- (void)refreshDisplayView:(BOOL)display {
    self.isCurrentDisplayView = display;
}

- (void)refreshCategory:(TTCategory *)model
{
    self.currentCategory = model;
}

- (void)pullAndRefresh{}
- (void)scrollToBottomAndLoadmore{}
- (void)scrollToTopEnable:(BOOL)enable{
    
}
- (void)closePadComments{}
- (void)refresh{}
- (void)cancelAllOperation{}
- (void)listViewWillEnterForground{}
- (void)listViewWillEnterBackground{}

- (void)trackPullDownEventForLabel:(NSString *)label {
    NSString *categoryID = self.currentCategory.categoryID;
    NSString *concernID = self.currentCategory.concernID;
    
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    
    if (!isEmptyString(categoryID)) {
        if (![categoryID isEqualToString:kTTMainCategoryID]) {
            label = [label stringByAppendingFormat:@"_%@", categoryID];
        }
    }
    
    [dictionary setValue:label forKey:@"label"];
    [dictionary setValue:@"umeng" forKey:@"category"];
    [dictionary setValue:@"category" forKey:@"tag"];
    
    if (!isEmptyString(categoryID)) {
        [dictionary setValue:categoryID forKey:@"category_id"];
    }
    if (!isEmptyString(concernID)) {
        [dictionary setValue:concernID forKey:@"concern_id"];
    }
    [dictionary setValue:@(1) forKey:@"refer"];//1表示从首页的频道，2表示关心tab的频道
    
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTrackerWrapper eventData:dictionary];
    }
    
    [self trackRefershEvent3];
}

//log3.0
- (void)trackRefershEvent3
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setValue:self.currentCategory.categoryID forKey:@"category_name"];
    [dict setValue:self.currentCategory.concernID forKey:@"concern_id"];
    [dict setValue:@(1) forKey:@"refer"];
    [dict setValue:@"pull" forKey:@"refresh_type"];
    [TTTrackerWrapper eventV3:@"category_refresh" params:dict isDoubleSending:YES];
}

- (BOOL)needClearRecommendTabBadge{
    return YES;
}

@end
