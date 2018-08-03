//
//  TFDetailView.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-29.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFDetailView.h"
#import "SSTitleBarView.h"
#import "SSButton.h"
#import "TFAppInfosView.h"
#import "UIColorAdditions.h"

#define tipLabelLeftPadding 20

#define valueLabelFontSize 15.f

@interface TFDetailView()

@property(nonatomic, retain)SSTitleBarView * titleBar;
@property(nonatomic, retain)TFAppInfosModel * model;
@property(nonatomic, assign)NSUInteger listIndex;
@property(nonatomic, retain)TFAppInfosView * infosView;

@property(nonatomic, retain)UILabel * infoTipLabel;
@property(nonatomic, retain)UILabel * fileSizeTipLabel;
@property(nonatomic, retain)UILabel * updateTimeTipLabel;
@property(nonatomic, retain)UILabel * whatsNewTipLabel;

@property(nonatomic, retain)UILabel * fileSizeLabel;
@property(nonatomic, retain)UILabel * updateTimeLabel;

@property(nonatomic, retain)UILabel * whatsNewLabel;
@property(nonatomic, retain)UIScrollView * contentView;
@end

@implementation TFDetailView

- (void)dealloc
{
    self.contentView = nil;
    self.whatsNewLabel = nil;
    self.fileSizeLabel = nil;
    self.updateTimeTipLabel = nil;
    self.infoTipLabel = nil;
    self.fileSizeTipLabel = nil;
    self.updateTimeTipLabel = nil;
    self.whatsNewTipLabel = nil;
    
    self.infosView = nil;
    self.titleBar = nil;
    self.model = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithHexString:@"dddddd"];
        
        self.titleBar = [[[SSTitleBarView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [SSTitleBarView titleBarHeight])] autorelease];
        [self addSubview:_titleBar];
        [_titleBar setTitleText:@"应用详情"];
        
        SSButton * backButton = [SSButton buttonWithSSButtonType:SSButtonTypeLeftBack];
        [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _titleBar.leftView = backButton;
        
//        SSButton * refreshButton = [SSButton buttonWithSSButtonType:SSButtonTypeRefresh];
//        [refreshButton addTarget:self action:@selector(refreshButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//        _titleBar.rightView = refreshButton;
        
        self.contentView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleBar.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(_titleBar.frame))] autorelease];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        
        CGFloat infosViewHeight = [TFAppInfosView heightForCellWithModel:_model cellWidth:self.frame.size.width];
        self.infosView = [[[TFAppInfosView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), infosViewHeight)] autorelease];
        _infosView.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
        [_contentView addSubview:_infosView];
        
        self.infoTipLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _infoTipLabel.text = @"信息";
        _infoTipLabel.textColor = [UIColor colorWithHexString:@"333333"];
        _infoTipLabel.backgroundColor = [UIColor clearColor];
        _infoTipLabel.font = [UIFont boldSystemFontOfSize:17.f];
        [_infoTipLabel sizeToFit];
        setFrameWithOrigin(_infoTipLabel, tipLabelLeftPadding, CGRectGetMaxY(_infosView.frame) + 10);
        [_contentView addSubview:_infoTipLabel];

        self.updateTimeTipLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        [self refreshTipLabelParameter:_updateTimeTipLabel];
        _updateTimeTipLabel.text = @"更新";
        setFrameWithOrigin(_updateTimeTipLabel, 10, CGRectGetMaxY(_infoTipLabel.frame) + 10);
        [_contentView addSubview:_updateTimeTipLabel];
        
        self.fileSizeTipLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        [self refreshTipLabelParameter:_fileSizeTipLabel];
        _fileSizeTipLabel.text = @"大小";
        setFrameWithOrigin(_fileSizeTipLabel, 10, CGRectGetMaxY(_updateTimeTipLabel.frame) + 10);
        [_contentView addSubview:_fileSizeTipLabel];
        
        self.fileSizeLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        [self refreshValueLabelParameter:_fileSizeLabel];
        _fileSizeLabel.text = @"";
        setFrameWithOrigin(_fileSizeLabel, CGRectGetMaxX(_fileSizeTipLabel.frame) + 10, CGRectGetMinY(_fileSizeTipLabel.frame));
        [_contentView addSubview:_fileSizeLabel];
        
        self.updateTimeLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        [self refreshValueLabelParameter:_updateTimeLabel];
        _updateTimeLabel.text = @"";
        setFrameWithOrigin(_updateTimeLabel, CGRectGetMaxX(_updateTimeTipLabel.frame) + 10, CGRectGetMinY(_updateTimeTipLabel.frame));
        [_contentView addSubview:_updateTimeLabel];
        
        self.whatsNewTipLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _whatsNewTipLabel.text = @"最新动态";
        _whatsNewTipLabel.textColor = [UIColor colorWithHexString:@"333333"];
        _whatsNewTipLabel.backgroundColor = [UIColor clearColor];
        _whatsNewTipLabel.font = [UIFont boldSystemFontOfSize:17.f];
        [_whatsNewTipLabel sizeToFit];
        setFrameWithOrigin(_whatsNewTipLabel, tipLabelLeftPadding, CGRectGetMaxY(_fileSizeTipLabel.frame) + 10);
        [_contentView addSubview:_whatsNewTipLabel];
        
        self.whatsNewLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        [self refreshValueLabelParameter:_whatsNewLabel];
        _whatsNewLabel.numberOfLines = 0;
        [_contentView addSubview:_whatsNewLabel];
    }
    return self;
}

- (void)refreshValueLabelParameter:(UILabel *)label
{
    label.frame = CGRectMake(0, 0, 200, 20);
    label.textAlignment = UITextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:valueLabelFontSize];
    label.textColor = [UIColor colorWithHexString:@"666666"];
}

- (void)refreshTipLabelParameter:(UILabel *)label
{
    label.frame = CGRectMake(0, 0, 60, 20);
    label.textAlignment = UITextAlignmentRight;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:15.f];
    label.textColor = [UIColor colorWithHexString:@"999999"];
}

- (void)setAppInfosModel:(TFAppInfosModel *)model modelIndex:(NSUInteger)row
{
    self.model = model;
    self.listIndex = row;
    
    [_infosView setAppInfosModel:_model modelIndex:_listIndex];
    float iSize = [model.ipaSize longLongValue] / 1024.f / 1024.f;
    _fileSizeLabel.text = [NSString stringWithFormat:@"%.2fM", iSize];
    
    NSString * time = [SSCommon noTimeStringSince1970:[_model.uploadTime doubleValue]];
    _updateTimeLabel.text = time;
    
    _whatsNewLabel.text = model.whatsNew;
    _whatsNewLabel.frame = [self frameForWhatsNewLabel];
    _contentView.contentSize = CGSizeMake(_contentView.frame.size.width, CGRectGetMaxY(_whatsNewLabel.frame));
}

- (void)backButtonClicked
{
    UIViewController * navCon = [SSCommon topViewControllerFor:self];
    if ([navCon isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)navCon) popViewControllerAnimated:YES];
    }
    else {
        [navCon.navigationController popViewControllerAnimated:YES];
    }
}

- (CGRect)frameForWhatsNewLabel
{
    CGRect rect = CGRectMake(tipLabelLeftPadding, CGRectGetMaxY(_whatsNewTipLabel.frame), self.frame.size.width - 2 * tipLabelLeftPadding, 0);
    if (isEmptyString(_model.whatsNew)) {
        return rect;
    }
    else {
        rect.size.height = heightOfContent(_model.whatsNew, rect.size.width, valueLabelFontSize);
        return rect;
    }
}


@end
