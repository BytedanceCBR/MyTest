//
//  Macrol.h
//  FaceKeyboard
//
//  Created by ruofei on 16/3/31.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#ifndef ChatKeyBoardMacroDefine_h
#define ChatKeyBoardMacroDefine_h

#define kScreenWidth    [[UIApplication sharedApplication] keyWindow].width
// [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight   [[UIApplication sharedApplication] keyWindow].height//[[UIScreen mainScreen] bounds].size.height

/**  判断文字中是否包含表情 */
#define IsTextContainFace(text) (text.length > 1) && [text containsString:@"["] &&  [text containsString:@"]"] && [[text substringFromIndex:text.length - 1] isEqualToString:@"]"]

//ChatKeyBoard背景颜色
#define kChatKeyBoardColor              [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.0f]

//键盘上面的工具条
///...
//#define kChatToolBarHeight              49
#define kChatToolBarHeight (45)

//整个聊天工具的高度
#define kChatKeyBoardHeight     kChatToolBarHeight

#define isIPhone4_5                (kScreenWidth == 320)
#define isIPhone6_6s               (kScreenWidth == 375)
#define isIPhone6p_6sp             (kScreenWidth == 414)

#endif /* ChatKeyBoardMacroDefine_h */
