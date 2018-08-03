//
//  TTUGCTextViewMediator.h
//  Article
//  中介者模式，处理 toolbar 和 textView 之间的交互，以及对外统一抛出事件
//  调用方还有额外的回调需要，则使用 `-(BOOL)tt_addDelegate:(id)delegate asMainDelegate:(BOOL)asMain` 方法来添加多路代理
//
//  Created by Jiyee Sheng on 28/11/2017.
//
//


#import "TTUGCToolbar.h"
#import "TTUGCTextView.h"
#import "TTUGCSearchUserViewController.h"
#import "TTUGCSearchHashtagViewController.h"

@interface TTUGCTextViewMediator : NSObject <TTUGCTextViewDelegate, TTUGCToolbarDelegate, TTUGCSearchUserTableViewDelegate, TTUGCSearchHashtagTableViewDelegate>

@property (nonatomic, strong) SSThemedView <TTUGCToolbarProtocol> *toolbar;
@property (nonatomic, strong) TTUGCTextView *textView;

@property (nonatomic, assign) TTHashtagSuggestOption hashtagSuggestOption;

/**
 * at 人或话题选择器面板是否正在显示
 */
@property (nonatomic, assign) BOOL isSelectViewControllerVisible;

@end
