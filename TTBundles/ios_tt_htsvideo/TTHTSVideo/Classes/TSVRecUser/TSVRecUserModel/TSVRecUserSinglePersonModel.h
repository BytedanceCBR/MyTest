//
//  TSVRecUserSinglePersonModel.h
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import <JSONModel/JSONModel.h>
#import "TSVUserModel.h"

@interface TSVRecUserSinglePersonModel : JSONModel

@property (nonatomic, strong) TSVUserModel<Optional> *user;
@property (nonatomic, copy) NSString<Optional> *statsPlaceHolder;
@property (nonatomic, copy) NSString<Optional> *recommendReason;
@property (nonatomic, copy) NSString<Optional> *recommendType;

@end
