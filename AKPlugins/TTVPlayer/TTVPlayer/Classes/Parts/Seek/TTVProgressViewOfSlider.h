//
//  TTVProgressViewOfSlider.h
//  Article
//
//  Created by liuty on 2017/1/8.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerSliderMarkView.h"
#import "TTVPlayerCustomViewDelegate.h"

@interface TTVProgressViewOfSlider : UIView<TTVProgressViewOfSliderProtocol>

// 标记点 标记位置为 [0, 1]， 同progress
@property (nonatomic, strong) NSArray <NSNumber *> *markPoints;
@property (nonatomic, strong) NSArray <NSNumber *> *openingPoints;

@property (nonatomic, strong) TTVPlayerSliderMarkView *markView;

@end
