//
//  FHPostUGCSelectedGroupHistoryView.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/8/11.
//

#import "FHPostUGCSelectedGroupHistoryView.h"
#import "Masonry.h"
#import <TTThemed/UIColor+TTThemeExtension.h>

@implementation FHPostUGCSelectedGroupHistory

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.historyInfos forKey:@"historyInfos"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.historyInfos = [aDecoder decodeObjectForKey:@"historyInfos"];
    }
    return self;
}
@end

@implementation FHPostUGCSelectedGroupModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.socialGroupId forKey:@"socialGroupId"];
    [aCoder encodeObject:self.socialGroupName forKey:@"socialGroupName"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.socialGroupId = [aDecoder decodeObjectForKey:@"socialGroupId"];
        self.socialGroupName = [aDecoder decodeObjectForKey:@"socialGroupName"];
    }
    return self;
}
@end

@interface FHPostUGCSelectedGroupHistoryView()
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *historyButton;
@property (nonatomic, weak) id<FHPostUGCSelectedGroupHistoryViewDelegate> delegate;
@end

@implementation FHPostUGCSelectedGroupHistoryView

-(instancetype)initWithFrame:(CGRect)frame
                    delegate:(id<FHPostUGCSelectedGroupHistoryViewDelegate>) delegate
                historyModel:(FHPostUGCSelectedGroupModel *)model {
    if(self = [super initWithFrame:frame]) {
        
        _model = model;
        self.delegate = delegate;
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.historyButton];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.bottom.equalTo(self);
        }];
        
        [self.historyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel.mas_centerY);
            make.left.equalTo(self.titleLabel.mas_right).offset(10);
            make.right.lessThanOrEqualTo(self).offset(-20);
        }];
    }
    return self;
}

-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"上次选择:";
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor tt_themedColorForKey:@"grey1"];
    }
    return _titleLabel;
}

-(UIButton *)historyButton {
    if(!_historyButton) {
        _historyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_historyButton setTitle: self.model.socialGroupName forState:UIControlStateNormal];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_historyButton setTitleColor:[UIColor tt_themedColorForKey:@"grey1"] forState:UIWindowLevelNormal];
        _historyButton.backgroundColor = [UIColor tt_themedColorForKey:@"grey7"];
        _historyButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        _historyButton.layer.cornerRadius = 4;
        
        [_historyButton addTarget:self action:@selector(historyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _historyButton;
}

-(void)historyButtonPressed: (UIButton *)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedHistoryGroup:)]) {
        [self.delegate selectedHistoryGroup:self.model];
    }
}
@end
