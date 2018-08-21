//
//  TTAdDetailActionModel.h
//  Article
//
//  Created by matrixzk on 04/09/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"


@interface TTAdDetailActionModel : NSObject <TTAdDetailAction, TTAd>

@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *log_extra;

@property (nonatomic, copy) NSString *web_url;
@property (nonatomic, copy) NSString *open_url;
@property (nonatomic, copy) NSString *web_title;

@property (nonatomic, strong)NSDictionary *extraDict;

- (instancetype)initWithAdId:(NSString *)ad_id logExtra:(NSString *)log_extra webUrl:(NSString *)web_url openUrl:(NSString *)open_url webTitle:(NSString *)web_title;

- (instancetype)initWithAdId:(NSString *)ad_id logExtra:(NSString *)log_extra webUrl:(NSString *)web_url openUrl:(NSString *)open_url webTitle:(NSString *)web_title extraDict:(NSDictionary *)extraDict;

@end
