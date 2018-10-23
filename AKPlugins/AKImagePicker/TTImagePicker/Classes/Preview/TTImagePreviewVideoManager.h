//
//  TTImagePreviewVideoManager.h
//  Article
//
//  Created by SongChai on 2017/4/12.
//
//

#import <Foundation/Foundation.h>
#import "TTImagePreviewVideoView.h"

typedef void(^TTImagePreviewVideoStateBlock)(TTImagePreviewVideoState state);


@interface TTImagePreviewVideoManager : NSObject

@property(nonatomic, strong) id asset;

@property(nonatomic, copy) TTImagePreviewVideoStateBlock stateBlock;

-(void)setVideoView:(TTImagePreviewVideoView *)view;
-(void)removeVideoView;

-(void)destory;

@property (strong, readonly) TTImagePreviewVideoLayerView *videoPlayer;

@end
