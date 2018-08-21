//
//  TTRChannel.m
//  Article
//
//  Created by muhuai on 2017/5/23.
//
//

#import "TTRChannel.h"
#import "TTArticleCategoryManager.h"

@implementation TTRChannel
TTR_PROTECTED_HANDLER(@"TTRChannel.addChannel", @"TTRChannel.getSubScribedChannelList")

- (void)addChannelWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *categoryID = [param objectForKey:@"category"];
    if(isEmptyString(categoryID)) {
        callback(TTRJSBMsgParamError, @{@"code": @0});
        return;
    }
    
    TTCategory *categoryModel = [TTArticleCategoryManager categoryModelByCategoryID:categoryID];
    if (!categoryModel) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:categoryID forKey:@"category"];
        [dict setValue:[param objectForKey:@"name"] forKey:@"name"];
        [dict setValue:[param objectForKey:@"type"] forKey:@"type"];
        [dict setValue:[param objectForKey:@"web_url"] forKey:@"web_url"];
        [dict setValue:[param objectForKey:@"flags"] forKey:@"flags"];
        categoryModel = [TTArticleCategoryManager insertCategoryWithDictionary:dict];
    }
    
    NSMutableDictionary * extraDict = [[NSMutableDictionary alloc] initWithDictionary:param];
    [extraDict setValue:categoryID forKey:@"category_name"];
    [extraDict setValue:nil forKey:@"category"];
    wrapperTrackEventWithCustomKeys(@"add_channel", @"click", nil, nil, extraDict);
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:categoryModel forKey:kTTInsertCategoryNotificationCategoryKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTInsertCategoryToLastPositionNotification object:self userInfo:userInfo];
    
    callback(TTRJSBMsgSuccess, @{@"code": @1});
    return;
}

- (void)getSubScribedChannelListWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSArray *categories = [[TTArticleCategoryManager sharedManager] subScribedCategories];
    __block NSMutableArray *list = [NSMutableArray array];
    [categories enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTCategory class]]) {
            TTCategory *category = (TTCategory *)obj;
            if (!isEmptyString(category.categoryID)) {
                [list addObject:category.categoryID];
            }
        }
    }];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
    [data setValue:@(1) forKey:@"code"];
    [data setValue:list forKey:@"list"];
    
    callback(TTRJSBMsgSuccess, data);
    return;
}
@end
