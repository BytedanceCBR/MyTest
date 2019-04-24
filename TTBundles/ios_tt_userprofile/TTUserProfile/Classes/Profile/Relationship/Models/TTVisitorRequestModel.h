//
//  TTVisitorRequestModel.h
//  Article
//
//  Created by it-test on 8/22/16.
//
//

#import <TTNetworkManager/TTNetworkManager.h>
#import "TTRequestModel.h"



@interface TTVisitorRequestModel : TTRequestModel
@property (nonatomic, strong) NSNumber *cursor; // 起始游标
@property (nonatomic, strong) NSNumber *count;  // 请求的访客数量
@property (nonatomic,   copy) NSString *user_id;
@end
