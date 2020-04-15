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

typedef void (^DidClickHashtagButtonBlock)(BOOL didInputTextHashtag);
typedef void (^DidClickAtButtonBlock)(BOOL didInputAt);

@protocol TTUGCAddMultiImageProtocol

- (void)presentMultiImagePickerView;

@end
@class FHTopicListResponseDataListModel;
@interface TTUGCTextViewMediator : NSObject <TTUGCTextViewDelegate, TTUGCToolbarDelegate, TTUGCSearchUserTableViewDelegate>

@property (nonatomic, strong) SSThemedView <TTUGCToolbarProtocol> *toolbar;
@property (nonatomic, strong) TTUGCTextView *textView;

@property (nonatomic, strong) SSThemedView <TTUGCAddMultiImageProtocol> *multiImageView;

@property (nonatomic, assign) TTHashtagSuggestOption hashtagSuggestOption;

@property (nonatomic, assign) BOOL showCanBeCreatedHashtag; // 是否展示可被创建的话题

@property (nonatomic, copy)  NSString *richSpanColorHexStringForDay;

@property (nonatomic, copy)  NSString *richSpanColorHexStringForNight;

/**
 * at 人或话题选择器面板是否正在显示
 */
@property (nonatomic, assign) BOOL isSelectViewControllerVisible;

@property (nonatomic, copy) DidClickHashtagButtonBlock hashTagBtnClickBlock;
@property (nonatomic, copy) DidClickAtButtonBlock atBtnClickBlock;
@property (nonatomic, assign) BOOL isPushOutAtListController;

// 埋点数据
@property (nonatomic, strong) NSDictionary *traceDict;

- (void)addHashtag:(FHTopicListResponseDataListModel *)hashtagModel;

//@事件点击
- (void)toolbarDidClickAtButton;

@end
