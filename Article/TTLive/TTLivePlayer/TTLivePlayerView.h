//
//  TTLivePlayerView.h
//  Article
//
//  Created by matrixzk on 25/09/2017.
//

#import <UIKit/UIKit.h>


@class TTLivePlayerControlView;
@class TVLApiRequestInfo;
@interface TTLivePlayerView : UIView

@property (nonatomic, strong, readonly) TTLivePlayerControlView *controlView;
@property (nonatomic, copy) BOOL (^shouldRotatePlayerViewBlock)(void);
@property (nonatomic, copy) void (^startPlayBlock)(void);

- (instancetype)initWithFrame:(CGRect)frame liveInfo:(TVLApiRequestInfo *)liveInfo;

- (void)setTitle:(NSString *)title;
- (void)setStatusView:(UIView *)statusView numOfParticipantsView:(UIView *)numOfParticipantsView;

- (void)play;
- (void)pause;

@end
