//
//  TTMomentDetailMiddleware.h
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import <Foundation/Foundation.h>
#import "TTRedux.h"


@interface TTMomentDetailMiddleware : NSObject <Middleware>

@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *element_from;
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, strong) NSDictionary *logPb;
@property (nonatomic, copy) NSString *ansid;
@property (nonatomic, copy) NSString *qid;
@property (nonatomic, strong) NSDictionary *extraDic;

@end
