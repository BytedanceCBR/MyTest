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

@class TTMoviePlayerControlBottomView;

@protocol TTVResolutionSelectDelegate <NSObject>

- (void)resolutionClickedWithType:(TTVPlayerResolutionType)type typeString:(NSString *)typeString;

@end

@interface TTVResolutionSelect : NSObject<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, assign) BOOL enableResolution;
@property(nonatomic, assign) TTVPlayerResolutionType resolutionType;
@property(nonatomic, weak)TTMoviePlayerControlBottomView *bottomBarView;
@property(nonatomic, weak)UIView *superView;
@property (nonatomic, weak) id <TTVResolutionSelectDelegate> delegate;

- (void)show;
- (void)showWithBottom:(CGFloat)bottom;
- (void)hidden;
@end
