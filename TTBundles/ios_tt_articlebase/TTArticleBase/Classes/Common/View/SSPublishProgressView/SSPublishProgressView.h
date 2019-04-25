//
//  SSPublishProgressView.h
//  Article
//
//  Created by Zhang Leonardo on 13-5-9.
//
//

#import "SSViewBase.h"

@interface SSPublishProgressView : SSViewBase

@property(nonatomic, retain)UIImageView * bgImgView;
@property(nonatomic, retain)UIButton * cancelButton;
@property(nonatomic, retain)UILabel * titleLabel;
@property(nonatomic, retain)UILabel * progressLabel;
@property(nonatomic, retain)UIImageView * progressBgView;
@property(nonatomic, retain)UIImageView * progressFgView;

- (void)setProgress:(CGFloat)progress;
- (void)addTarget:(id)target selecter:(SEL)sel;

@end
