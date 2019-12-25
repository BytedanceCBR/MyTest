//
//  TTFeedDislikeOptionCell.m
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/13.
//

#import "TTFeedDislikeOptionCell.h"
#import "UIViewAdditions.h"
#import "FHFeedOperationWord.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTFeedDislikeConfig.h"
#import "FHFeedOperationView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface TTFeedDislikeOptionCell ()

@property (nonatomic, strong) FHFeedOperationOption *option;

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *subTitleLabel;
@property (nonatomic, strong) UIImageView *accessor;

@end

@implementation TTFeedDislikeOptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifiers {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifiers]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _iconImageView = [UIImageView new];
        [self addSubview:_iconImageView];
        
        _titleLabel = ({
            SSThemedLabel *v = [SSThemedLabel new];
            v.font = [UIFont themeFontRegular:16];
            v.textColor = [UIColor themeGray1];
            v;
        });
        [self addSubview:_titleLabel];
        
        _subTitleLabel = ({
            SSThemedLabel *v = [SSThemedLabel new];
            v.font = [UIFont themeFontRegular:12.0];
            v.textColor = [UIColor themeGray3];
            v;
        });
        [self addSubview:_subTitleLabel];
        
        _accessor = ({
            UIImageView *v = [UIImageView new];
            v.image = [UIImage imageNamed:@"fh_ugc_arrow_right"];
            v;
        });
        [self addSubview:_accessor];
        
        _separator = ({
            SSThemedView *v = [SSThemedView new];
            v.backgroundColor = [UIColor themeGray6];
            v;
        });
        [self addSubview:_separator];
        
        self.backgroundView = ({
            SSThemedView *v = [[SSThemedView alloc] init];
            v.backgroundColor = [UIColor whiteColor];
            v;
        });
        
        [self addSubview:_separator];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL enableSubTitle = !!self.subTitleLabel.text.length;
    BOOL enableArrow = (self.option.type == FHFeedOperationOptionTypeReport);
    CGFloat padding = 20.0;
    CGFloat offsetTop = 24.0;
    
    self.iconImageView.size = CGSizeMake(18.0, 18.0);
    self.iconImageView.left = padding;
    self.iconImageView.centerY = self.height / 2.0;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.left = self.iconImageView.right + 20.0;
    if(enableSubTitle){
        self.titleLabel.top = 15.0;
    }else{
        self.titleLabel.centerY = self.iconImageView.centerY;
    }
    self.titleLabel.width = self.width - self.titleLabel.left - padding;
    self.titleLabel.height = 22.0;
    offsetTop = self.titleLabel.bottom;
    
    if (enableSubTitle) {
        [self.subTitleLabel sizeToFit];
        self.subTitleLabel.top = offsetTop;
        self.subTitleLabel.left = self.titleLabel.left;
        self.subTitleLabel.width = self.width - self.subTitleLabel.left - padding;
        self.subTitleLabel.height = 17.0;
        offsetTop = self.subTitleLabel.bottom;
    }
    
    self.accessor.hidden = !enableArrow;
    if (enableArrow) {
        self.accessor.size = CGSizeMake(6.0, 10.0);
        self.accessor.right = self.width - (padding - 1.0);
        self.accessor.centerY = self.height / 2.0;
    }
    
    self.separator.height = [TTDeviceHelper ssOnePixel];
    self.separator.left = padding;
    self.separator.bottom = self.height;
    self.separator.width = self.width - self.separator.left - padding;
}

- (void)configWithOption:(FHFeedOperationOption *)option showSeparator:(BOOL)showSeparator {
    self.option = option;
    
    UIImage *icon = nil;
    
    switch (option.type) {
        case FHFeedOperationOptionTypeReport: {
            icon = [UIImage imageNamed:@"fh_ugc_report"];
        }
            break;
        case FHFeedOperationOptionTypeDelete: {
            icon = [UIImage imageNamed:@"fh_ugc_delete"];
        }
            break;
        case FHFeedOperationOptionTypeTop: {
            icon = [UIImage imageNamed:@"fh_ugc_top"];
        }
            break;
        case FHFeedOperationOptionTypeCancelTop: {
            icon = [UIImage imageNamed:@"fh_ugc_top"];
        }
            break;
        case FHFeedOperationOptionTypeGood: {
            icon = [UIImage imageNamed:@"fh_ugc_good"];
        }
            break;
        case FHFeedOperationOptionTypeCancelGood: {
            icon = [UIImage imageNamed:@"fh_ugc_good"];
        }
            break;
        case FHFeedOperationOptionTypeSelfLook: {
            icon = [UIImage imageNamed:@"fh_ugc_self_look"];
        }
            break;
        case FHFeedOperationOptionTypeEdit: {
            icon = [UIImage imageNamed:@"fh_ugc_feed_edit"];
        }
        case FHFeedOperationOptionTypeEditList: {
            icon = [UIImage imageNamed:@"fh_ugc_feed_edit_history"];
        }
            break;
    }
    
    self.iconImageView.image = icon;
    self.titleLabel.text = option.title;
    self.subTitleLabel.text = option.subTitle;
    self.separator.hidden = !showSeparator;
    
    [self setNeedsLayout];
}

@end
