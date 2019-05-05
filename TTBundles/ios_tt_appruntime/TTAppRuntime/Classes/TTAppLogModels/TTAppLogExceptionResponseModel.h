//
//  TTAppLogExceptionResponseModel.h
//  Article
//
//  Created by chenjiesheng on 16/12/15.
//
//

#import <JSONModel/JSONModel.h>

@interface TTAppLogExceptionResponseModel : JSONModel

@property (nonatomic, copy) NSString *magicTag;
@property (nonatomic, copy) NSString *message;
@end
