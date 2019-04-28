//
//  SSFeedbackPostViewBase.h
//  Article
//
//  Created by Zhang Leonardo on 13-5-9.
//
//

#import "SSViewBase.h"
#import "SSThemed.h"

@interface SSFeedbackPostViewBase : SSViewBase<UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, retain)SSThemedTextView * inputTextView;
@property(nonatomic, retain)UIImageView * bgImgView;

@property(nonatomic, retain)UIView * containerView;
@property(nonatomic, retain)UIButton * imageButton;
@property(nonatomic, retain)UIView * contactView;
@property(nonatomic, retain)SSThemedTextField* contactField;
@property(nonatomic, retain)UIImageView * contactImageView;

- (void)setInputTextViewText:(NSString *)text;
- (void)setImageButtonImg:(UIImage *)img;
- (void)removeProgressView;

#pragma mark -- Protected Method
- (BOOL) hasPickedImg;
- (void)submitImgCancel;
- (void)setSubmitProgress:(CGFloat)progress;
- (void)pickedImage:(UIImage *)image withReferenceURL:(NSURL *)url;
- (void)deletePickedImg;
/*
 *  返回YES，可以发送
 */
- (BOOL)inputContentLegal;

/*
 * 返回nil，不发送
 */
- (NSString *)availableContact;

- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName;
- (void)showIndicatorMsg:(NSString *)msg autoHidden:(BOOL)autoHide;
- (void)hideIndicator:(BOOL)animated;

@end
