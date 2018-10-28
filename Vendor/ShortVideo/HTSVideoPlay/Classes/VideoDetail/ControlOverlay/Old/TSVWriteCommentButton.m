//
//  TSVWriteCommentButton.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 20/09/2017.
//

#import "TSVWriteCommentButton.h"
#import "HTSVideoPlayColor.h"

@interface TSVWriteCommentButton ()

@property (nonatomic, strong) UILabel *label;
//@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation TSVWriteCommentButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
        self.layer.cornerRadius = 16.;

        self.label = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = LiveStandardColorS5;
            label.text = @"写评论...";
            label;
        });
        [self addSubview:self.label];

//        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hts_vp_write_new_white"]];
//        [self addSubview:self.iconImageView];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [UIView performWithoutAnimation:^{
//        self.iconImageView.bounds = CGRectMake(0, 0, 24, 24);
//        self.iconImageView.center = CGPointMake(20, CGRectGetHeight(self.frame) / 2);

//        self.label.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 4, 0,
//                                      CGRectGetWidth(self.frame) - 4 - CGRectGetMaxX(self.iconImageView.frame),
//                                      CGRectGetHeight(self.frame));
        
        self.label.frame = CGRectMake(20, 0,
                                      CGRectGetWidth(self.frame) - 20,
                                      CGRectGetHeight(self.frame));
    }];
}

@end
