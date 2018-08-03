//
//  AWEVideoReportReasonCellViewController.m
//  Pods
//
//  Created by 01 on 17/5/7.
//
//
#import "AWEVideoPlayReporReasonCell.h"
#import <Masonry/Masonry.h>

@interface AWEVideoPlayReporReasonCell()

@property (nonatomic, strong)SSThemedLabel *reportReasonLabel;
@property (nonatomic, strong)SSThemedImageView *selectedImageView;
@property (nonatomic, strong)SSThemedView *sepline;

@end

@implementation AWEVideoPlayReporReasonCell

+ (NSInteger)cellHeight
{
    return 44;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _reportReasonLabel = [[SSThemedLabel alloc] init];
        _reportReasonLabel.textColorThemeKey = kColorText1;
        _reportReasonLabel.font = [UIFont systemFontOfSize:16.0f];
        _reportReasonLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_reportReasonLabel];
        
        _selectedImageView = [[SSThemedImageView alloc] init];
        _selectedImageView.imageName = @"hts_vp_hookicon_location";
        
        [self.contentView addSubview:_selectedImageView];
        
        _sepline = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _sepline.backgroundColorThemeKey = kColorLine1;
        [self.contentView addSubview:_sepline];
        
        [_reportReasonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@32);
            make.top.equalTo(@10.5);
            make.height.equalTo(@22.5);
        }];
        
        [_selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(@12);
            make.centerY.equalTo(_reportReasonLabel);
            make.right.equalTo(@(-32));
            make.left.greaterThanOrEqualTo(_reportReasonLabel.mas_right).offset(10);
        }];
        
        [_sepline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(32);
            make.right.equalTo(self.contentView).offset(-32);
            make.height.equalTo(@(0.5));
            make.bottom.equalTo(self.contentView);
        }];
        
    }
    return self;
}

- (void)setTitleText:(NSString *)text
{
    _reportReasonLabel.text = text;
}

- (void)hideCellSepline:(BOOL)hidden
{
    _sepline.hidden = hidden;
}

- (void)setSelectedStatus:(BOOL)selected
{
    _selectedImageView.hidden = !selected;
    _reportReasonLabel.textColorThemeKey = selected ? kColorText3 : kColorText1;
}

@end

