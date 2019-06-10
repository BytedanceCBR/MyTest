//
//  FHEditableUserInfo.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHEditableUserInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userDescription;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, assign) BOOL editEnabled;
@property (nonatomic, assign) BOOL isAuditing;

@end

NS_ASSUME_NONNULL_END
