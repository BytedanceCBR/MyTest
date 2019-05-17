//
//  SSCommentInputViewBase.h
//  Article
//
//  Created by Zhang Leonardo on 13-3-31.
//
//

#import <UIKit/UIKit.h>
#import "SSTitleBarView.h"
#import "SSViewBase.h"
#import "SSNavigationBar.h"
#import "UITextView+TTAdditions.h"

typedef enum SSCommentInputViewType{
    SSCommentInputViewTypeAllPlatform,      //转发/评论到所有SNS平台, default
    SSCommentInputViewTypeSinaWeibo,         //转发/评论到单个SNS平台，新浪微博
    SSCommentInputViewTypeQQZone,
    SSCommentInputViewTypeQQWeibo,
    SSCommentInputViewTypeRenren,
    SSCommentInputViewTypeKaixin
}SSCommentInputViewType;

@interface SSCommentInputViewBase : SSViewBase

@property(nonatomic, retain)SSTitleBarView *titleBarView;
@property (nonatomic, retain) SSNavigationBar * navigationBar;
@property(nonatomic, retain)UIView * platformButtonsView;
@property(nonatomic, retain)UILabel * countLabel;
@property(nonatomic, retain)UITextView *inputTextView;
@property(nonatomic, retain)UIImageView * bgImgView;
@property(nonatomic, retain)UILabel * tipLabel;
@property(nonatomic, retain)UIView * containerView;
@property(nonatomic, assign)SSCommentInputViewType inputViewType;
@property (nonatomic, retain) UIButton      * leftButton;
@property (nonatomic, retain) UIButton      * rightButton;

@property (nonatomic, assign) NSInteger designatedMaxWordsCount;

#pragma mark -- Protected Method

+ (Class)userAccountClassForCommentInputViewType:(SSCommentInputViewType)type;

- (void)setInputTypeByPlatformKey:(NSString *)key;
- (void)backButtonClicked;
- (void)sendButtonClicked;
- (void)refreshCountLabel;
/*
 *  返回YES，可以发送
 */
- (BOOL)inputContentLegal;
- (void)showRightImgIndicatorWithMsg:(NSString *)msg;
- (void)showWrongImgIndicatorWithMsg:(NSString *)msg;
- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName;

@end
