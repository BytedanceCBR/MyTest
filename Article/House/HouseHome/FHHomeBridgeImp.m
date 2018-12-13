//
//  FHHomeBridgeImp.m
//  Article
//
//  Created by 谢飞 on 2018/12/11.
//

#import "FHHomeBridgeImp.h"
#import "TTArticleCategoryManager.h"

@implementation FHHomeBridgeImp

- (NSString *)feedStartCategoryName
{
    NSString * categoryStartName = [SSCommonLogic feedStartCategory];
    return categoryStartName;
}


- (NSString *)currentSelectCategoryName
{
    NSString * currentCategoryName = [TTArticleCategoryManager currentSelectedCategoryID];
    return currentCategoryName;
}

@end
