//
//  TTVADGuideCountdownViewProtocol.h
//  Article
//
//  Created by pei yun on 2017/10/29.
//

#ifndef TTVADGuideCountdownViewProtocol_h
#define TTVADGuideCountdownViewProtocol_h

@protocol TTVADGuideCountdownViewProtocol

- (void)performVerticalTranslation:(BOOL)toolBarHidden needShiftDown:(BOOL)needShiftDown animated:(BOOL)animated;
- (void)pauseTimer;
- (void)resumeTimer;

@end

#endif /* TTVADGuideCountdownViewProtocol_h */
