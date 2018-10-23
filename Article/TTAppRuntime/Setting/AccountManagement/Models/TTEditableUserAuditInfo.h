//
//  TTEditableUserAuditInfo.h
//  Article
//
//  Created by liuzuopeng on 8/25/16.
//
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, TTEditingUserItemType) {
    kTTEditingUserItemTypeNone = 0,
    kTTEditingUserItemTypeUsername,
    kTTEditingUserItemTypeAvatar,
    kTTEditingUserItemTypeBgImage,
    kTTEditingUserItemTypeDescription,
};

/**
 * 用或操作表示修改了多个
 */
typedef NS_ENUM(NSUInteger, TTUserInfoModifiedFlag) {
    kTTUserInfoModifiedFlagNone        = 1 << 0,
    kTTUserInfoModifiedFlagUsername    = 1 << 1,
    kTTUserInfoModifiedFlagAvatar      = 1 << 2,
    kTTUserInfoModifiedFlagBgImage     = 1 << 3,
    kTTUserInfoModifiedFlagDescription = 1 << 4,
};

/**
 *  本地可编辑的用户审核信息
 */
@interface TTEditableUserAuditInfo : TTAccountUserAuditEntity
@property (nonatomic, assign) BOOL isAuditing;
@property (nonatomic, assign) BOOL editEnabled;
@property (nonatomic, assign) TTEditingUserItemType  editingItem; // default is kTTEditingUserItemTypeNone
@property (nonatomic, assign) TTUserInfoModifiedFlag modifiedFlags; // default is kTTUserInfoModifiedFlagNone

@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic,   copy) NSString *avatarImageURI;
@property (nonatomic,   copy) NSString *bgImageURI;

- (BOOL)containUserAuditInfo:(TTAccountUserAuditSet *)info;

- (NSDictionary *)toUploadedParameters;

- (NSDictionary *)toModifiedParamters;
@end

