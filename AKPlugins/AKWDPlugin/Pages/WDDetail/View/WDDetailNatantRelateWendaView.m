//
//  WDDetailNatantRelateWendaView.m
//  Article
//
//  Created by 延晋 张 on 16/4/27.
//
//

#import "WDDetailNatantRelateWendaView.h"
#import "WDDetailModel.h"
#import "WDDefines.h"
 
#import "TTStringHelper.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"
#import "TTRoute.h"

@interface WDDetailNatantRelateWendaView ()

@property (nonnull, strong, nonatomic) WDDetailNatantRelatedItemModel * model;
@property(nonatomic, strong)SSThemedLabel * titleLabel;
@property(nonatomic, strong)SSThemedView * bottomLineView;
@property(nonatomic, strong)SSThemedButton * bgButton;
@property(nonatomic, strong)SSThemedLabel * titleLeftTagView;


@end

@implementation WDDetailNatantRelateWendaView

+ (nullable WDDetailNatantRelateWendaView *)genViewForModel:(nullable WDDetailNatantRelatedItemModel *)model
                                                          width:(float)width
{
    WDDetailNatantRelateWendaView * view = nil;
    view = [[WDDetailNatantRelateWendaView alloc] initWithWidth:width];
    [view refreshModel:model];
    return view;
}

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.backgroundColorThemeKey= kColorBackground3;
        self.bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _bgButton.frame = self.bounds;
        _bgButton.backgroundColor = [UIColor clearColor];;
        _bgButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bgButton];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            _titleLabel.font = [UIFont systemFontOfSize:17];
        }
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_titleLabel];
        
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
        _bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bottomLineView];
        
        
        self.titleLeftTagView = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLeftTagView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _titleLeftTagView.layer.cornerRadius = 3;
        _titleLeftTagView.textAlignment  = NSTextAlignmentCenter;
        _titleLeftTagView.font = [UIFont systemFontOfSize:9];
        _titleLeftTagView.clipsToBounds = YES;
        _titleLeftTagView.textColorThemeKey = kColorText6;
        _titleLeftTagView.borderColorThemeKey = kColorLine5;
        
        [self addSubview:_titleLeftTagView];
        
        [self reloadThemeUI];
        
    }
    return self;
}

- (void)refreshModel:(nullable WDDetailNatantRelatedItemModel *)model
{
    _model = model;
    
    _titleLabel.text = model.title;
    
    _titleLeftTagView.text = model.typeName;
    
    self.frame = CGRectMake(0, 0, self.width, 45);
    if (model.typeName.length > 0) {
        
        CGRect unlimitRect = [_titleLeftTagView.text boundingRectWithSize:CGSizeMake(999, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _titleLeftTagView.font} context:nil];
        _titleLeftTagView.frame = CGRectMake(15, 16, unlimitRect.size.width+8, 14);
        _titleLabel.frame = CGRectMake(_titleLeftTagView.right + 10, 0, self.width - 30 - _titleLeftTagView.width - 10, 45);
        
    }
    else {
        _titleLabel.frame = CGRectMake(15, 0, self.width - 30, 45);
    }
    
    [self refreshBottomLineView];
    
    [self sendSubviewToBack:_bgButton];
}

- (void)refreshBottomLineView
{
    _bottomLineView.frame = CGRectMake(15, self.height - [TTDeviceHelper ssOnePixel], self.width - 30, [TTDeviceHelper ssOnePixel]);
}

- (void)hideBottomLine:(BOOL)hide
{
    self.bottomLineView.hidden = hide;
}

-(void)bgButtonClicked
{
    NSString * openPageURL = self.model.schema;
    if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openPageURL]]) {
        [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:openPageURL] userInfo:nil];
    }
    [TTTracker category:@"umeng" event:kWDDetailViewControllerUMEventName label:@"click_related" dict:self.detailModule.gdExtJsonDict];

}

@end

