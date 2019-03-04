//
//  TTVAudioWaveView.h
//  Article
//
//  Created by panxiang on 2017/5/23.
//
//

#import <UIKit/UIKit.h>

@interface TTVAudioWaveView : UIView

@property (nonatomic, readonly) BOOL isWaving;

/**
 *  开始动画
 */
- (void)wave;

/**
 *  结束动画
 */
- (void)finish;

@end

