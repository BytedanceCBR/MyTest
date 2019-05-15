//
//  TTNPopupView.h
//  Article
//
//  Created by Zuopeng Liu on 7/23/16.
//
//

#import <TTThemed/SSThemed.h>



/**
 * clickedIndex = -1, indicates blank area and closeButton
 */
typedef void (^TTNPopupViewDidDismissBlock)(NSInteger clickedIndex);
typedef void (^TTNPopupViewDidShowBlock)();

@interface TTNPopupView : SSThemedView

@property (nonatomic, assign) BOOL touchDismissEnabled;       // default is YES
@property (nonatomic, assign) BOOL imageLoadIndicatorEnabled; // default is YES

@property (nonatomic,   copy) NSString *titleColorKey;
@property (nonatomic, assign) CGFloat   titleFontSize;

@property (nonatomic,   copy) NSString *contentColorKey;
@property (nonatomic, assign) CGFloat   contentFontSize;

@property (nonatomic,   copy) NSString *buttonTextColorKey;
@property (nonatomic, assign) CGFloat   buttonTextFontSize;

@property (nonatomic, assign) CGFloat spacingToMarginTop; /* topMost control to margin top */
@property (nonatomic, assign) CGFloat spacingToMarginBottom; /* bottomMost control to margin bottom */
@property (nonatomic, assign) CGFloat spacingOfText; /* spacing between title and content */
@property (nonatomic, assign) CGFloat widthOfButton; /* button width */

#pragma mark - blocks

@property (nonatomic, copy) TTNPopupViewDidDismissBlock didDismissHandler; // callback did dismiss


- (instancetype)initWithFrame:(CGRect)frame
                     imageURL:(NSURL *)url
                        title:(NSString *)title
                      content:(NSString *)content
                  description:(NSString *)description
           confirmButtonTitle:(NSString *)confirmButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (instancetype)initWithFrame:(CGRect)frame
                        image:(UIImage *)image
                        title:(NSString *)title
                      content:(NSString *)content
                  description:(NSString *)description
           confirmButtonTitle:(NSString *)confirmButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void)showWithCompletion:(TTNPopupViewDidShowBlock)completion;

- (void)showInView:(UIView *)view
        completion:(TTNPopupViewDidShowBlock)completion;

- (void)dismiss; // dismiss manually

- (void)dismissWithAnimated:(BOOL)animated;

@end
