//
//  FHSingleImageInfoCellModel.m
//  FHHouseBase
//
//  Created by 张静 on 2018/12/25.
//

#import "FHSingleImageInfoCellModel.h"
#import "YYTextLayout.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "YYText.h"

@interface FHSingleImageInfoCellModel ()

@property (nonatomic, strong , nullable, readwrite) NSAttributedString *tagsAttrStr;
@property (nonatomic, strong , nullable, readwrite) NSAttributedString *originPriceAttrStr;

@property (nonatomic, strong) UILabel *majorTitle;

@end

@implementation FHSingleImageInfoCellModel


//-(instancetype)initWithHouseModel {
//    
//    self = [self init];
//    if (self) {
//        
//        
//    }
//    
//    return self;
//}

-(void)setHouseModel:(FHNewHouseItemModel *)houseModel {
    
    _houseModel = houseModel;
    _houseType = FHHouseTypeNewHouse;
    _houseId = houseModel.houseId;
    _tagsAttrStr = [self.class tagsStringWithTagList:houseModel.tags];
    _titleSize = [self titleSizeWithTagList:houseModel.tags titleStr:houseModel.displayTitle];
    _originPriceAttrStr = nil;

}

-(void)setSecondModel:(FHSearchHouseDataItemsModel *)secondModel {
    
    _secondModel = secondModel;
    _houseType = FHHouseTypeSecondHandHouse;
    _houseId = secondModel.hid;
    _tagsAttrStr = [self.class tagsStringWithTagList:secondModel.tags];
    _titleSize = [self titleSizeWithTagList:secondModel.tags titleStr:secondModel.displayTitle];
    _originPriceAttrStr = [self originPriceAttr:secondModel.originPrice];

}

-(void)setRentModel:(FHHouseRentDataItemsModel *)rentModel {
    
    _rentModel = rentModel;
    _houseType = FHHouseTypeRentHouse;
    _houseId = rentModel.id;
    _tagsAttrStr = [self.class tagsStringWithTagList:rentModel.tags];
    _titleSize = [self titleSizeWithTagList:rentModel.tags titleStr:rentModel.title];
    _originPriceAttrStr = nil;

}

-(void)setNeighborModel:(FHHouseNeighborDataItemsModel *)neighborModel {
    
    _neighborModel = neighborModel;
    _houseType = FHHouseTypeNeighborhood;
    _houseId = neighborModel.id;
    _tagsAttrStr = nil;
    _titleSize = [self titleSizeWithTagList:nil titleStr:neighborModel.displayTitle];
    _originPriceAttrStr = nil;

}

#pragma mark - log
-(NSString *)imprId {
    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return self.houseModel.imprId;
            break;
        case FHHouseTypeSecondHandHouse:
            return self.secondModel.imprId;
            break;
        case FHHouseTypeRentHouse:
            return self.rentModel.imprId;
            break;
        case FHHouseTypeNeighborhood:
            return self.neighborModel.imprId;
            break;
        default:
            return @"be_null";
            break;
    }
}
-(NSString *)groupId {
    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return self.houseModel.houseId;
            break;
        case FHHouseTypeSecondHandHouse:
            return self.secondModel.hid;
            break;
        case FHHouseTypeRentHouse:
            return self.rentModel.id;
            break;
        case FHHouseTypeNeighborhood:
            return self.neighborModel.id;
            break;
        default:
            return @"be_null";
            break;
    }
}
-(nullable NSDictionary *)logPb {
    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return self.houseModel.logPb;
            break;
        case FHHouseTypeSecondHandHouse:
            return self.secondModel.logPb;
            break;
        case FHHouseTypeRentHouse:
            return self.rentModel.logPb;
            break;
        case FHHouseTypeNeighborhood:
            return self.neighborModel.logPb;
            break;
        default:
            return nil;
            break;
    }
}




#pragma UI处理
-(NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray3] range:NSMakeRange(0, originPrice.length)];
    return attri;
}




-(CGSize)titleSizeWithTagList:(NSArray<FHHouseTagsModel *> *)tagList titleStr:(NSString *)titleStr {
    
    if (tagList.count < 1) {
        
        self.majorTitle.numberOfLines = 2;
    }else {
        self.majorTitle.numberOfLines = 1;
    }
    self.majorTitle.text = titleStr;
    CGSize fitSize = [self.majorTitle sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width * ([UIScreen mainScreen].bounds.size.width > 376 ? 0.61 : [UIScreen mainScreen].bounds.size.width > 321 ? 0.56 : 0.48), 0)];
    return fitSize;

}


+(NSAttributedString *)tagsStringWithTagList:(NSArray<FHHouseTagsModel *> *)tagList {
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    if (tagList.count > 0) {
        
        NSMutableArray *attrTexts = [NSMutableArray array];
        
        [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHHouseTagsModel *element = obj;
            if (element.content && element.textColor && element.backgroundColor) {
                
                UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor colorWithHexString:@"#f85959"];
                UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:0.08];
                NSAttributedString *attr = [self.class createTagAttrString:element.content isFirst:idx == 0 textColor:textColor backgroundColor:backgroundColor];
                [attrTexts addObject:attr];
            }
        }];
        
        __block CGFloat height = 0;
        [attrTexts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSAttributedString *attr = obj;
            [text appendAttributedString:attr];
            
            YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 170, CGFLOAT_MAX) text:text];
            CGFloat lineHeight = tagLayout.textBoundingSize.height;
            if (lineHeight > height) {
                
                if (idx != 0) {
                    [text deleteCharactersInRange:NSMakeRange(text.length - attr.length, attr.length)];
                }
                if (idx == 0) {
                    height = lineHeight;
                }
            }
        }];
        
    }
    
    return text;
}

+ (NSString *)cutStringFromString:(NSString *)string
{
    if (string) {
        NSArray *paramsArrary = [string componentsSeparatedByString:@" · "];
        NSMutableString * resultString = [NSMutableString new];
        
        for (NSInteger i = 0; i < paramsArrary.count - 1; i ++) {
            [resultString appendFormat:paramsArrary[i]];
            if (i != paramsArrary.count - 2) {
                [resultString appendString:@" · "];
            }
        }
        return resultString;
    }else
    {
        return @"";
    }
}

+(NSAttributedString *)tagsStringSmallImageWithTagList:(NSArray<FHHouseTagsModel *> *)tagList
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    if (tagList.count > 0) {
        
        NSMutableArray *attrTexts = [NSMutableArray array];
        
        [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHHouseTagsModel *element = obj;
            if (element.content && element.textColor && element.backgroundColor) {
                
                NSMutableString *reulstString = element.content;
                if (tagList.count > 1) {
                    if (reulstString.length * 10 > ([UIScreen mainScreen].bounds.size.width  - 40 - 72 - 90)) {
                        
                        NSArray *paramsArrary = [element.content componentsSeparatedByString:@" · "];
                        
                        for (NSInteger i = 0; i < paramsArrary.count; i++) {
                            reulstString = [self cutStringFromString:reulstString];
                            
                            if (reulstString.length * 8 < ([UIScreen mainScreen].bounds.size.width  - 40 - 72 - 90 - 10))
                            {
                                break;
                            }
                        }
                    }
                }else
                {
                    reulstString = element.content;
                }
          
                UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor themeRed4];
                UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor whiteColor];
                NSAttributedString *attr = [self.class createSmallTagAttrString:reulstString isFirst:idx == 0 textColor:textColor backgroundColor:backgroundColor];
                [attrTexts addObject:attr];
            }
        }];
        
        __block CGFloat height = 0;
        [attrTexts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSAttributedString *attr = obj;
            [text appendAttributedString:attr];
            
            YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width  - 40 - 72 - 90, CGFLOAT_MAX) text:text];
            CGFloat lineHeight = tagLayout.textBoundingSize.height;
            if (lineHeight > height) {
                
                if (idx != 0) {
                    [text deleteCharactersInRange:NSMakeRange(text.length - attr.length, attr.length)];
                }
                if (idx == 0) {
                    height = lineHeight;
                }
            }
        }];
        
    }
    
    return text;
}

+(NSAttributedString *)createTagAttrString:(NSString *)text isFirst:(BOOL)isFirst textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
    
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"  %@  ",text]];
    attributeText.yy_font = [UIFont themeFontRegular:10];
    attributeText.yy_color = textColor;
    NSRange substringRange = [attributeText.string rangeOfString:text];
    [attributeText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:substringRange];
    YYTextBorder *border = [YYTextBorder borderWithFillColor:backgroundColor cornerRadius:2];
    [border setInsets:UIEdgeInsetsMake(0, -4, 0, -4)];
    
    [attributeText yy_setTextBackgroundBorder:border range:substringRange];
    return attributeText;
    
}

+(NSAttributedString *)createSmallTagAttrString:(NSString *)text isFirst:(BOOL)isFirst textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
    
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",text]];
    attributeText.yy_font = [UIFont themeFontRegular:12];
    attributeText.yy_color = textColor;
    NSRange substringRange = [attributeText.string rangeOfString:text];
    [attributeText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:substringRange];
    YYTextBorder *border = [YYTextBorder borderWithFillColor:backgroundColor cornerRadius:2];
    
    [attributeText yy_setTextBackgroundBorder:border range:substringRange];
    return attributeText;
}

-(UILabel *)majorTitle {
    
    if (!_majorTitle) {
        
        _majorTitle = [[UILabel alloc]init];
        _majorTitle.font = [UIFont themeFontRegular:16];
        _majorTitle.textColor = [UIColor themeGray1];
    }
    return _majorTitle;
}

+ (FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {
    FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
    
    if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
        cellModel.secondModel = obj;
        
    }else if ([obj isKindOfClass:[FHNewHouseItemModel class]]) {
        
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
        cellModel.houseModel = obj;
        
    }else if ([obj isKindOfClass:[FHHouseRentDataItemsModel class]]) {
        
        FHHouseRentDataItemsModel *item = (FHHouseRentDataItemsModel *)obj;
        cellModel.rentModel = obj;
        
    } else if ([obj isKindOfClass:[FHHouseNeighborDataItemsModel class]]) {
        
        FHHouseNeighborDataItemsModel *item = (FHHouseNeighborDataItemsModel *)obj;
        cellModel.neighborModel = obj;
        
    }
    return cellModel;
}

@end
