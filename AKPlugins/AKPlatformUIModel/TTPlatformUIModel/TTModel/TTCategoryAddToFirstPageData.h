//
//  TTCategoryAddToFirstPageData.h
//  Article
//
//  Created by xuzichao on 16/9/7.
//
//

#import "ExploreOriginalData.h"
#import "JSONModel.h"

@interface TTCategoryAddToFirstActionData : JSONModel

@property (nonatomic, copy)     NSNumber  * flag;
@property (nonatomic, copy)     NSString  * name;
@property (nonatomic, copy)     NSNumber  * type;
@property (nonatomic, copy)     NSString  * category;
@property (nonatomic, copy)     NSString  * webUrl;

@end

@interface TTCategoryAddToFirstPageData : ExploreOriginalData

@property (nonatomic, copy)     NSString  * cellId;
@property (nonatomic, copy)     NSNumber  * behotTime;
@property (nonatomic, copy)     NSNumber  * cellType;
@property (nonatomic, copy)     NSNumber  * cursor;
@property (nonatomic, copy)     NSNumber  * jumpType;
@property (nonatomic, copy)     NSString  * text;
@property (nonatomic, copy)     NSString  * openUrl;
@property (nonatomic, copy)     NSString  * buttonText;
@property (nonatomic, copy)     NSString  * iconUrl;
@property (nonatomic, strong)   NSDictionary  * recommendImage;
@property (nonatomic, copy)     NSNumber  * showBottomSeparator;
@property (nonatomic, copy)     NSNumber  * showTopSeparator;
@property (nonatomic, strong)   NSDictionary * action;

@end
