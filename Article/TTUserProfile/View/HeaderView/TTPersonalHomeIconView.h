//
//  TTPersonalHomeIconView.h
//  Article
//
//  Created by wangdi on 2017/5/3.
//
//

#import "SSThemed.h"
#import "TTVerifyIconImageView.h"

@interface TTPersonalHomeIconView : SSThemedView

@property (nonatomic, strong) TTVerifyIconImageView *avatarVerifyView;
@property (nonatomic, strong) SSThemedImageView *avatarImageView;
@property (nonatomic, strong) SSThemedView *coverView;
@property (nonatomic, copy) NSString *placeHolder;
- (void)setImageWithURL:(NSString *)url;
- (void)showPersonalVerifyViewWithVerifyInfo:(NSString *)verifyInfo size:(CGSize)size;
- (void)hideVerifyView;
- (void)setDecoratorWithURL:(NSString *)url userID:(NSString *)uid;
@end
