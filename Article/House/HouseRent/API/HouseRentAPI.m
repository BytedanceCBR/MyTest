//
//  HouseRentAPI.m
//  Article
//
//  Created by leo on 2018/11/22.
//

#import "HouseRentAPI.h"
#import <TTNetworkManager.h>

@implementation HouseRentAPI
+ (TTHttpTask*)requestHouseRentRelated {
    NSString* url = @"https://i.haoduofangs.com/f100/api/related_rent";
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url
                                                              params:@{@"house_id": @"1111"}
                                                              method:@"GET"
                                                    needCommonParams:YES
                                                            callback:^(NSError *error, id obj) {
                                                                NSLog(@"%@", obj);
                                                            }];
}
@end
