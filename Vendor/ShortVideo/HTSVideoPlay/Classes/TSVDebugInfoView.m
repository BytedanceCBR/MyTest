//
//  TSVDebugView.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 24/11/2017.
//

#import "TSVDebugInfoView.h"

@interface TSVDebugInfoView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation TSVDebugInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _label = [[UILabel alloc] initWithFrame:self.frame];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _label.textColor = [UIColor whiteColor];
        _label.adjustsFontSizeToFitWidth = YES;
        _label.minimumScaleFactor = 0.2;
        _label.numberOfLines = 0;
        [self addSubview:_label];
    }

    return self;
}

- (void)setDebugInfo:(NSString *)debugInfo
{
    _debugInfo = debugInfo;
    
    self.label.text = debugInfo;
}

@end
