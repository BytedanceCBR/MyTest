//
//  TTVPlayerTipLoading.h
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import <UIKit/UIKit.h>

@protocol TTVPlayerTipLoading <NSObject>
@property(nonatomic, assign)BOOL isFullScreen;
- (void)stopLoading;
- (void)startLoading:(NSString *)tipText;
@end

@interface TTVPlayerTipLoading : UIView<TTVPlayerTipLoading>
@property(nonatomic, assign)BOOL isFullScreen;
- (void)stopLoading;
- (void)startLoading:(NSString *)tipText;
@end
