//
//  TTLiveMessageBox.h
//  Article
//
//  Created by xuzichao on 16/1/6.
//
//
//  通过initWithFrame初始化固定位置

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTLiveTopBannerInfoModel.h"

@class TTLiveMainViewController;
@class TTLiveMessage;

typedef NS_ENUM(NSUInteger, TTLiveMessageBoxType) {
    TTLiveMessageBoxTypeSupportTextOnly = 0, //只能发文字,对应观众
    TTLiveMessageBoxTypeSupportAll = 1 //文字、拍摄、本地照片、语音，对应嘉宾和明星
};

static CGFloat kTopPaddingOfTextView = 6; // textView上下padding
static CGFloat kMinHeightOfTextView = 38; // textView单行文字时的高度
static CGFloat kMaxHeightOfTextView = 74; // textView三行文字时的高度
static CGFloat kHeightOfBottomMediaView = 40; // textView下边多媒体view的高度

// 视觉上消息发送框的高度，实际高度下述
NS_INLINE CGFloat kVisualHeightOfMsgBoxWithTypeTextOnly() {
    return kMinHeightOfTextView + kTopPaddingOfTextView*2;
}
NS_INLINE CGFloat kVisualHeightOfMsgBoxWithTypeSupportAll() {
    return kVisualHeightOfMsgBoxWithTypeTextOnly() + kHeightOfBottomMediaView;
}
// 消息发送框的实际高度(默认为三行textView的高度，只是透明处理了，这样做是为了解决textView自增高过程中的抖动问题)
NS_INLINE CGFloat kRealHeightOfMsgBoxWithTypeTextOnly() {
    return kMaxHeightOfTextView + kTopPaddingOfTextView*2;
}
NS_INLINE CGFloat kRealHeightOfMsgBoxWithTypeSupportAll() {
    return kRealHeightOfMsgBoxWithTypeTextOnly() + kHeightOfBottomMediaView;
}

@class TTLiveMessageBox;

@protocol TTLiveMessageBoxDelegate <NSObject>

@optional

/** 用户点赞 */
- (void)tt_clickPariseByUserWithCommonImage:(NSString *)commonImage;

//准备发送消息
- (void)ttMessagePrepareToSendOut;

//输入框编辑状态
- (void)ttMessageTextBeginEditing:(UIView *)textView;
- (void)ttMessageTextEditDidChange:(UIView *)textView;;
- (void)ttMessageTextEndEditing:(UIView *)textView;;

//本地选取中，视频返回File NSUrl,照片返回ALAsset
- (void)ttMessageAlbumPhotoLibraryBack:(NSMutableArray *)assetsArray;

//拍照成功返回
- (void)ttMessageCameraPhotoBackAssetUrl:(NSURL *)url image:(UIImage *)photoImage;

//视频成功返回文件URL以及视频预览图片
- (void)ttMessageCameraVideoBack:(NSURL *)videoUrl previewImage:(UIImage *)previewImage;

//录音成功返回文件url
- (void)ttMessageAudioRecordFinishedWithURL:(NSURL *)audioUrl duration:(CGFloat)duration;

//发送文字消息
- (void)ttMessageBox:(TTLiveMessageBox *)messageBox textBack:(NSString *)text;

// 多媒体消息编辑
- (void)ttLiveMediaMessageEditPrepared:(TTLiveMessageBox *)messageBox;
- (void)ttLiveMediaMessageEditDidFinished:(TTLiveMessageBox *)messageBox;

@end

@interface TTLiveMessageBox : SSThemedView

@property (nonatomic, weak) id<TTLiveMessageBoxDelegate> delegate;

@property (nonatomic, strong, readonly) TTLiveMessage *replyedMsg;
@property (nonatomic, weak) TTLiveMainViewController *mainChatroom;
@property (nonatomic, strong, readonly) SSThemedButton *pariseButton;

@property (nonatomic, copy, readonly) NSString *pariseImageUrl;

@property (nonatomic) BOOL shouldShowPariseButton;
@property (nonatomic, assign) BOOL disableSendMsg;
@property (nonatomic) TTLiveType type;

- (void)clearDataBySendSuccess;

//统计
- (void)setSsTrackerDic:(NSDictionary *)ssTrackerDic;

//根据身份生成不同类型

/**
 根据身份设置输入栏样式

 @param newMessageType 新样式
 */
- (void)setMessageViewType:(TTLiveMessageBoxType)messageType;

//输入框默认提示文字颜色
- (void)setInputPlaceholder:(NSString *)defaultText TextColor:(UIColor *)color;

//输入框左边显示的图标
- (void)setInputBarSpeakerAvatar:(UIImage *)image;

- (void)changePariseCommonImage:(NSString *)imageName;

/**
 回复

 @param type       回复类型
 @param replyedMsg 回复信息
 */
- (void)activedWithType:(TTLiveMessageBoxType)type replyedMessage:(TTLiveMessage *)replyedMsg;

/**
 收起到最小

 @param isCancel 取消状态
 */
- (void)becomeToShortestAtBottom:(BOOL)isCancel;

- (void)setPariseCount:(NSString *)count;

- (void)textFieldButtonClick:(UITapGestureRecognizer *)recognizer;

- (BOOL)currentIsEditing;

@end
