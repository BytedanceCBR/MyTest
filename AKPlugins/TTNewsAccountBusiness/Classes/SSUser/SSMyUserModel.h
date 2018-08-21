//
//  SSMyUserModel.h
//  Article
//
//  Created by Dianwei on 14-5-21.
//
//

#import "SSUserBaseModel.h"



/**
 * @Wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=52040298
 *        https://wiki.bytedance.com/pages/viewpage.action?pageId=53809581
 * 自己的user model
 */
@class TTAccountUserEntity;
@interface SSMyUserModel : SSUserBaseModel
@property (nonatomic, strong) NSMutableArray *accounts;
@property (nonatomic,   copy) NSString *phoneNumberString;
@property (nonatomic,   copy)   NSString *email;

- (instancetype)initWithAccountUser:(TTAccountUserEntity *)userEntity;

- (void)clear;
@end

