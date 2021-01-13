//
//  FHOldSuggestionItemCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/1/3.
//

#import "FHOldSuggestionItemCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "masonry.h"
#import "TTDeviceHelper.h"
#import "NSAttributedString+YYText.h"
#import "YYLabel.h"
#import "UIDevice+BTDAdditions.h"
@interface FHOldSuggestionItemCell ()
@property (weak, nonatomic) UIView *zoneTypeView;
@property (weak, nonatomic) UILabel *zoneTypeLab;
@property (weak, nonatomic) UILabel *titleLab;
@property (weak, nonatomic) UILabel *subTitleLab;
@property (weak, nonatomic) UILabel *regionLab;
@property (weak, nonatomic) UILabel *villageLab;
@property (weak, nonatomic) UILabel *amountLab;

@end

@implementation FHOldSuggestionItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return  self;
}

- (void)createUI {
    [self.zoneTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(14);
        make.left.equalTo(self.contentView).offset(15);
        make.height.mas_offset(18);
    }];
    [self.zoneTypeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.zoneTypeView);
        make.left.equalTo(self.zoneTypeView).offset(6);
        make.right.equalTo(self.zoneTypeView).offset(-6);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.zoneTypeView);
        make.left.equalTo(self.zoneTypeView.mas_right).offset(15); 
    }];
    [self.amountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.zoneTypeView);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.subTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.zoneTypeView);
        make.left.equalTo(self.titleLab.mas_right).offset(4);
        make.right.mas_lessThanOrEqualTo(self.amountLab.mas_left).offset(-15);
    }];
    [self.regionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLab).priorityHigh();
        make.top.equalTo(self.titleLab.mas_bottom).offset(3);
    }];
    [self.villageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.regionLab.mas_right).offset(5).priorityHigh();
        make.right.mas_lessThanOrEqualTo(self.amountLab.mas_left).offset(-6);
        make.top.equalTo(self.titleLab.mas_bottom).offset(3);
    }];
    [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15) ;
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo([UIDevice btd_onePixel]);
    }];
    [self.regionLab setContentCompressionResistancePriority:UILayoutPrioritySceneSizeStayPut forAxis:UILayoutConstraintAxisHorizontal];
    [self.villageLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.subTitleLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.amountLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.amountLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.zoneTypeView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (UIView *)zoneTypeView {
    if (!_zoneTypeView) {
        UIView *zoneTypeView = [[UIView alloc]init];
        zoneTypeView.backgroundColor = [UIColor themeGray7];
        zoneTypeView.layer.cornerRadius = 9;
        zoneTypeView.hidden = YES;
        [self.contentView addSubview:zoneTypeView];
        _zoneTypeView = zoneTypeView;
    }
    return _zoneTypeView;
}

- (UILabel *)zoneTypeLab {
    if (!_zoneTypeLab) {
        UILabel *zoneTypeLab = [[UILabel alloc]init];
        zoneTypeLab.textColor = [UIColor themeGray1];
        zoneTypeLab.font = [UIFont themeFontRegular:12];
        [self.zoneTypeView addSubview:zoneTypeLab];
        _zoneTypeLab = zoneTypeLab;
    }
    return _zoneTypeLab;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *titleLab = [[UILabel alloc]init];
        titleLab.textColor = [UIColor themeGray1];
        titleLab.font = [UIFont themeFontSemibold:16];
        [self.contentView addSubview:titleLab];
        _titleLab = titleLab;
    }
    return _titleLab;
}

- (UILabel *)subTitleLab {
    if (!_subTitleLab) {
        UILabel *subTitleLab = [[UILabel alloc]init];
        subTitleLab.textColor = [UIColor themeGray1];
        subTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:subTitleLab];
        _subTitleLab = subTitleLab;
    }
    return _subTitleLab;
}

- (UILabel *)regionLab {
    if (!_regionLab) {
        UILabel *regionLab = [[UILabel alloc]init];
        regionLab.textColor = [UIColor themeGray3];
        regionLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:regionLab];
        _regionLab = regionLab;
    }
    return _regionLab;
}

- (UILabel *)villageLab {
    if (!_villageLab) {
        UILabel *villageLab = [[UILabel alloc]init];
        villageLab.textColor = [UIColor themeGray3];
        villageLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:villageLab];
        _villageLab = villageLab;
    }
    return _villageLab;
}

- (UILabel *)amountLab {
    if (!_amountLab) {
        UILabel *amountLab = [[UILabel alloc]init];
        amountLab.textColor = [UIColor colorWithHexStr:@"#333333"];
        amountLab.font = [UIFont themeFontRegular:14];
        amountLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:amountLab];
        _amountLab = amountLab;
    }
    return _amountLab;
}

- (UIView *)sepLine{
    if(!_sepLine){
        UIView *sepLine = [[UIView alloc]init];
        _sepLine=sepLine;
        _sepLine.backgroundColor = [UIColor themeGray6];
        [self.contentView addSubview:_sepLine];
    }
    return _sepLine;
}

- (void)setModel:(FHSuggestionResponseItemModel *)model {
    if (model) {
        _model = model;
        if(model.name.length>0){
            NSAttributedString *text1 = [self processHighlightedDefault:model.name textColor:[UIColor themeGray1] fontSize:16.0];
            self.titleLab.attributedText = [self processHighlighted:text1 originText:model.name textColor:[UIColor themeOrange1] fontSize:16.0];
            [self.titleLab sizeToFit];
        }
       
        if (model.recallType.length > 0) {
            self.zoneTypeView.hidden = NO;
        }
        if (model.oldName.length > 0) {
            self.subTitleLab.hidden = NO;
            NSAttributedString *text1 = [self processHighlightedDefault:model.oldName textColor:[UIColor themeGray1] font:[UIFont themeFontRegular:14]];
            self.subTitleLab.attributedText = [self processHighlighted:text1 originText:model.oldName textColor:[UIColor themeOrange1] font:[UIFont themeFontRegular:14]];
        } else {
            self.subTitleLab.hidden = YES;
        }
        self.zoneTypeLab.text = model.recallType;
        CGFloat zoneTypeLabWidth = [model.recallType boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.zoneTypeLab.font} context:nil].size.width;
        [self.zoneTypeView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(zoneTypeLabWidth+12);
        }];
        self.regionLab.text = model.tag;
        self.villageLab.text = model.tag2;
        self.amountLab.text = model.countDisplay;
        
        [self.amountLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            if([model.tag length] > 0 ){
                make.top.equalTo(self.titleLab.mas_bottom).offset(3);
            }else{
                make.centerY.equalTo(self.titleLab);
            }
            make.right.equalTo(self.contentView).offset(-15);
        }];
        
        UILabel *leftLab = [model.oldName length] > 0 ? self.subTitleLab:self.titleLab;
        float margin = [model.oldName length] > 0 ? 1:6;
        
        if(model.isNewStyle){
            self.amountLab.textColor = [UIColor colorWithHexStr:@"#999999"];
            self.zoneTypeView.layer.cornerRadius = 2;
            self.zoneTypeLab.font = [UIFont themeFontRegular:10];
            zoneTypeLabWidth = [model.newtip.content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.zoneTypeLab.font} context:nil].size.width;
            [self.zoneTypeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.zoneTypeView);
                make.width.mas_equalTo(zoneTypeLabWidth).priorityHigh();
                make.left.equalTo(self.zoneTypeView).offset(5);
                make.right.equalTo(self.zoneTypeView).offset(-5);
            }];
            [self.zoneTypeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).offset(14);
                make.left.equalTo(leftLab.mas_right).offset(margin);
                make.right.mas_lessThanOrEqualTo(self.amountLab.mas_right);
                make.height.mas_offset(15);
            }];
            [self.subTitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.zoneTypeView);
                make.left.equalTo(self.titleLab.mas_right).offset(5);
            }];
            [self.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.zoneTypeView);
                make.left.equalTo(self.contentView).offset(15);
            }];
            
            if(model.newtip){
                self.zoneTypeView.backgroundColor = [UIColor colorWithHexStr:model.newtip.backgroundcolor];
                self.zoneTypeLab.textColor = [UIColor colorWithHexStr:model.newtip.textcolor];
                self.zoneTypeLab.text = model.newtip.content;
                self.zoneTypeLab.hidden = NO;
                self.zoneTypeView.hidden = NO;
            }else{
                self.zoneTypeLab.hidden = YES;
                self.zoneTypeView.hidden = YES;
            }
        }
    }
}

- (NSAttributedString *)processHighlightedDefault:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font {
    NSDictionary *attr = @{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
    
    return attrStr;
}

- (NSAttributedString *)processHighlighted:(NSAttributedString *)text originText:(NSString *)originText textColor:(UIColor *)textColor font:(UIFont *)font {
    if (self.highlightedText.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor};
        NSMutableAttributedString * tempAttr = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        
        NSMutableString *string = [NSMutableString stringWithString:self.highlightedText];
        
        //左括号
        NSRange rangeLeft = [string rangeOfString:@"("];
        if (rangeLeft.location != NSNotFound) {
            [string insertString:@"[" atIndex:rangeLeft.location];
            [string insertString:@"]" atIndex:rangeLeft.location + 2];
        }
        
        //右括号
        NSRange rangeRight = [string rangeOfString:@")"];
        if (rangeRight.location != NSNotFound) {
            [string insertString:@"[" atIndex:rangeRight.location];
            [string insertString:@"]" atIndex:rangeRight.location + 2];
        }
        
        //()在正则表达式有特殊意义——子表达式
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@",string] options:NSRegularExpressionCaseInsensitive error:nil];
        
        [regex enumerateMatchesInString:originText options:NSMatchingReportProgress range:NSMakeRange(0, originText.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            [tempAttr addAttributes:attr range:result.range];
        }];
        return tempAttr;
    } else {
        return text;
    }
    return text;
}

// 1、默认
- (NSAttributedString *)processHighlightedDefault:(NSString *)text textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize {
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontSemibold:fontSize],NSForegroundColorAttributeName:textColor};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
    
    return attrStr;
}

// 2、部分 灰色
- (NSAttributedString *)processHighlightedGray:(NSString *)text2 {
    NSString *retStr = [NSString stringWithFormat:@" (%@)",text2];
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:15],NSForegroundColorAttributeName:[UIColor themeGray3]};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:retStr attributes:attr];
    
    return attrStr;
}

// 3、高亮
- (NSAttributedString *)processHighlighted:(NSAttributedString *)text originText:(NSString *)originText textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize {
    if (self.highlightedText.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontSemibold:fontSize],NSForegroundColorAttributeName:textColor};
        NSMutableAttributedString * tempAttr = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        
        NSMutableString *string = [NSMutableString stringWithString:self.highlightedText];
        
        //左括号
        NSRange rangeLeft = [string rangeOfString:@"("];
        if (rangeLeft.location != NSNotFound) {
            [string insertString:@"[" atIndex:rangeLeft.location];
            [string insertString:@"]" atIndex:rangeLeft.location + 2];
        }
        
        //右括号
        NSRange rangeRight = [string rangeOfString:@")"];
        if (rangeRight.location != NSNotFound) {
            [string insertString:@"[" atIndex:rangeRight.location];
            [string insertString:@"]" atIndex:rangeRight.location + 2];
        }
        
        //()在正则表达式有特殊意义——子表达式
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@",string] options:NSRegularExpressionCaseInsensitive error:nil];
        
        [regex enumerateMatchesInString:originText options:NSMatchingReportProgress range:NSMakeRange(0, originText.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            [tempAttr addAttributes:attr range:result.range];
        }];
        return tempAttr;
    } else {
        return text;
    }
    return text;
}
@end
