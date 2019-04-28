//
//  TTVideoDetailHeaderPosterViewProtocol.h
//  Article
//
//  Created by pei yun on 2017/4/11.
//
//

#ifndef TTVideoDetailHeaderPosterViewProtocol_h
#define TTVideoDetailHeaderPosterViewProtocol_h

@protocol TTVideoDetailHeaderPosterViewProtocol <NSObject>

@property (nonatomic, strong) SSThemedButton *playButton;
@property (nonatomic, assign) BOOL isAD;
@property (nonatomic, assign) BOOL showSourceLabel;
@property (nonatomic, assign) BOOL showPlayButton;

- (void)removeAllActions;

@end

#endif /* TTVideoDetailHeaderPosterViewProtocol_h */
