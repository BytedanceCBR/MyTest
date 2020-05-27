//
//  FHHomeHouseModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/25.
//

#import "FHHomeHouseModel.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "YYText.h"

@implementation FHHomeHouseImageTagModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"backgroundColor": @"background_color",
        @"idx": @"id",
        @"textColor": @"text_color",
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

@implementation FHHomeHouseVRModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"hasVr": @"has_vr",
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

//for implementation
@implementation  FHHomeHouseDataItemsFloorpanListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"userStatus": @"user_status",
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


@implementation  FHHomeHouseDataItemsGlobalPricingModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"userStatus": @"user_status",
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


@implementation  FHHomeHouseDataItemsCoreInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"courtAddress": @"court_address",
        @"saleStatus": @"sale_status",
        @"properyType": @"propery_type",
        @"pricingPerSqm": @"pricing_per_sqm",
        @"gaodeLng": @"gaode_lng",
        @"gaodeLat": @"gaode_lat",
        @"constructionOpendate": @"construction_opendate",
        @"aliasName": @"alias_name",
        @"gaodeImageUrl": @"gaode_image_url",
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


@implementation  FHHomeHouseDataItemsGlobalPricingListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"agencyName": @"agency_name",
        @"fromUrl": @"from_url",
        @"pricingPerSqm": @"pricing_per_sqm",
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


@implementation FHHomeHouseAdvantageTagModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"textColor": @"text_color",
        @"backgroundColor": @"background_color",
        @"borderColor": @"border_color",
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


@implementation  FHHomeHouseDataItemsTimelineListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"createdTime": @"created_time",
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


@implementation  FHHomeHouseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


//@implementation  FHHomeHouseDataItemsTagsModel
//
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"backgroundColor": @"background_color",
//                           @"textColor": @"text_color",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//
//@end


@implementation  FHHomeHouseDataItemsFloorpanListListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"logPb": @"log_pb",
        @"roomCount": @"room_count",
        @"pricingPerSqm": @"pricing_per_sqm",
        @"saleStatus": @"sale_status",
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


//@implementation  FHHomeHouseDataItemsImagesModel
//
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"urlList": @"url_list",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//
//@end


@implementation  FHHomeHouseDataItemsFloorpanListListImagesModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"urlList": @"url_list",
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


@implementation  FHHomeHouseDataItemsCommentListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"createdTime": @"created_time",
        @"fromUrl": @"from_url",
        @"userName": @"user_name",
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


@implementation  FHHomeHouseDataItemsContactModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"noticeDesc": @"notice_desc",
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


@implementation  FHHomeHouseDataItemsCoreInfoSaleStatusModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"backgroundColor": @"background_color",
        @"textColor": @"text_color",
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


@implementation  FHHomeHouseDataItemsFloorpanListListSaleStatusModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"backgroundColor": @"background_color",
        @"textColor": @"text_color",
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


@implementation  FHHomeHouseDataItemsTimelineModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"userStatus": @"user_status",
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

@implementation FHHomeHouseDataItemsDislikeInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"mutualExclusiveIds": @"mutual_exclusive_ids",
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

@implementation  FHHomeHouseDataItemsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"buildingSquareMeter": @"building_square_meter",
        @"idx": @"id",
        @"userStatus": @"user_status",
        @"globalPricing": @"global_pricing",
        @"logPb": @"log_pb",
        @"displayTitle": @"display_title",
        @"uploadAt": @"upload_at",
        @"displayDescription": @"display_description",
        @"searchId": @"search_id",
        @"displaySubtitle": @"display_subtitle",
        @"displaySameneighborhoodTitle": @"display_same_neighborhood_title",
        @"displayPriceColor":@"display_price_color",
        @"pricing": @"pricing",
        @"subtitle": @"subtitle",
        @"displayBuiltYear": @"display_built_year",
        @"displayPrice": @"display_price",
        @"displayPricePerSqm": @"display_price_per_sqm",
        @"imprId": @"impr_id",
        @"vrInfo": @"vr_info",
        @"advantageDescription":@"advantage_description",
        @"cellStyle": @"cell_style",
        @"houseImageTag": @"house_image_tag",
        @"floorpanList": @"floorpan_list",
        @"houseType": @"house_type",
        @"houseVideo": @"house_video",
        @"coreInfo": @"core_info",
        @"baseInfo": @"base_info",
        @"houseImage": @"house_image",
        @"tagImage": @"tag_image",
        @"originPrice": @"origin_price",
        @"pricingNum":@"pricing_num",
        @"pricingUnit":@"pricing_unit",
        @"pricePerSqmNum":@"price_per_sqm_num",
        @"pricePerSqmUnit":@"price_per_sqm_unit",
        @"dislikeInfo": @"dislike_info",
        @"titleTag": @"title_tag",
        @"reasonTags": @"reason_tags",
        @"addrData": @"addr_data",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

-(instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    self = [super initWithDictionary:dict error:err];
    if (self) {
        id coreInfo = dict[@"core_info"];
        if ([coreInfo isKindOfClass:[NSArray class]]) {
            NSMutableArray *coreInfoList = [NSMutableArray new];
            for (NSDictionary *info in (NSArray *)coreInfo) {
                FHHouseCoreInfoModel *infoModel = [[FHHouseCoreInfoModel alloc] initWithDictionary:info error:nil];
                if (infoModel) {
                    [coreInfoList addObject:infoModel];
                }
            }
            self.coreInfoList = coreInfoList;
        }
    }
    return self;
}
- (void)setTags:(NSArray<FHHouseTagsModel> *)tags {
    _tags = tags;
    if (tags.count >0) {
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
                    [_tagString appendAttributedString: [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" "]  attributes:nil]];
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

- (CGSize)getStringRect:(NSAttributedString *)aString size:(CGSize )sizes
{
    CGRect strSize = [aString boundingRectWithSize:CGSizeMake(sizes.width, sizes.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return  CGSizeMake(strSize.size.width, strSize.size.height);
}

- (CGFloat)tagShowMaxWidth {
    //屏幕宽度-视图左右间距-mainImage-mainImageLeftMargin-rightMargin
    return [UIScreen mainScreen].bounds.size.width - 30 - 85 - 12  - 50;
}
@end


@implementation  FHHomeHouseDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"refreshTip": @"refresh_tip",
        @"searchId": @"search_id",
        @"triggerTime":@"trigger_time"
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


@implementation  FHHomeHouseDataItemsCommentModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"userStatus": @"user_status",
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


@implementation  FHHomeHouseDataItemsUserStatusModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"pricingSubStauts": @"pricing_sub_stauts",
        @"courtSubStatus": @"court_sub_status",
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

@implementation FHHomeHouseDataItemsTitleTagModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"backgroundColor": @"background_color",
        @"textColor": @"text_color",
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
