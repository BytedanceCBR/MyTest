//
//  RFTextView.h
//  FaceKeyboard

//  Company：     SunEee
//  Blog:        devcai.com
//  Communicate: 2581502433@qq.com

//  Created by ruofei on 16/3/28.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFTextView;
@protocol RFTextViewDelegate <UITextViewDelegate>

- (void)textViewDeleteBackward:(RFTextView *)textView;

@end

@interface RFTextView : UITextView

@property(nonatomic ,weak) id<RFTextViewDelegate> delegate;

@property (nonatomic, copy) NSString * placeHolder;

@property (nonatomic, strong) UIColor * placeHolderTextColor;

///...
@property (nonatomic, assign) UIOffset placeHolderTextOffset;
///...
// 处理消息为多行文本时，发送后立即会显示placeholderText，导致placeholderText有一个被拉伸的动画的问题。
@property (nonatomic, assign) BOOL shouldNotDrawPlaceholder;

- (NSUInteger)numberOfLinesOfText;

@end
