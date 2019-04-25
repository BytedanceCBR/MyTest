//
//  TTAppLogResponseModel.h
//  Article
//
//  Created by fengyadong on 16/12/14.
//
//

//https://wiki.bytedance.net/pages/viewpage.action?pageId=525581

#import <JSONModel/JSONModel.h>

@interface TTAppLogResponseModel : JSONModel


@property (nonatomic, copy)   NSString *magicTag;
@property (nonatomic, copy)   NSString *message;
@property (nonatomic, strong) NSNumber *serverTime;
@property (nonatomic, strong) NSDictionary<Optional> *blackList;
@end
