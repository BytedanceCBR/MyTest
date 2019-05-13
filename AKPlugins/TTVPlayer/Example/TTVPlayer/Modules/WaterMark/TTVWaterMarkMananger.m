//
//  TTVWaterMarkMananger.m
//  Article
//
//  Created by panxiang on 2018/7/23.
//

#import "TTVWaterMarkMananger.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVPlayerStateWaterMarkPrivate.h"

#import "TTVPlayerStateFullScreen.h"

@interface TTVWaterMarkView : UIImageView
@property (nonatomic, strong) UIImage *watermarkFullImage;
@property (nonatomic, strong) UIImage *watermarkImage;
@property (nonatomic, strong) TTVPlayerStore *store;
@property (nonatomic, strong) TTVPlayerState *state;
@end

@implementation TTVWaterMarkView

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    self.state.waterMark.hidden = hidden;
}

- (void)setStore:(TTVPlayerStore *)store
{
    _store = store;
    self.state = (TTVPlayerState *)store.state;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    TTVideoEngineURLInfo *info = [self urlInfo];
    self.hidden = !info.encrypt;
    if (self.hidden || !self.superview) {
        return;
    }
    if (self.watermarkImage && self.watermarkFullImage) {
        self.image = self.fullScreen ? self.watermarkFullImage : self.watermarkImage;
    }
    [self sizeToFit];
    
    CGFloat rightOffset = 0;
    
    CGFloat topOffset = 28 - self.image.size.height / 2.0;
    BOOL fullScreen = self.fullScreen;
    
    CGFloat playerViewHeight = self.superview.frame.size.height;
    CGFloat playerViewWidth = self.superview.frame.size.width;
    
    if (fullScreen) {
        CGRect fullScreenFrame = [self.state landscapeFullScreenBounds];
        playerViewHeight = fullScreenFrame.size.height;
        playerViewWidth = fullScreenFrame.size.width;
    }else{
        topOffset = 10 - (self.image.size.height - 24) / 2.0;
    }
    
    CGFloat videoWidth = [info.vWidth doubleValue];
    CGFloat videoHeight = [info.vHeight doubleValue];
    
    if (playerViewHeight > 0 && playerViewWidth > 0 && videoHeight > 0 && videoWidth > 0 && self.store.player.scaleMode != TTVideoEngineScalingModeAspectFill) {
        // TODO: 后续做满屏播放以及缩屏缩放时，这里还需要相应的调整。
        // 这里的假设是100%播放。
        if (playerViewWidth/playerViewHeight >= videoWidth/videoHeight) {
            //左右会留有黑边，Logo位置左移
            videoWidth = playerViewHeight/videoHeight*videoWidth;
            rightOffset = rightOffset - (playerViewWidth - videoWidth) / 2.0;
        } else {
            //上下会留有黑边，logo位置下移
            videoHeight = playerViewWidth/videoWidth*videoHeight;
            topOffset = topOffset + (playerViewHeight -videoHeight) / 2.0;
        }
    }
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.superview).offset(topOffset);
        make.right.mas_equalTo(self.superview).offset(rightOffset);
    }];
    
}

- (TTVideoEngineURLInfo *)urlInfo
{
    return [self.store.player.videoInfo videoInfoForType:self.store.player.currentResolution];
}

- (BOOL)fullScreen
{
    TTVPlayerStateFullScreen * state = [self.state stateForKey:[TTVPlayerStateFullScreen class]];
    return state.isFullScreen;
}

- (void)setWatermarkImage:(UIImage *)image watermarkFullImage:(UIImage *)fullImage
{
    self.watermarkImage = image;
    self.watermarkFullImage = fullImage;
    [self setNeedsLayout];
}
@end


@interface TTVWaterMarkMananger()
@property (nonatomic ,strong)TTVWaterMarkView *markView;
@end


@implementation TTVWaterMarkMananger
@synthesize store = _store;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _markView = [[TTVWaterMarkView alloc] init];
    }
    return self;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {
        self.markView = [[TTVWaterMarkView alloc] init];
        self.markView.store = self.store;
        @weakify(self);
        [RACObserve(self.store.player, scaleMode) subscribeNext:^(NSNumber *scaleMode) {
            @strongify(self);
            [self.markView setNeedsLayout];
        }];
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVPlayerActionTypeWaterMarkHidden]) {
                [self setMarkViewHidden:[[action.info valueForKey:@"hidden"] boolValue]];
            }
        }];
    }
}

- (void)setMarkViewHidden:(BOOL)hidden
{
    self.store.state.waterMark.hidden = hidden;
    self.markView.hidden = hidden;
}

- (void)setWatermarkImage:(UIImage *)image watermarkFullImage:(UIImage *)fullImage
{
    [self setMarkViewHidden:NO];
    [self.markView setWatermarkImage:image watermarkFullImage:fullImage];
}

- (void)defaultWaterMark
{
    [self setMarkViewHidden:NO];
    [self.markView setWatermarkImage:[UIImage imageNamed:@"player_watermark"] watermarkFullImage:[UIImage imageNamed:@"player_watermark_full"]];
}
@end

@implementation TTVPlayer (WaterMark)

- (TTVWaterMarkMananger *)waterMarkMananger
{    return nil;

//    return [self partManagerFromClass:[TTVWaterMarkMananger class]];
}

@end
