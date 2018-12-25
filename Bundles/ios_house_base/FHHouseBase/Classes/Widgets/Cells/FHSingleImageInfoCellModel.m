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
    _tagsAttrStr = [self tagsStringWithModel:houseModel.tags];

}

-(void)setSecondModel:(FHSearchHouseDataItemsModel *)secondModel {
    
    _secondModel = secondModel;
    _houseType = FHHouseTypeSecondHandHouse;
    _houseId = secondModel.hid;
    _tagsAttrStr = [self tagsStringWithModel:secondModel.tags];

}

-(void)setRentModel:(FHHouseRentDataItemsModel *)rentModel {
    
    _rentModel = rentModel;
    _houseType = FHHouseTypeRentHouse;
    _houseId = rentModel.id;
    _tagsAttrStr = [self tagsStringWithModel:rentModel.tags];

    
}

-(void)setNeighborModel:(FHHouseNeighborDataItemsModel *)neighborModel {
    
    _neighborModel = neighborModel;
    _houseType = FHHouseTypeNeighborhood;
    _houseId = neighborModel.id;
    _tagsAttrStr = nil;
}

-(NSAttributedString *)tagsStringWithModel:(NSArray<FHSearchHouseDataItemsTagsModel *> *)tagList {
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    if (tagList.count > 0) {
        
        NSMutableArray *attrTexts = [NSMutableArray array];
        
        [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSearchHouseDataItemsTagsModel *element = obj;
            if (element.content && element.textColor && element.backgroundColor) {
                
                UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor colorWithHexString:@"#f85959"];
                UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:0.08];
                NSAttributedString *attr = [self createTagAttrString:element.content isFirst:idx == 0 textColor:textColor backgroundColor:backgroundColor];
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

-(NSAttributedString *)createTagAttrString:(NSString *)text isFirst:(BOOL)isFirst textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
    
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


@end
