//
//  TTVPlayerTipRetry.h
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import <UIKit/UIKit.h>

typedef void(^RetryAction)(void);
@protocol TTVPlayerTipRetry <NSObject>
@property(nonatomic, assign)BOOL isFullScreen;
/**
 网络错误码,如视频正在审核中,给用户明确的提示
 */
@property(nonatomic, assign)NSInteger errorCode;
@property(nonatomic, copy)RetryAction retryAction;
@end

@interface TTVPlayerTipRetry : UIView<TTVPlayerTipRetry>
@property(nonatomic, assign)BOOL isFullScreen;
@property(nonatomic, copy)RetryAction retryAction;
@property(nonatomic, assign)NSInteger errorCode;
@end
