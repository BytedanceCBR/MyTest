//
//  ArticleForwardManager.m
//  Article
//
//  Created by SunJiangting on 15-1-23.
//
//

#import "ArticleForwardManager.h"
#import "TTNetworkManager.h"
#import "ExploreMomentDefine.h"
#import "NSDictionary+TTAdditions.h"

@interface ArticleForwardManager ()

@property (nonatomic, strong)TTHttpTask *fowardTask;
@end

@implementation ArticleForwardManager

static ArticleForwardManager *_sharedManager;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)forwardMoment:(ArticleMomentModel *)momentModel
             withText:(NSString *)text
    completionHandler:(void(^)(NSError *error))completionHandler {
    [self.fowardTask cancel];
    
    NSMutableDictionary *postParameter = [NSMutableDictionary dictionary];
    [postParameter setValue:text forKey:@"content"];
    [postParameter setValue:momentModel.ID forKey:@"dongtai_id"];
    
    self.fowardTask = [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting forwardMomentURLString] params:nil method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error)
        {
            if ([jsonObj isKindOfClass:[NSDictionary class]])
            {
                NSDictionary * momentItemData = [(NSDictionary *)jsonObj tt_dictionaryValueForKey:@"data"];
                
                if (momentItemData) {
                    ArticleMomentModel *momentItem = [[ArticleMomentModel alloc] initWithDictionary:momentItemData];
                    if (momentItem) {
                        NSDictionary * notificationUerInfo = @{@"item" : momentItem, @"data": momentItemData};
                        momentModel.forwardNum = @(momentModel.forwardNum.longLongValue + 1);
                        [[NSNotificationCenter defaultCenter] postNotificationName:kForwardMomentItemDoneNotification object:nil userInfo:notificationUerInfo];
                    }
                }
            }
        }
        
        if (completionHandler)
        {
            completionHandler(error);
        }
    }];
}

- (void)cancel {
    [self.fowardTask cancel];
}

@end
