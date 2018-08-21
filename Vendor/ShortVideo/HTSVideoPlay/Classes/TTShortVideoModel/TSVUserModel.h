
//
//  TSVUserModel.h
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/9/25.
//

#import <JSONModel/JSONModel.h>

@interface TSVUserModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *avatarURL;
@property (nonatomic, copy) NSString<Optional> *name;
@property (nonatomic, copy) NSString<Optional> *schema;
@property (nonatomic, copy) NSString<Optional> *userAuthInfo;
@property (nonatomic, copy) NSString<Optional> *userID;
@property (nonatomic, copy) NSString<Optional> *verifiedContent;
@property (nonatomic, copy) NSString<Optional> *desc;
@property (nonatomic, copy) NSString<Optional> *userDecoration;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isFriend;

@property (nonatomic, assign) NSInteger followingsCount;
@property (nonatomic, assign) NSInteger followersCount;

@end
