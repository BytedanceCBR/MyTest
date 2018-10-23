//
//  TTTagItem.h
//  Article
//
//  Created by 王霖 on 4/19/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTTagButtonStyle) {
    TTTagDisplayButtonStyle,//只做展示
    TTTagSelectedButtonStyle,//可选择标记的button
    TTTagJumpedButtonStyle//点击后跳转的button
};

@interface TTTagItem : NSObject

NS_ASSUME_NONNULL_BEGIN
//style must be set firstly
@property (nonatomic, assign)           TTTagButtonStyle style;

//all style
@property (nonatomic, copy, readonly)   NSString *text;
//textColor
@property (nonatomic, strong, nullable) NSString *textColorThemedKey;
@property (nonatomic, strong, nullable) NSString *highlightedTextColorThemedKey;
//backgound color
@property (nonatomic, strong, nullable) NSString *bgColorThemedKey;
@property (nonatomic, strong, nullable) NSString *highlightedBgColorThemedKey;
//border color & width
@property (nonatomic, strong, nullable) NSString *borderColorThemedKey;
@property (nonatomic, strong, nullable) NSString *highlightedBorderColorThemedKey;
@property (nonatomic, assign)           CGFloat borderWidth;
//background image
@property (nonatomic, strong, nullable) UIImage *buttonImg;
@property (nonatomic, strong, nullable) UIImage *highlightedbuttonImg;
//if no font is specified, system font with fontSize is used
@property (nonatomic, strong, nullable) UIFont *font;
@property (nonatomic, assign)           CGFloat fontSize;
//coner radius
@property (nonatomic, assign)           CGFloat cornerRadius;
//like padding in css
@property (nonatomic, assign)           UIEdgeInsets padding;
//interval
@property (nonatomic, assign)           CGFloat textImageInterval;

//TTTagJumpedButtonStyle only
@property(nonatomic, copy)    void(^ _Nullable action)(void);

//TTTagSelectedButtonStyle only
@property(nonatomic, copy)              void(^ _Nullable stateChanged)(BOOL hasSelected);
@property (nonatomic, strong, nullable) NSString *selectedBgColorThemedKey;
@property (nonatomic, strong, nullable) NSString *selectedHighlightedBgColorThemedKey;
@property (nonatomic, strong, nullable) NSString *selectedTextColorKey;
@property (nonatomic, strong, nullable) NSString *selectedBorderColorThemedKey;
@property (nonatomic, assign)           BOOL isSelected;

- (instancetype _Nonnull)initWithText:(NSString * _Nonnull)text action:(void(^ _Nullable)(void))action;

NS_ASSUME_NONNULL_END

@end
