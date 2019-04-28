//
//  TTPlayerSliderMarkView.h
//  Article
//
//  Created by liufeng on 2017/8/22.
//
//

#import <UIKit/UIKit.h>

@interface TTPlayerSliderMarkView : UIView

@property (nonatomic, strong) NSArray <NSNumber *>*markPoints;
@property (nonatomic, strong) NSArray <NSNumber *>*openingPoints;
- (void)updateMarkColorWithProgress:(CGFloat)progress;



@end
