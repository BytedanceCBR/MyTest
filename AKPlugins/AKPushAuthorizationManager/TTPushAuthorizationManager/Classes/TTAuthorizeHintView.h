//
//  TTAuthorizeHintView.h
//  Article
//
//  Created by 邱鑫玥 on 16/6/17.
//
//

#import "SSThemed.h"

typedef NS_ENUM(NSUInteger, TTAuthorizeHintCompleteType) {
    TTAuthorizeHintCompleteTypeCancel,
    TTAuthorizeHintCompleteTypeDone,
};

typedef void(^TTAuthorizeHintComplete)(TTAuthorizeHintCompleteType type);

@interface TTAuthorizeHintView : SSThemedView

- (instancetype)initAuthorizeHintWithImageName:(NSString *)imageName
                                         title:(NSString *)title
                                       message:(NSString *)message
                               confirmBtnTitle:(NSString *)confirmBtnTitle
                                      animated:(BOOL)animated
                                     completed:(TTAuthorizeHintComplete)completed;

- (instancetype)initAuthorizeHintWithTitle:(NSString *)title
                                   message:(NSString *)message
                                     image:(id)imageObject /* imageURL or UIImage */
                           confirmBtnTitle:(NSString *)confirmBtnTitle
                                  animated:(BOOL)animated
                                 completed:(TTAuthorizeHintComplete)completed;

- (instancetype)initAuthorizeHintWithImageName:(NSString *)imageName
                                         title:(NSString *)title
                                       message:(NSString *)message
                               confirmBtnTitle:(NSString *)confirmBtnTitle
                                      animated:(BOOL)animated
                                      reversed:(BOOL)reversed
                                     completed:(TTAuthorizeHintComplete)completed;

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineSpacing:(CGFloat)lineSpace lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)alignment;

- (void)show;
- (void)hide;

@end
