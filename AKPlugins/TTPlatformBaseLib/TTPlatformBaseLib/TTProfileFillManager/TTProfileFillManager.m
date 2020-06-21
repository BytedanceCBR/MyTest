//
//  TTProfileFillManager.m
//  Article
//
//  Created by tyh on 2017/6/2.
//
//

#import "TTProfileFillManager.h"
#import "TTNetworkManager.h"
#import "TTIndicatorView.h"
#import "TTAccountBusiness.h"
#import <TTServiceKit/TTModuleBridge.h>
#import "TTURLDomainHelper.h"


@implementation TTUserProfileEvaluationRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
        self._uri = @"/user/profile/evaluation";
        self._response = @"TTUserProfileEvaluationResponseModel";
    }
    
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_log_action forKey:@"log_action"];
    [params setValue:_disable forKey:@"disable"];
    
    return params;
}

@end


@implementation TTUserProfileEvaluationResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    
    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.score = nil;
    self.beat_pct = nil;
    self.show = nil;
    self.name = nil;
    self.avatar_url = nil;
    self.is_name_valid = nil;
    self.is_avatar_valid = nil;
    self.apply_auth_url = nil;
    self.title = nil;
    self.tips = nil;
    self.save = nil;
}
@end

@interface TTProfileFillManager()

@property (nonatomic, copy)NSString *avartarUri;
@property (nonatomic, strong)UIImage *avartarImage;
@property (nonatomic, copy)NSString *userName;
@property (nonatomic, strong)void(^pendingCompletion)(TTAccountUserEntity *aModel, NSError *error);

@end

@implementation TTProfileFillManager

+ (instancetype)manager {
    
    static TTProfileFillManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)load {
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTProfileFillManager.isCommentFlag" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        return @([TTProfileFillManager manager].isCommentFlag);
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTProfileFillManager.isShowProfileFill" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        return @([TTProfileFillManager manager].isShowProfileFill);
    }];
}

- (void)isShowProfileFill:(CompleteAction )complete log_action:(BOOL)log_action disable:(BOOL)disable
{
    if ([TTDeviceHelper isPadDevice]) {                    // iPad
        return;
    }
    
    if (![TTAccountManager isLogin]) {
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *date = [NSDate date];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    
    NSMutableDictionary *profileFillDic =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"ProfileFillDic"] mutableCopy];
    
    //标识当天已经请求过了
    if (profileFillDic && profileFillDic[dateStr] && !disable && log_action) {
        return;
    }
    
    if (!profileFillDic) {
        profileFillDic = [NSMutableDictionary dictionary];
    }
    [profileFillDic setObject:@"yes" forKey:dateStr];
    
    [[NSUserDefaults standardUserDefaults] setObject:profileFillDic forKey:@"ProfileFillDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    TTUserProfileEvaluationRequestModel *requestModel =  [[TTUserProfileEvaluationRequestModel alloc] init];
    
    if (log_action) {
        requestModel.log_action = @1;
    }else{
        requestModel.log_action = @0;
    }
    if (disable) {
        requestModel.disable = @1;
        requestModel.log_action = @0;
    }else{
        requestModel.disable = @0;
    }
    
    
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        //重新加载数据
        if (error) {
            if (complete) {
                complete(nil,error);
            }
            return ;
        }
        TTUserProfileEvaluationResponseModel *model = (TTUserProfileEvaluationResponseModel *)responseModel;
        
        if (model) {
            [profileFillDic setValue:model.toDictionary forKey:@"TTUserProfileEvaluationResponseModel"];
            [[NSUserDefaults standardUserDefaults] setObject:profileFillDic forKey:@"ProfileFillDic"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:TTProfileFillNotify object:nil];
        
        if (complete) {
            complete(model,nil);
        }
    }];
}

- (void)updateUserName:(NSString *)username
            completion:(void (^)(TTAccountUserEntity *aModel, NSError *error))completion
{
    //这段逻辑如果username为空仍然上传
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:username forKey:TTAccountUserNameKey];
    [self updateUserInfo:params completion:completion];

}

- (void)updateUserIcon:(UIImage *)icon
            completion:(void (^)(TTAccountUserEntity *aModel, NSError *error))completion
{
    [TTAccount startUploadImage:icon progress:nil completion:^(TTAccountImageEntity * _Nullable imageEntity, NSError * _Nullable error) {
        if (error || !imageEntity.web_uri) {
            
            if (completion) completion(nil, error);
            
        } else {
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:imageEntity.web_uri forKey:TTAccountUserAvatarKey];
            
            [self updateUserInfo:params completion:completion];
        }
    }];
}

- (void)uploadUserIcon:(UIImage *)icon
            completion:(void (^)(TTAccountImageEntity *, NSError *))completion
{
    self.avartarImage = icon;
    self.imageStatus = TTProfileFillManagerImageStatusUploading;
    [TTAccount startUploadImage:icon progress:nil completion:^(TTAccountImageEntity * _Nullable imageEntity, NSError * _Nullable error) {
        if (error || !imageEntity.web_uri) {
            self.imageStatus = TTProfileFillManagerImageStatusUploadFailed;
            if (completion) {
                completion(imageEntity,error);
            }
            if (self.updateInfoPending == YES) {
                //因为图片上传失败导致的更新信息失败，需要给出明确的提示。
                if (self.pendingCompletion) {
                    self.pendingCompletion(nil, error);
                }
            }
        } else {
            //上传成功
            if (self.updateInfoPending == YES) {
                //已经触发过更新操作，只是限于图片的原因在等待，应该利用上传好的图片继续之前的updateInfo操作。
                self.imageStatus = TTProfileFillManagerImageStatusUploadSucceeded;
                self.avartarUri = imageEntity.web_uri;
                if (completion) {
                    completion(imageEntity,nil);
                }
                [self confirmUserIconAndNameCompletion:self.pendingCompletion];

            } else {
                //正常的上传完图片，只需要记录下图片url即可
                self.imageStatus = TTProfileFillManagerImageStatusUploadSucceeded;
                self.avartarUri = imageEntity.web_uri;
                if (completion) {
                    completion(imageEntity,nil);
                }
            }
        }
    }];
    
}

- (void)presetUserName:(NSString *)userName
{
    self.userName = userName;
}

- (void)confirmUserIconAndNameCompletion:(void(^)(TTAccountUserEntity *aModel, NSError *error))completion
{
    if (!isEmptyString(self.userName) && self.avartarImage) {
        //都要更新
        if (self.imageStatus == TTProfileFillManagerImageStatusUploadSucceeded) {
            self.updateInfoPending = NO;
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:self.userName forKey:TTAccountUserNameKey];
            [params setValue:self.avartarUri forKey:TTAccountUserAvatarKey];
            [self updateUserInfo:params completion:completion];
        } else if (self.imageStatus == TTProfileFillManagerImageStatusUploading) {
            //应该等待uploading成功后上传
            self.updateInfoPending = YES;
            self.pendingCompletion = completion;
        } else if (self.imageStatus == TTProfileFillManagerImageStatusUploadFailed) {
            //试图上传过图片，但失败了。
            //调用上传图片的方法，
            self.updateInfoPending = YES;
            self.pendingCompletion = completion;
            [self uploadUserIcon:self.avartarImage completion:nil];
        }
    } else if (isEmptyString(self.userName) && self.avartarImage) {
        //昵称为空，只修改头像
        if (self.imageStatus == TTProfileFillManagerImageStatusUploadSucceeded) {
            self.updateInfoPending = NO;
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:self.avartarUri forKey:TTAccountUserAvatarKey];
            [self updateUserInfo:params completion:completion];
        } else if (self.imageStatus == TTProfileFillManagerImageStatusUploading) {
            //应该等待uploading成功后上传
            self.updateInfoPending = YES;
            self.pendingCompletion = completion;
        } else if (self.imageStatus == TTProfileFillManagerImageStatusUploadFailed) {
            //试图上传过图片，但失败了。
            //调用上传图片的方法，
            self.updateInfoPending = YES;
            self.pendingCompletion = completion;
            [self uploadUserIcon:self.avartarImage completion:nil];
        }
    } else if (!isEmptyString(self.userName) && !self.avartarImage) {
        //不该头像，只改昵称
        self.updateInfoPending = NO;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.userName forKey:TTAccountUserNameKey];
        [self updateUserInfo:params completion:completion];
    } else {
        //啥也不改
        if (completion) {
            completion(nil,nil);
        }
    }
}

- (void)updateUserInfo:(NSDictionary *)info
            completion:(void (^)(TTAccountUserEntity *aModel, NSError *error))completion
{
    [TTAccount updateUserProfileWithDict:info completion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
        if (!error) {
            // 同步本地标识
            [self synchronizeLocalFlag:[TTAccountManager userName] orIcon:[TTAccountManager avatarURLString]];
            
            if (completion) completion(userEntity, error);
            
        } else {
            if (completion) completion(nil, error);
        }
    }];
}

- (void)synchronizeLocalFlag:(NSString *)name orIcon:(NSString *)icon
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *date = [NSDate date];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    
    NSMutableDictionary *profileFillDic =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"ProfileFillDic"] mutableCopy];
    
    if (!profileFillDic) {
        profileFillDic = [NSMutableDictionary dictionary];
    }
    [profileFillDic setValue:@"yes" forKey:dateStr];
    
    NSMutableDictionary *dic = [[profileFillDic valueForKey:@"TTUserProfileEvaluationResponseModel"] mutableCopy];
    
    if (dic) {
        if (name) {
            [dic setValue:name forKey:@"name"];
        }
        if (icon) {
            [dic setValue:icon forKey:@"avatar_url"];
        }
        [profileFillDic setValue:dic forKey:@"TTUserProfileEvaluationResponseModel"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:profileFillDic forKey:@"ProfileFillDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (BOOL)isShowProfileFill
{
    if ([self isAccoutChanged]) {
        return NO;
    }
    if (self.profileModel) {
        if ([self.profileModel.is_avatar_valid boolValue] && [self.profileModel.is_name_valid boolValue]) {
            return NO;
        }
        if (![self.profileModel.show boolValue]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (TTUserProfileEvaluationResponseModel *)profileModel
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]valueForKey:@"ProfileFillDic"];
    
    TTUserProfileEvaluationResponseModel *model = nil;
    if (dic) {
        model = [[TTUserProfileEvaluationResponseModel alloc] initWithDictionary:dic[@"TTUserProfileEvaluationResponseModel"] error:nil];
    }
    return model;
}

- (BOOL)isAccoutChanged
{
    if (!self.profileModel) {
        return YES;
    }
    if (![self.profileModel.is_avatar_valid boolValue] ) {
        NSString *avatarPath = [[self.profileModel.avatar_url stringByDeletingPathExtension] lastPathComponent];
        NSString *accountAvatarPath = [[[TTAccountManager avatarURLString] stringByDeletingPathExtension] lastPathComponent];
        if (![avatarPath isEqualToString:accountAvatarPath]) {
            return YES;
        }
    }
    if (![self.profileModel.is_name_valid boolValue] && ![self.profileModel.name isEqualToString:[TTAccountManager userName]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isShowAuth
{
    if (self.profileModel) {
        if ([self.profileModel.is_avatar_valid boolValue] && [self.profileModel.is_name_valid boolValue] && [self.profileModel.show boolValue]) {
            return YES;
        }
    }
    return NO;
}

- (void)clearProfileModel
{
    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults]valueForKey:@"ProfileFillDic"] mutableCopy];
    if (dic) {
        [dic setValue:nil forKey:@"TTUserProfileEvaluationResponseModel"];
    }
    [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"ProfileFillDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
