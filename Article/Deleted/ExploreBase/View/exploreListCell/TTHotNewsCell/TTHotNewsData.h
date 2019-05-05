//
//  TTHotNewsData.h
//  Article
//
//  Created by Sunhaiyuan on 2018/1/22.
//

#import "ExploreOriginalData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"

@interface TTHotNewsData : ExploreOriginalData
@property (nonatomic, assign)           NSUInteger           groupId;
@property (nonatomic, assign)           long                 aggrType;
@property (nonatomic, assign)           long                 behotTime;
@property (nullable, nonatomic, copy)   NSString             *showMoreDesc;
@property (nullable, nonatomic, copy)   NSString             *showMoreSchemaUrl;
@property (nullable, nonatomic, strong) NSDictionary         *rawData;
@property (nullable, nonatomic, copy)   NSString             *label;
@property (nonatomic, assign) BOOL                           showDislike;

- (nullable ExploreOrderedData *)internalData;
@end
