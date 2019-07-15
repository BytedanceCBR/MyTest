//
//  UITextView+TTUGCTapping.h
//  TTUGCFoundation
//
//  Created by SongChai on 2018/6/12.
//

#import <UIKit/UIKit.h>

typedef void (^TTTextViewTapBlock)(NSRange range);

@protocol TTTextViewTappingDelegate <NSObject>

@optional
/** 点击对应的URL回调，两者只会触发其一 */
- (void)textView:(UITextView *)textView didSelectLinkWithURL:(NSURL *)URL;

@end

@interface UITextView (TTUGCTapping)

/** 点击/长按 回调方法的代理 */
@property (nonatomic, weak) id<TTTextViewTappingDelegate> textViewTappingDelegate;
/** 用于显示高亮状态下的链接的Attributes，点击时候会添加此Attributes并删除Inactive的Attributes */
@property (nonatomic, strong) NSDictionary<NSString *,id> *textViewActiveLinkAttributes;
/** 用于显示非高亮状态下的链接的Attributes，非点击时候会添加此Attributes并删除active的Attributes */
@property (nonatomic, strong) NSDictionary<NSString *,id> *textViewInactiveLinkAttributes;
/** 是否允许外部的ScrollView的手势同时响应 */
@property (nonatomic, assign) BOOL needSimultaneouslyScrollGesture;

/** 指定range内的AttributedText为URL，需要预先设置完成Active/Inactive的LinkAttributes */
- (void)addLink:(NSURL *)URL range:(NSRange)range tapBlock:(TTTextViewTapBlock)tapBlock;
/** 检测当前的TextView本身的attributedText，并自动添加检测到的URL和对应的range到link中 */
- (void)detectAndAddLink;
/** 删除所有的linkAttributes */
- (void)removeAllLinkAttributes;

@end

