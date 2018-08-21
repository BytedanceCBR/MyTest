//
//  UILabel+Tapping
//  Article
//
//  Created by lizhuoli on 17/2/16.
//
//
//  TTTAttributeLabel不支持NSTextAttachment图片，如果只是为了URL点击回调可以直接使用此UILabel Category

#import <UIKit/UIKit.h>

@protocol TTLabelTappingDelegate <NSObject>

@optional
/** 点击对应的URL回调，两者只会触发其一 */
- (void)label:(UILabel *)label didSelectLinkWithURL:(NSURL *)URL;
/** 长按对应的URL回调，两者只会触发其一 */
- (void)label:(UILabel *)label didLongPressLinkWithURL:(NSURL *)URL;
@end

@interface UILabel (Tapping)

//注意，使用该UILabel+Tappding Category，必须用attributedText，对应的一些属性，比如UILabel.font也必须设置到attributedText中
//坑注意，TextKit计算attributedText的时候，如果设置了NSParagraphStyle的lineBreakMode属性为非NSLineBreakByWordWrapping或者NSLineBreakByCharWrapping，就会导致usedRectForTextContainer得到的高度错误（实践表现为只有一行的高度），此时会导致点击区域识别出错。因此使用时，避免UILabel的attributedText设置NSParagraphStyle不兼容的lineBreakMode属性。如果非要使用，会兼容并在计算时临时采用NSLineBreakByWordWrapping

/** 点击/长按 回调方法的代理 */
@property (nonatomic, weak) id<TTLabelTappingDelegate> labelTappingDelegate;
/** 用于显示高亮状态下的链接的Attributes，点击时候会添加此Attributes并删除Inactive的Attributes */
@property (nonatomic, strong) NSDictionary<NSString *,id> *labelActiveLinkAttributes;
/** 用于显示非高亮状态下的链接的Attributes，非点击时候会添加此Attributes并删除active的Attributes */
@property (nonatomic, strong) NSDictionary<NSString *,id> *labelInactiveLinkAttributes;
/** 是否允许外部的ScrollView的手势同时响应 */
@property (nonatomic, assign) BOOL needSimultaneouslyScrollGesture;

/** 指定range内的AttributedText为URL，需要预先设置完成Active/Inactive的LinkAttributes */
- (void)addLinkToLabelWithURL:(NSURL *)URL range:(NSRange)range;
/** 检测当前的Label本身的attributedText，并自动添加检测到的URL和对应的range到link中 */
- (void)detectAndAddLinkToLabel;
/** 删除所有的linkAttributes */
- (void)removeAllLinkAttributes;

@end
