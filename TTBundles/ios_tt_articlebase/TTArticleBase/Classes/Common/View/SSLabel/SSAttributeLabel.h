//
//  SSAttributeLabel.h
//  Article
//
//  Created by Zhang Leonardo on 13-6-17.
//
//
//  使用该类, 设置了attributeModels，系统的attributedText将无效
//  需要先设置text， 然后再设置attributeModels, 不然将被判定无效

#import <UIKit/UIKit.h>

//下划线风格
typedef enum SSAttributeLabelTextUnderLineStyle{
    SSAttributeLabelTextUnderLineStyleNotSet = -1,//private style，do not use
    SSAttributeLabelTextUnderLineStyleNone = 0,
    SSAttributeLabelTextUnderLineStyleSingle = 1,
    SSAttributeLabelTextUnderLineStyleDouble = 2,
    SSAttributeLabelTextUnderLineStyleItalic = 4,
}SSAttributeLabelTextUnderLineStyle;

@protocol SSAttributeLabelModelDelegate;

/*
 *  link text default color is "blueColur"
 *  link text default textUnderLineStyle is SSAttributeLabelTextUnderLineStyleSingle
 */
@interface SSAttributeLabelModel : NSObject
@property(nonatomic, retain)UIColor * textColor;
@property(nonatomic, assign)SSAttributeLabelTextUnderLineStyle textUnderLineStyle;
@property(nonatomic, retain)NSString * linkURLString;
@property(nonatomic, assign)NSRange attributeRange;
@end

@interface SSAttributeLabel : UILabel
/// add by sunjiangting .
+ (CGSize) sizeWithText:(NSString *) text
                   font:(UIFont *) font
      constrainedToSize:(CGSize) constrainedSize;

+ (CGSize) sizeWithText:(NSString *) text
                   font:(UIFont *) font
      constrainedToSize:(CGSize) constrainedSize
     lineSpacingMultiple:(CGFloat)lineSpacingMultiple;

@property(nonatomic, weak)id<SSAttributeLabelModelDelegate>delegate;
@property(nonatomic, assign)UIDataDetectorTypes ssDataDetectorTypes; //default is UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber , and now only support that
@property(nonatomic, retain)UIColor * detectedTextColor;
@property(nonatomic, assign)SSAttributeLabelTextUnderLineStyle detectedTextUnderLineStyle;// default is SSAttributeLabelTextUnderLineStyleSingle
@property(nonatomic, retain, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, retain)NSString * backgroundHighlightColorName; //点击没有model的文字及没有文字的地方， 背景会变色。默认为nil， 如果为nil， 没有效果
@property(nonatomic, assign)CGFloat lineSpacingMultiple;
@property(nonatomic, retain)NSString * selectTextForegroundColorName;//点击状态文字的背景色对应的色值name， 会通过SSUIString(selectTextBackgroundColorName)获取具体颜色值

- (id)initWithFrame:(CGRect)frame supportCopy:(BOOL)supportCopy;

- (void)refreshAttributeModels:(NSArray *)attributeModels;

@end

@protocol SSAttributeLabelModelDelegate <NSObject>

@optional

- (void)attributeLabel:(SSAttributeLabel *)label didClickLink:(NSString *)linkURLString;
- (void)attributeLabelClickedUntackArea:(SSAttributeLabel *)label;//点击到了非model地区

@end