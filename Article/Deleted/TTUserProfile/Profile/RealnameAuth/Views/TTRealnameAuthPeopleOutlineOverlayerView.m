//
//  TTPeopleOutlineOverlayerView.m
//  CameraDemo
//
//  Created by muhuai on 2018/1/15.
//  Copyright © 2018年 muhuai. All rights reserved.
//

#import "TTRealnameAuthPeopleOutlineOverlayerView.h"


@interface TTRealnameAuthPeopleOutlineOverlayerView()

@property (nonatomic, strong) UIImageView *peopleOutlineImageView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TTRealnameAuthPeopleOutlineOverlayerView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.userInteractionEnabled = NO;
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.font = [UIFont systemFontOfSize:14.f];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.text = @"请保持正脸在取景框内";
    [self.textLabel sizeToFit];
    self.textLabel.centerX = self.centerX;
    self.textLabel.top = 50.f;
    
    self.peopleOutlineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"people_outline"]];
    self.peopleOutlineImageView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat scale = self.frame.size.width / self.peopleOutlineImageView.frame.size.width;
    self.peopleOutlineImageView.frame = CGRectApplyAffineTransform(self.peopleOutlineImageView.frame,CGAffineTransformMakeScale(scale, scale));
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.peopleOutlineImageView.top = 77.f;
        self.textLabel.top = 33.f + 77.f;
    }
    [self addSubview:self.peopleOutlineImageView];
    [self addSubview:self.textLabel];
}

@end
