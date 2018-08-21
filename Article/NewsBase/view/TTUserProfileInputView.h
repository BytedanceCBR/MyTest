//
//  TTUserProfileInputView.h
//  Article
//
//  Created by 王双华 on 15/10/10.
//
//

#import "SSViewBase.h"
#import "SSThemed.h"

typedef NS_ENUM(NSInteger, TTUserProfileInputViewType)
{
    TTUserProfileInputViewTypeName,     //用户名
    TTUserProfileInputViewTypeSign,     //签名
    TTUserProfileInputViewTypePGCSign,  //头条号签名
};


@class TTUserProfileInputView;
@protocol TTUserProfileInputViewDelegate <NSObject>

@optional
- (void)cancelButtonClicked:(TTUserProfileInputView *)view;
- (void)confirmButtonClicked:(TTUserProfileInputView *)view;
@end

@interface TTUserProfileInputView : SSViewBase

@property(nonatomic)TTUserProfileInputViewType type;
@property(nonatomic, strong)SSThemedTextView *textView;
@property(nonatomic, strong)UIView * backgroundView;
@property(nonatomic, strong)UIView * editView;
@property (nonatomic, strong) SSThemedLabel * tipLabel;
@property (nonatomic, assign) NSInteger count;

@property(nonatomic, weak)id<TTUserProfileInputViewDelegate> delegate;

- (void)showInView:(UIView *) view animated:(BOOL) animated;
- (void)dismissAnimated:(BOOL)animated;


@end
