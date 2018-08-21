//
//  TTAdApointAlertView.h
//  Article
//
//  Created by yin on 16/9/21.
//
//

#import "SSThemed.h"
#import "SSWebViewContainer.h"
#import "TTGuideDispatchManager.h"
#import "TTAdConstant.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString* const TTAdAppointAlertViewShowKey;
extern NSString* const TTAdAppointAlertViewCloseKey;

//SubmitSuccess:提交成功  SubmitFail:提交失败   CloseForm:关闭按钮 LoadFail:web加载失败 LoadSuccess:web加载成功
typedef NS_ENUM(NSUInteger, TTAdApointCompleteType) {
    TTAdApointCompleteTypeSubmitSuccess = 0,
    TTAdApointCompleteTypeSubmitFail,
    TTAdApointCompleteTypeCloseForm,
    TTAdApointCompleteTypeLoadFail,
    TTAdApointCompleteTypeLoadSuccess
};

//表单来源 Feed或详情页
typedef NS_ENUM(NSUInteger, TTAdApointFromSource) {
    TTAdApointFromSourceFeed,
    TTAdApointFromSourceDetail,
};

typedef void(^TTAdApointCompleteBlock)(TTAdApointCompleteType type);
typedef void(^TTAdApointHideBlock)();

@protocol  TTAdAppointDelegate<NSObject>

- (void)appointAlertViewCompleteType:(TTAdApointCompleteType)type;

@end

@interface TTAdLoadingCicle : SSThemedView
@property(nonatomic, strong) SSThemedImageView * animationView;
- (void)startAnimating;
- (void)stopAnimating;
@end

@interface TTAdLoadingView : SSThemedView
@property (nonatomic,strong,nonnull) TTAdLoadingCicle* loadingCicle;
- (void)startAnimating;
- (void)stopAnimating;
@end

typedef void(^TTAdActionBlock)();
@interface TTAdRetryView : SSThemedView

@property (nonatomic,strong,nonnull) SSThemedButton* retryCicle;
@property (nonatomic,strong,nonnull) SSThemedLabel*  loadingLabel;
@property (nonatomic,copy,  nonnull) TTAdActionBlock block;
- (instancetype)initWithBlock:(TTAdActionBlock)block;
- (void)netWorkFail;
@end

@interface TTAdAppointAlertView : SSThemedView<YSWebViewDelegate, NSURLConnectionDelegate,TTGuideProtocol, UIScrollViewDelegate>

@property (nonatomic, weak) id<TTAdAppointDelegate> delegate;

- (TTAdAppointAlertView*)initWithModel:(id)appointModel fromSource:(TTAdApointFromSource)fromSource;

@end

@interface TTAdFormHandler : NSObject

@property (nonatomic,copy) TTAdApointCompleteBlock completeBlock;

+ (instancetype)sharedInstance;

- (BOOL)handleFormModel:(id<TTAdFormAction>)model fromSource:(TTAdApointFromSource)fromSource completeBlock:(TTAdApointCompleteBlock)block;

@end


@interface TTAdAppointAlertModel : NSObject<TTAdFormAction>

@property(nonatomic, copy)   NSString * ad_id;
@property(nonatomic, copy)   NSString * log_extra;
@property(nonatomic, copy)   NSString * formUrl;
@property(nonatomic, strong) NSNumber * formWidth;
@property(nonatomic, strong) NSNumber * formHeight;
@property(nonatomic, strong) NSNumber * formSizeValid;

- (instancetype)initWithAdId:(NSString *)ad_id logExtra:(NSString *)log_extra formUrl:(NSString *)url width:(NSNumber *)width height:(NSNumber *)height sizeValid:(NSNumber *)sizeValid;

// 此初始化方法不支持预约webview ocpc功能,不建议使用
- (instancetype)initWithFormUrl:(NSString *)url width:(NSNumber *)width height:(NSNumber *)height sizeValid:(NSNumber *)sizeValid;

@end

NS_ASSUME_NONNULL_END
