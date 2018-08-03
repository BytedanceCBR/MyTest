//
//  ToolbarView.h
//  FaceKeyboard

//  Company：     SunEee
//  Blog:        devcai.com
//  Communicate: 2581502433@qq.com

//  Created by ruofei on 16/3/28.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFTextView.h"

#import "TTAlphaThemedButton.h"

#import "ChatToolBarItem.h"

typedef NS_ENUM(NSInteger, ButKind)
{
//    kButKindVoice = kBarItemVoice,
//    kButKindSwitchBar = kBarItemSwitchBar,
    ///...
    kButKindImage = kBarItemImage,
    kButKindSend = kBarItemSend,
//    kButKindVideo = kBarItemVideo
};

@class ChatToolBar;
@class ChatToolBarItem;

@protocol ChatToolBarDelegate <NSObject>

@optional

///...
- (void)chatToolBar:(ChatToolBar *)toolBar imageBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(ChatToolBar *)toolBar videoBtnPressed:(BOOL)select keyBoardState:(BOOL)change;

- (void)chatToolBar:(ChatToolBar *)toolBar voiceBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(ChatToolBar *)toolBar faceBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(ChatToolBar *)toolBar moreBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBarSwitchToolBarBtnPressed:(ChatToolBar *)toolBar keyBoardState:(BOOL)change;

//- (void)chatToolBarDidStartRecording:(ChatToolBar *)toolBar;
//- (void)chatToolBarDidCancelRecording:(ChatToolBar *)toolBar;
//- (void)chatToolBarDidFinishRecoding:(ChatToolBar *)toolBar;
//- (void)chatToolBarWillCancelRecoding:(ChatToolBar *)toolBar;
//- (void)chatToolBarContineRecording:(ChatToolBar *)toolBar;

- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView;
- (void)chatToolBarSendText:(NSString *)text;
- (void)chatToolBarTextViewDidChange:(UITextView *)textView;
- (void)chatToolBarTextViewDeleteBackward:(RFTextView *)textView;
@end


@interface ChatToolBar : UIImageView

@property (nonatomic, weak) id<ChatToolBarDelegate> delegate;

///...
@property (nonatomic, strong, readonly) TTAlphaThemedButton *imageButton;
@property (nonatomic, strong, readonly) TTAlphaThemedButton *sendButton;

/** 输入文本框 */
@property (nonatomic, readonly, strong) RFTextView *textView;
///...
@property (nonatomic, assign) BOOL allowImage;

///...
@property (nonatomic, strong) UIColor *topLineColor;

///...
// 为 RN 定制，只显示发送按钮，没有发送按钮和视频录制按钮间的切换逻辑
@property (nonatomic, assign) BOOL alwaysShowSendButton;

/**
 *  配置textView内容
 */
- (void)setTextViewContent:(NSString *)text;
- (void)clearTextViewContent;

/**
 *  配置placeHolder
 */
- (void)setTextViewPlaceHolder:(NSString *)placeholder;
- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor;

/**
 *  加载数据
 */
- (void)loadBarItems:(NSArray<ChatToolBarItem *> *)barItems;

@end
