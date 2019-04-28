//
//  TTRealnameAuthModel.h
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTRealnameAuthState) {
    TTRealnameAuthStateInit, // 初始进入状态
    TTRealnameAuthStateNotAuth, // 未认证
    TTRealnameAuthStateAuthed, // 已认证
    TTRealnameAuthStateCardForegroundCamera, // 身份证正面照拍摄中
    TTRealnameAuthStateCardForegroundInfo, // 身份证正面照信息
    TTRealnameAuthStateCardBackgroundCamera, // 身份证背面照拍摄中
    TTRealnameAuthStateCardBackgroundInfo, // 身份证背面照信息
    TTRealnameAuthStateCardSubmit, // 身份证识别提交
    TTRealnameAuthStateCardSubmitting, // 身份证识别提交中
    TTRealnameAuthStatePersonAuth, // 人像识别
    TTRealnameAuthStatePersonCamera, // 人像识别拍摄中
    TTRealnameAuthStatePersonSubmit, // 人像识别提交
    TTRealnameAuthStatePersonSubmitting, // 人像识别提交中
    TTRealnameAuthStateAuthSucess, // 认证成功
    TTRealnameAuthStateAuthError, // 认证失败
};

@interface TTRealnameAuthModel : NSObject

@property (nonatomic, assign) TTRealnameAuthState state;

@property (nonatomic, strong) UIImage *foregroundImage;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *personImage;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *IDNum;
@property (nonatomic, strong) NSNumber *authStatus;

@property (nonatomic, copy) NSError *authStatusError;
@property (nonatomic, copy) NSError *foregroundError;
@property (nonatomic, copy) NSError *backgroundError;
@property (nonatomic, copy) NSError *submitError;
@property (nonatomic, copy) NSError *personError;

@property (nonatomic, assign) BOOL dismissFlag;
@property (nonatomic, assign) BOOL clearImageFlag;
@property (nonatomic, assign) BOOL editInfoFlag;
@property (nonatomic, assign) BOOL finishFlag;

+ (instancetype)modelWithState:(TTRealnameAuthState)state;

@end
