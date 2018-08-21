
//
//  TTVisitorDateCell.m
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTVisitorDateCell.h"
#import "TTProfileThemeConstants.h"



@interface TTVisitorDateCell ()
@property (nonatomic, strong) SSThemedLabel *dateLabel;
@end
@implementation TTVisitorDateCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        [self.contentView addSubview:self.dateLabel];
        
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset([TTDeviceUIUtils tt_padding:kTTProfileInsetLeft]);
            make.right.equalTo(self.textContainerView);
            make.top.equalTo(self.contentView.mas_top).with.offset([TTDeviceUIUtils tt_padding:20.f/2]);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _dateLabel.text = nil;
}

- (void)reloadWithVisitorModel:(TTVisitorFormattedModelItem *)aModel {
    if (!aModel) return;
    [super reloadWithVisitorModel:aModel];
    
    self.dateLabel.text = [aModel formattedDateLabel];
    [self.dateLabel sizeToFit];
}

#pragma mark - properties 

- (SSThemedLabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[SSThemedLabel alloc] init];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _dateLabel.textColorThemeKey = kColorText1;
        _dateLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:24.f/2]];
    }
    return _dateLabel;
}

+ (CGFloat)cellHeight {
    return [TTDeviceUIUtils tt_padding:192.f/2];
}
@end
