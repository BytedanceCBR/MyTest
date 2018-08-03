//
//  SSUserFriendModel.h
//  Article
//
//  Created by Dianwei on 14-7-20.
//
//

#import "SSUserBaseModel.h"

@interface SSUserFriendModel : SSUserBaseModel<NSCoding>
@property (nonatomic, assign) BOOL isNew; // 标记是否新加入
@property (nonatomic,   copy) NSString *displayInfo;
@property (nonatomic,   copy) NSString *verifiedAgency;
@property (nonatomic,   copy) NSString *verifiedContent;
@end
