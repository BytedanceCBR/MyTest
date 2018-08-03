//
//  ExploreWidgetEmptyView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-13.
//
//

#import "ExploreWidgetEmptyView.h"
#import "TTBaseMacro.h"
#import "TTWidgetTool.h"

#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]

#define kTopMargin                      18
#define kBottomMargin                   18
#define kLabelFontSize                  18
#define kIndicatorViewHeight            20
#define kIndicatorViewWidth             20
#define kIndicatorViewRightPadding      4
#define kLeftMargin                     (([TTWidgetTool OSVersionNumber] >= 10.0) ? 8.0 : 0.0)
#define kRightMargin                    8
#define kLeftSystemPadding              (([TTWidgetTool OSVersionNumber] >= 10.0) ? 0.0 : 47.0)

@interface ExploreWidgetEmptyView()
@property(nonatomic, retain)UILabel * tipLabel;
@property(nonatomic, retain)UIActivityIndicatorView * indicatorView;
@property(nonatomic, assign, readwrite)ExploreWidgetEmptyViewType emptyType;
@property(nonatomic, retain, readwrite)UIButton * actionButton;
@property(nonatomic, retain)UIView * bottomLineView;
@end

@implementation ExploreWidgetEmptyView

- (void)dealloc
{
    if (_indicatorView.isAnimating) {
        [_indicatorView stopAnimating];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont systemFontOfSize:kLabelFontSize];
        _tipLabel.backgroundColor = [UIColor clearColor];
        if ([TTWidgetTool OSVersionNumber] >= 10.0) {
            _tipLabel.textColor = [UIColor blackColor];
            _tipLabel.alpha = 1.0f;
        }
        else {
            _tipLabel.textColor = [UIColor whiteColor];
            _tipLabel.alpha = 0.5f;
        }
        [self addSubview:_tipLabel];
        
        self.bottomLineView =[[UIView alloc] initWithFrame:CGRectZero];
        if ([TTWidgetTool OSVersionNumber] >= 10.0) {
            _bottomLineView.backgroundColor = [UIColor blackColor];
            _bottomLineView.alpha = 0.1f;
        }
        else {
            _bottomLineView.backgroundColor = [UIColor whiteColor];
            _bottomLineView.alpha = 0.4f;
        }
        [self addSubview:_bottomLineView];

        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.frame = self.bounds;
        [self addSubview:_actionButton];
    }
    return self;
}

- (void)refreshType:(ExploreWidgetEmptyViewType)type
{
    self.emptyType = type;
    
    if (_emptyType == ExploreWidgetEmptyViewTypeError) {
        [_tipLabel setText:NSLocalizedString(@"网络异常，点击重试", nil)];
        [_tipLabel sizeToFit];
        
        _tipLabel.center = CGPointMake(self.frame.size.width / 2  - kLeftSystemPadding / 2, self.frame.size.height / 2);
        
        if (_indicatorView.isAnimating) {
            [_indicatorView stopAnimating];
        }
        [_indicatorView removeFromSuperview];
        self.indicatorView = nil;
    }
    else {
        [_tipLabel setText:NSLocalizedString(@"推荐中", nil)];
        [_tipLabel sizeToFit];
        if (!_indicatorView) {
            self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:([TTWidgetTool OSVersionNumber] >= 10.0) ? UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhite];
            _indicatorView.frame = CGRectMake(0, 0, kIndicatorViewWidth, kIndicatorViewHeight);
            [self addSubview:_indicatorView];
        }
        [_indicatorView startAnimating];
        
        _tipLabel.frame = CGRectMake(
                           (self.frame.size.width - _tipLabel.frame.size.width) / 2 + kIndicatorViewWidth / 2 + kIndicatorViewRightPadding - kLeftSystemPadding / 2,
                           (self.frame.size.height - _tipLabel.frame.size.height) / 2,
                                     _tipLabel.frame.size.width,
                                     _tipLabel.frame.size.height);
        
        _indicatorView.frame = CGRectMake(CGRectGetMinX(_tipLabel.frame) - kIndicatorViewWidth - kIndicatorViewRightPadding,
                           (self.frame.size.height - _indicatorView.frame.size.height) / 2,
                                           _indicatorView.frame.size.width,
                                           _indicatorView.frame.size.height);
    }
    
     _bottomLineView.frame = CGRectMake(kLeftMargin, self.frame.size.height - 1, self.frame.size.width - kRightMargin - kLeftMargin, [TTWidgetTool ssOnePixel]);
    
    [self sendSubviewToBack:_actionButton];
}


+ (CGFloat)heightForView
{
    return kTopMargin + kBottomMargin + kLabelFontSize;
}
@end
