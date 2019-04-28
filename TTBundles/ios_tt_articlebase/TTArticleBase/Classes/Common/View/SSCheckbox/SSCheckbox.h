//
//  SSCheckbox.h
//  Article
//
//  Created by SunJiangting on 15-1-14.
//
//

#import <UIKit/UIKit.h>

@class SSThemedLabel, SSThemedImageView;
@interface SSCheckbox : UIControl

- (instancetype)initWithTitle:(NSString *)title;
@property (nonatomic, copy) NSString  *title;
@property (nonatomic, strong) UIImage   *image;
@property (nonatomic, strong) UIImage   *checkedImage;

@property (nonatomic, readonly) SSThemedImageView *imageView;
@property (nonatomic, readonly) SSThemedLabel *titleLabel;
/// default 10 , imageView和titleLabel之间的间距
@property (nonatomic) CGFloat   horizontalSpacing;
@property (nonatomic) BOOL  checked;

@end

@interface SSCheckbox (SSTheme)

@property (nonatomic, copy) NSString    *imageName;
@property (nonatomic, copy) NSString    *checkedImageName;

@end

