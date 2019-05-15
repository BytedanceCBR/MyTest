//
//  TSVRecUserSinglePersonCollectionViewCellViewModel.h
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import <Foundation/Foundation.h>
#import "TSVRecUserSinglePersonModel.h"

@interface TSVRecUserSinglePersonCollectionViewCellViewModel : NSObject

@property (nonatomic, copy, readonly) NSString *avatarURL;
@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *userAuthInfo;
@property (nonatomic, copy, readonly) NSString *recommendReason;
@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *statsPlaceHolder;

@property (nonatomic) BOOL isFollowing;

- (instancetype)initWithModel:(TSVRecUserSinglePersonModel *)model;

@end
