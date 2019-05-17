//
//  TTAdDetailActionModel.m
//  Article
//
//  Created by matrixzk on 04/09/2017.
//
//

#import "TTAdDetailActionModel.h"

@implementation TTAdDetailActionModel

- (instancetype)initWithAdId:(NSString *)ad_id logExtra:(NSString *)log_extra webUrl:(NSString *)web_url openUrl:(NSString *)open_url webTitle:(NSString *)web_title
{
    return [self initWithAdId:ad_id logExtra:log_extra webUrl:web_url openUrl:open_url webTitle:web_title extraDict:nil];
}

- (instancetype)initWithAdId:(NSString *)ad_id logExtra:(NSString *)log_extra webUrl:(NSString *)web_url openUrl:(NSString *)open_url webTitle:(NSString *)web_title extraDict:(NSDictionary *)extraDict
{
    self = [super init];
    if (self) {
        self.ad_id = ad_id;
        self.log_extra = log_extra;
        self.web_url = web_url;
        self.open_url = open_url;
        self.web_title = web_title;
        self.extraDict = extraDict;
    }
    return self;
}

@end
