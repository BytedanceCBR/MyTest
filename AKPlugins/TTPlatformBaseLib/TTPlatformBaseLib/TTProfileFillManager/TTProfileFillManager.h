//
//  TTProfileFillManager.h
//  Article
//
//  Created by tyh on 2017/6/2.
//
//

#import <Foundation/Foundation.h>

#import "TTAccountUserEntity.h"
#import "TTRequestModel.h"
#import "TTResponseModel.h"

typedef NS_ENUM(NSUInteger, TTProfileFillManagerImageStatus) {
    TTProfileFillManagerImageStatusUploading,
    TTProfileFillManagerImageStatusUploadSucceeded,
    TTProfileFillManagerImageStatusUploadFailed,
};


@interface  TTUserProfileEvaluationRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *log_action;
@property (strong, nonatomic) NSNumber *disable;
@end

@interface  TTUserProfileEvaluationResponseModel : TTResponseModel
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) NSNumber *beat_pct;
@property (strong, nonatomic) NSNumber *show;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSNumber *is_name_valid;
@property (strong, nonatomic) NSNumber *is_avatar_valid;
@property (strong, nonatomic) NSString<Optional> *apply_auth_url;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString<Optional> *save;
@property (strong, nonatomic) NSString<Optional> *tips;
@end

static NSString* const TTProfileFillNotify = @"TTProfileFillNotify";

typedef void(^CompleteAction)(id model,NSError *error);


@interface TTProfileFillManager : NSObject

+ (instancetype)manager;

@property (nonatomic,assign)BOOL isCommentFlag;
@property (nonatomic,assign)BOOL isShowProfileFill;
@property (nonatomic,strong)TTUserProfileEvaluationResponseModel *profileModel;

//加V认证
@property (nonatomic,assign)BOOL isShowAuth;

//头像上传状态
@property (nonatomic,assign)TTProfileFillManagerImageStatus imageStatus;
@property (nonatomic,assign)BOOL updateInfoPending;

- (void)isShowProfileFill:(CompleteAction)complete
               log_action:(BOOL)log_action
                  disable:(BOOL)disable;

//更新用户昵称
- (void)updateUserName:(NSString *)username
            completion:(void (^)(TTAccountUserEntity *aModel, NSError *error))completion;
//上传并更新用户头像
- (void)updateUserIcon:(UIImage *)icon
            completion:(void (^)(TTAccountUserEntity *aModel, NSError *error))completion;
//上传用户头像，不更新配置
- (void)uploadUserIcon:(UIImage *)icon
            completion:(void (^)(TTAccountImageEntity *imageEntity,NSError *error))completion;
//预设用户昵称，用于confirmUserIconAndName时候直接更新
- (void)presetUserName:(NSString *)userName;
//采用之前上传的头像更和预设的name来更新用户信息
- (void)confirmUserIconAndNameCompletion:(void(^)(TTAccountUserEntity *aModel, NSError *error))completion;



- (BOOL)isAccoutChanged;

- (void)clearProfileModel;


@end
