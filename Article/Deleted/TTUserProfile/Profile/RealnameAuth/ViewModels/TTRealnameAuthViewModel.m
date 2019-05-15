//
//  TTRealnameAuthViewModel.m
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import "TTRealnameAuthViewModel.h"
#import "TTRealnameAuthViewController.h"
#import "TTRealnameAuthCardCameraViewController.h"
#import "TTRealnameAuthPersonCameraViewController.h"
#import "TTRealnameAuthManager.h"

@interface TTRealnameAuthViewModel ()

@property (nonatomic, weak) SSViewControllerBase<RealnameAuthViewDelegate, UIViewControllerErrorHandler> *rootVC;

@end

@implementation TTRealnameAuthViewModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        TTRealnameAuthModel *initModel = [TTRealnameAuthModel new];
        self.model = initModel;
    }
    return self;
}

- (void)setupModel:(TTRealnameAuthModel *)model withSender:(id)sender
{
    self.model.state = model.state;
    
    self.model.dismissFlag = model.dismissFlag;
    self.model.clearImageFlag = model.clearImageFlag;
    LOGD(@"current state: %ld", (long)self.model.state);
    switch (self.model.state) {
        case TTRealnameAuthStateInit: { // root vc init error
            [self.rootVC updateViewsWithModel:model];
        }
            break;
        case TTRealnameAuthStateNotAuth: {
            self.model.foregroundImage = nil;
            self.model.backgroundImage = nil;
            self.model.personImage = nil;
            self.model.name = nil;
            self.model.IDNum = nil;
            self.model.foregroundError = nil;
            self.model.backgroundError = nil;
            self.model.personError = nil;
            self.model.submitError = nil;
            if (self.rootVC) {
                [self.rootVC tt_endUpdataData:NO error:nil];
                [self.rootVC updateViewsWithModel:model];
            }
        }
            break;
        case TTRealnameAuthStateCardForegroundCamera: {
            if (self.model.clearImageFlag) {
                self.model.foregroundImage = nil;
                self.model.foregroundError = nil;
            }
        }
            break;
        case TTRealnameAuthStateCardForegroundInfo: {
            if (model.foregroundImage) {
                self.model.foregroundImage = model.foregroundImage;
                self.model.name = nil; // 清空数据
                self.model.IDNum = nil;
                WeakSelf;
                [[TTRealnameAuthManager sharedInstance] uploadImageWithImage:wself.model.foregroundImage type:TTRealnameAuthImageCardForeground callback:^(NSError *err, TTRealnameAuthUploadResponseModel *model) {
                    if (!err) {
                        wself.model.name = model.real_name;
                        wself.model.IDNum = model.identity_number;
                    } else {
                        wself.model.foregroundError = err;
                    }
                }];
            }
        }
            break;
        case TTRealnameAuthStateCardBackgroundCamera: {
            if (self.model.clearImageFlag) {
                self.model.backgroundImage = nil;
                self.model.backgroundError = nil;
            }
        }
            break;
        case TTRealnameAuthStateCardBackgroundInfo: {
            if (model.backgroundImage) {
                self.model.backgroundImage = model.backgroundImage;
                WeakSelf;
                [[TTRealnameAuthManager sharedInstance] uploadImageWithImage:wself.model.backgroundImage type:TTRealnameAuthImageCardBackground callback:^(NSError *err, TTRealnameAuthUploadResponseModel *model) {
                    if (!err) {
                        // Do nothing
                    } else {
                        wself.model.backgroundError = err;
                    }
                }];
            }
        }
            break;
        case TTRealnameAuthStateCardSubmit: { // 如果身份证反面上传失败，重试
            if (self.model.backgroundError && self.model.backgroundImage) {
                WeakSelf;
                [[TTRealnameAuthManager sharedInstance] uploadImageWithImage:wself.model.backgroundImage type:TTRealnameAuthImageCardBackground callback:^(NSError *err, TTRealnameAuthUploadResponseModel *model) {
                    if (!err) {
                        wself.model.backgroundError = nil;
                        // Do nothing
                    } else {
                        wself.model.backgroundError = err;
                    }
                    [sender updateViewsWithModel:wself.model];
                }];
            }
        }
            break;
        case TTRealnameAuthStateCardSubmitting: {
            self.model.state = TTRealnameAuthStatePersonAuth; // 由于提前已经上传图片到服务端OCR，直接跳过这步骤
        }
            break;
        case TTRealnameAuthStatePersonAuth:
            break;
        case TTRealnameAuthStatePersonCamera: {
            if (self.model.clearImageFlag) {
                self.model.personImage = nil;
                self.model.personError = nil;
            }
        }
            break;
        case TTRealnameAuthStatePersonSubmit: {
            if (model.personImage) {
                self.model.personImage = model.personImage;
            }
        }
            break;
        case TTRealnameAuthStatePersonSubmitting: {
            if (self.model.editInfoFlag) {
                WeakSelf;
                [[TTRealnameAuthManager sharedInstance] submitInfoWithName:wself.model.name IDNum:wself.model.IDNum callback:^(NSError *submitErr) {
                    if (!submitErr) {
                        self.model.editInfoFlag = NO; // 不需要再上传编辑信息
                        [[TTRealnameAuthManager sharedInstance] uploadImageWithImage:wself.model.personImage type:TTRealnameAuthImagePerson callback:^(NSError *err, TTRealnameAuthUploadResponseModel *model) {
                            if (!err) {
                                wself.model.state = TTRealnameAuthStateAuthSucess;
                                wself.model.finishFlag = YES;
                            } else {
                                wself.model.state = TTRealnameAuthStatePersonSubmit;
                                wself.model.personError = err;
                            }
                            [sender updateViewsWithModel:wself.model];
                        }];
                    } else {
                        wself.model.state = TTRealnameAuthStatePersonSubmit;
                        wself.model.submitError = submitErr;
                        [sender updateViewsWithModel:self.model];
                    }
                }];
            } else {
                WeakSelf;
                [[TTRealnameAuthManager sharedInstance] uploadImageWithImage:wself.model.personImage type:TTRealnameAuthImagePerson callback:^(NSError *err, TTRealnameAuthUploadResponseModel *model) {
                    if (!err) {
                        wself.model.state = TTRealnameAuthStateAuthSucess;
                        wself.model.finishFlag = YES;
                    } else {
                        wself.model.state = TTRealnameAuthStatePersonSubmit;
                        wself.model.personError = err;
                    }
                    [sender updateViewsWithModel:wself.model];
                }];
            }
        }
            break;
        case TTRealnameAuthStateAuthSucess: {
            self.model.finishFlag = YES;
        }
            break;
        case TTRealnameAuthStateAuthError: {
            self.model.finishFlag = YES;
            [self.rootVC tt_endUpdataData:NO error:nil];
            [self.rootVC setupViewsWithModel:self.model];
        }
            break;
        case TTRealnameAuthStateAuthed: {
            self.model.finishFlag = YES;
            [self.rootVC tt_endUpdataData:NO error:nil];
            [self.rootVC setupViewsWithModel:self.model];
        }
            break;
        default:
            break;
    }
}

- (void)loadInitialAuthStatus
{
    WeakSelf;
    [[TTRealnameAuthManager sharedInstance] fetchInfoStatusWithCallback:^(NSError *err, TTRealnameAuthStatusResponseModel *model) {
        if (!err && model) {
            wself.model.authStatus = model.status;
            if ([model.status isEqualToNumber:@(0)]) {
                wself.model.state = TTRealnameAuthStateAuthError;
            } else if ([model.status isEqualToNumber:@(1)]) {
                wself.model.state = TTRealnameAuthStateNotAuth;
            } else if ([model.status isEqualToNumber:@(2)]) {
                wself.model.state = TTRealnameAuthStateAuthed;
            }
        } else {
            wself.model.authStatusError = err;
            wself.model.state = TTRealnameAuthStateInit;
        }
        
        [self setupModel:wself.model withSender:self.rootVC];
    }];
}

- (void)setupRootVC:(SSViewControllerBase<RealnameAuthViewDelegate, UIViewControllerErrorHandler> *)rootVC
{
    if (!_rootVC) {
        _rootVC = rootVC;
    }
}

- (SSViewControllerBase<RealnameAuthViewDelegate> *)rootVC
{
    return _rootVC;
}

@end
