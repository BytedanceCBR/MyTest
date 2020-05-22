//
//  FHHouseDetailHeaderMoreStateView.m
//  Pods
//
//  Created by bytedance on 2020/5/20.
//

#import "FHHouseDetailHeaderMoreStateView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

@interface FHHouseDetailHeaderMoreStateView ()

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIImageView *stateImageView;

@end

@implementation FHHouseDetailHeaderMoreStateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.stateLabel = [[UILabel alloc] init];
        self.stateLabel.font = [UIFont themeFontRegular:16];
        self.stateLabel.textColor = [UIColor themeGray1];
        self.stateLabel.numberOfLines = 0;
        [self addSubview:self.stateLabel];
        [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.mas_equalTo(16);
        }];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"查看更多"];
        [title addAttributes:[self titleLabelAttributes] range:NSMakeRange(0, title.length)];
        self.stateLabel.attributedText = title.copy;
        
        self.stateImageView = [[UIImageView alloc] init];
        [self addSubview:self.stateImageView];
        [self.stateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.stateLabel.mas_bottom).mas_offset(6);
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerX.mas_equalTo(self);
        }];
        self.stateImageView.image = [UIImage imageNamed:@"house_detail_header_more_icon_left"];
    }
    return self;
}

- (NSDictionary *)titleLabelAttributes {
    NSMutableDictionary *attributes = @{}.mutableCopy;
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 18;
    paragraphStyle.maximumLineHeight = 18;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    return [attributes copy];
}

- (void)setMoreState:(FHHouseDetailHeaderMoreState)moreState {
    if (_moreState == moreState) {
        return;
    }
    _moreState = moreState;
    switch (moreState) {
        case FHHouseDetailHeaderMoreStateBegin: {
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"查看更多"];
            [title addAttributes:[self titleLabelAttributes] range:NSMakeRange(0, title.length)];
            self.stateLabel.attributedText = title.copy;
            
            self.stateImageView.image = [UIImage imageNamed:@"house_detail_header_more_icon_left"];
            break;
        }
        case FHHouseDetailHeaderMoreStateRelease: {
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"释放查看"];
            [title addAttributes:[self titleLabelAttributes] range:NSMakeRange(0, title.length)];
            self.stateLabel.attributedText = title.copy;
            
            self.stateImageView.image = [UIImage imageNamed:@"house_detail_header_more_icon_right"];
            break;
        }
        default:
            break;
    }
}

@end
