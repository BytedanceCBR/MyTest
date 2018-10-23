//
//  TTImagePreviewVideoView.h
//  Article
//
//  Created by SongChai on 2017/4/12.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@class TTImagePreviewViewController;

typedef NS_ENUM(NSInteger, TTImagePreviewVideoState) {
    TTImagePreviewVideoStateNormal,
    TTImagePreviewVideoStatePlaying,
    TTImagePreviewVideoStatePause,
};

@class TTImagePreviewVideoManager;
@interface TTImagePreviewVideoView  : UIImageView

@property (nonatomic, strong) id asset;
@property (nonatomic, assign) TTImagePreviewVideoState state;

-(id)initWithFrame:(CGRect)frame withManager:(TTImagePreviewVideoManager*) manager;

-(void)setCover:(UIImage *)cover;

-(void)prepare;

-(void)play; //如果asset没变，play为继续播放

-(void)pause;

-(void)stop;

@end

@interface TTImagePreviewVideoLayerView : UIView

@property (nonatomic, strong) AVPlayer* player;

@property (nonatomic, strong) id asset;
@property(assign, nonatomic) TTImagePreviewVideoState state;

-(id)initWithFrame:(CGRect)frame;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

- (void) shutdown;
- (void) prepare;
- (void) play;
- (void) resume;
- (void) pause;

@property (nonatomic, weak) TTImagePreviewViewController *myVC;

@end
