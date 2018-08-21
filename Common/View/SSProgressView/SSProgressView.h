//
//  SSProgressView.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-7-30.
//
//

#import <UIKit/UIKit.h>

typedef enum{
    SSProgressViewStyleTowardLeft,
    SSProgressViewStyleTowardUp,
    SSProgressViewStyleTowardDown,
    SSProgressViewStyleTowardRight
}SSProgressViewStyle;

@interface SSProgressView : UIView

@property (nonatomic, assign)CGFloat progress;
@property (nonatomic, assign)SSProgressViewStyle style;
@property (nonatomic, retain)UIImage * progressBackgroundImage;
@property (nonatomic, retain)UIImage * progressForegroundImage;
@property (nonatomic, retain)UIImage * progressHeadImage;
@property (nonatomic, assign)UIEdgeInsets progressViewEdgeInsets;
@property(nonatomic, assign)BOOL progressStop;

- (id)initWithProgressViewStyle:(SSProgressViewStyle)style;
- (void)setProgress:(float)progress animated:(BOOL)animated; // you should set 0.f - 100.f
@end
