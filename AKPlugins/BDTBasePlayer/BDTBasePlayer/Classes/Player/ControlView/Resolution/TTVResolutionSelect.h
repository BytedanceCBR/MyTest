//
//  TTVResolutionSelect.h
//  Article
//
//  Created by panxiang on 2017/5/24.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTVPlayerControllerState.h"
#import "TTVPlayerControlBottomView.h"

@protocol TTVResolutionSelectDelegate <NSObject>

- (void)resolutionClickedWithType:(TTVPlayerResolutionType)type typeString:(NSString *)typeString;

@end

@interface TTVResolutionSelect : NSObject<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, assign) BOOL enableResolution;
@property(nonatomic, weak)UIView <TTVPlayerControlBottomView, TTVPlayerContext> *bottomBarView;
@property(nonatomic, weak)UIView *superView;
@property (nonatomic, weak) id <TTVResolutionSelectDelegate> delegate;

- (void)show;
- (void)showWithBottom:(CGFloat)bottom;
- (void)hidden;
@end
