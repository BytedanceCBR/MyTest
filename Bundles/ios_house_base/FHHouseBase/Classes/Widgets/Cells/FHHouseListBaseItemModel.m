//
//  FHHouseListBaseItemModel.m
//  FHHouseBase
//
//  Created by liuyu on 2020/3/8.
//

#import "FHHouseListBaseItemModel.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "YYText.h"

@implementation FHHouseListBaseItemModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        
        @"logPb": @"log_pb",
        @"recommendReasons": @"recommend_reasons",
        @"baseInfo": @"base_info",
        @"displaySubtitle": @"display_subtitle",
        @"neighborhoodInfo": @"neighborhood_info",
        @"displayPrice": @"display_price",
        @"displayBuiltYear": @"display_built_year",
        @"displayTitle": @"display_title",
        @"houseImageTag": @"house_image_tag",
        @"houseTitleTag": @"title_tag",
        @"displayDescription": @"display_description",
        @"displayPricePerSqm": @"display_price_per_sqm",
        @"uploadAt": @"upload_at",
        @"imprId": @"impr_id",
        @"vrInfo": @"vr_info",
        
        @"searchId": @"search_id",
        @"houseImage": @"house_image",
        @"houseType": @"house_type",
        @"houseVideo": @"house_video",
        @"displaySameNeighborhoodTitle": @"display_same_neighborhood_title",
        @"baseInfoMap": @"base_info_map",
        @"coreInfo": @"core_info",
        
        @"externalInfo":@"external_info",
        @"originPrice":@"origin_price",
        @"subscribeInfo": @"subscribe_info",
        @"bottomText": @"bottom_text",
        @"fakeReason": @"fake_reason",
        @"externalInfo": @"external_info",
        @"skyEyeTag": @"sky_eye_tag",
        @"advantageDescription":@"advantage_description",
        
        @"pricePerSqmNum": @"price_per_sqm_num",
        @"pricePerSqmUnit": @"price_per_sqm_unit",
        @"globalPricing":@"global_pricing",
        @"floorpanList":@"floorpan_list",
        @"userStatus":@"user_status",
        
        @"pricingNum": @"pricing_num",
        @"pricingUnit": @"pricing_unit",
        
        @"houseType": @"house_type",
        @"coreInfo": @"core_info",
        
        @"houseImageTag": @"house_image_tag",
        @"houseImage": @"house_image",
        @"bottomText": @"bottom_text",
        @"baseInfo": @"base_info",
        @"coreInfo": @"core_info",
        
        @"gaodeLat": @"gaode_lat",
        @"gaodeLng": @"gaode_lng",
        @"displayStatsInfo": @"display_stats_info",
        @"dealStatus": @"deal_status",
        @"dealOpenUrl": @"deal_open_url",
        @"reasonTags": @"reason_tags",
        @"addrData": @"addr_data",
        
        @"houseid":@"id",
        
        //针对我关注的数据
        @"followId": @"follow_id",
        @"pricePerSqm": @"price_per_sqm",
        @"groupId": @"group_id",
        @"salesInfo": @"sales_info",
        @"desc": @"description",
        
        //针对于消息列表
        @"moreDetail": @"more_detail",
        @"dateStr": @"date_str",
        @"moreLabel": @"more_label",
        
        //针对租房相关
        @"pricingNum": @"pricing_num",
        @"pricingUnit": @"pricing_unit",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
- (void)setTags:(NSArray<FHHouseTagsModel> *)tags {
    _tags = tags;
    if (tags.count >0) {
        //当数组对象只有一个时，表示非新房标签，需要合并
        if (tags.count == 1) {
            FHHouseTagsModel *element = tags[0];
            if (element.content && element.textColor && element.backgroundColor) {
                CGSize textSize = [element.content sizeWithFont: [UIFont themeFontRegular:12] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 14) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.width > [self tagShowMaxWidth]) {
                    NSArray *paramsArrary = [element.content componentsSeparatedByString:@" · "];
                    NSString *resultString ;
                    for (int i = 0; i < paramsArrary.count; i ++) {
                        NSString *tagStr = paramsArrary[i];
                        CGSize tagSize = [resultString sizeWithFont: [UIFont themeFontRegular:12] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 14) lineBreakMode:NSLineBreakByWordWrapping];
                        if (tagSize.width < [self tagShowMaxWidth]) {
                            if (resultString.length >0) {
                                resultString = [NSString stringWithFormat:@"%@ · %@",resultString,tagStr];
                            }else {
                                resultString = tagStr;
                            }
                        }else {
                            NSMutableArray *resultArrary = [[resultString componentsSeparatedByString:@" · "] mutableCopy];
                            [resultArrary removeObjectAtIndex: resultArrary.count -1];
                            resultString = @"";
                            for (NSString *string  in resultArrary) {
                                if (resultString.length >0) {
                                    resultString = [NSString stringWithFormat:@"%@ · %@",resultString,string];
                                }else {
                                    resultString = string;
                                }
                            }
                            break;
                        }
                    }
                    _tagString = [[NSAttributedString alloc]initWithString:resultString attributes:@{ NSFontAttributeName:[UIFont themeFontRegular:12] ,
                                                                                                      NSForegroundColorAttributeName:element.textColor?[UIColor colorWithHexStr:element.textColor]:[UIColor themeOrange1]}];
                }else {
                    _tagString = [[NSAttributedString alloc]initWithString:element.content attributes:@{ NSFontAttributeName:[UIFont themeFontRegular:12] ,
                                                                                                         NSForegroundColorAttributeName:element.textColor?[UIColor colorWithHexStr:element.textColor]:[UIColor themeOrange1]}];
                }
            }else {
                _tagString = [[NSAttributedString alloc]initWithString:element.content attributes:@{ NSFontAttributeName:[UIFont themeFontRegular:12] ,
                                                                                                     NSForegroundColorAttributeName:element.textColor?[UIColor colorWithHexStr:element.textColor]:[UIColor themeOrange1]}];
            }
            ///针对于新房tag计算
        }else {
            _tagString = [[NSMutableAttributedString alloc]init];
            for (int m = 0; m<tags.count; m ++) {
                FHHouseTagsModel *element = (FHHouseTagsModel*)tags[m];
                NSDictionary * attDic = @{ NSFontAttributeName:[UIFont themeFontRegular:12] ,NSForegroundColorAttributeName:element.textColor?[UIColor colorWithHexStr:element.textColor]:[UIColor themeOrange1]
                };
                if (_tagString.length >0) {
                    CGSize size1 = [self getStringRect:_tagString size:CGSizeMake( [self tagShowMaxWidth], 14)];
                    CGSize size2 =   [self getStringRect:[[NSAttributedString alloc]initWithString:element.content attributes:attDic] size:CGSizeMake( [self tagShowMaxWidth], 14)];
                    if (size1.width +size2.width > [self tagShowMaxWidth]) {
                        break;
                    }else {
                        [_tagString appendAttributedString: [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"  "]  attributes:nil]];
                        [_tagString appendAttributedString: [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ ",element.content]  attributes:attDic]];
                        NSRange substringRange = [_tagString.string rangeOfString:element.content];
                        YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor colorWithHexStr:element.backgroundColor] cornerRadius:2];
                        [border setInsets:UIEdgeInsetsMake(0, -4, 0, -4)];
                        [_tagString yy_setTextBackgroundBorder:border range:substringRange];
                    }
                    
                }else {
                    _tagString =  [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ ",element.content]  attributes:attDic];
                    YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor colorWithHexStr:element.backgroundColor] cornerRadius:2];
                    [border setInsets:UIEdgeInsetsMake(0, -4, 0, -4)];
                    NSRange substringRange = [_tagString.string rangeOfString:element.content];
                    [_tagString yy_setTextBackgroundBorder:border range:substringRange];
                    CGSize size = [self getStringRect:_tagString size:CGSizeMake( [self tagShowMaxWidth], 14)];
                    if (size.width > [self tagShowMaxWidth]) {
                        _tagString = @"";
                    }
                }
            }
        }
    }
}

- (CGSize)getStringRect:(NSAttributedString *)aString size:(CGSize )sizes
{
    CGRect strSize = [aString boundingRectWithSize:CGSizeMake(sizes.width, sizes.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return  CGSizeMake(strSize.size.width, strSize.size.height);
}

- (void)setReasonTags:(NSArray<FHHouseTagsModel> *)reasonTags {
    _reasonTags = reasonTags;
    if (reasonTags.count>0) {
        FHHouseTagsModel *element = reasonTags.firstObject;
        if (element.content && element.textColor && element.backgroundColor) {
            UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor themeOrange1];
            UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor whiteColor];
            _recommendReasonStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",element.content ]attributes:@{ NSFontAttributeName:[UIFont themeFontRegular:12] ,
                                                                                                                                            NSForegroundColorAttributeName:element.textColor?[UIColor colorWithHexStr:element.textColor]:[UIColor themeOrange1]}];
        }
    }
}

- (CGFloat)tagShowMaxWidth {
    //屏幕宽度-视图左右间距-mainImage-mainImageLeftMargin-rightPriceWidth-rightPriceMargin
    return [UIScreen mainScreen].bounds.size.width - 30 - 85 - 12 - 90 - 12;
}
- (NSString *)displayPrice {
    if (_houseType == FHHouseTypeRentHouse) {
        return _pricing.length>0?_pricing:_price;
    }else if (_houseType == FHHouseTypeNeighborhood){
        return _pricePerSqm;
    }else {
        return _displayPrice.length>0?_displayPrice:_price;
    }
}


- (NSString *)displaySubtitle {
    if (_houseType == FHHouseTypeRentHouse) {
        return _subtitle.length>0?_subtitle:_desc;
    }else if(_houseType == FHHouseTypeNewHouse){
        return _displayDescription.length>0?_displayDescription:_desc;;
    }else {
        return _displaySubtitle.length>0?_displaySubtitle:_desc;
    }
}

- (NSString *)displayPricePerSqm {
    if (_houseType == FHHouseTypeRentHouse || _houseType == FHHouseTypeNeighborhood) {
        return @" ";
    }else {
        return _displayPricePerSqm.length>0?_displayPricePerSqm:_pricePerSqm;
    }
}

- (NSString *)houseid {
    return _houseid.length>0?_houseid:_followId;
}

- (NSArray *)houseImage {
    return _houseImage.count>0?_houseImage:_images;
}
@end

@implementation FHHouseListDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"refreshTip": @"refresh_tip",
        @"redirectTips": @"redirect_tips",
        @"searchId": @"search_id",
        @"minCursor": @"min_cursor",
        @"mapFindHouseOpenUrl": @"map_find_house_open_url",
        @"houseListOpenUrl": @"house_list_open_url",
        @"recommendSearchModel": @"recommend_search",
        @"subscribeInfo": @"subscribe_info",
        @"externalSite": @"external_site",
        @"agencyInfo": @"agency_info",
        @"topTip":@"top_tip",
        @"bottomTip":@"bottom_tip",
        @"followItems": @"follow_items",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation  FHListResultHouseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
