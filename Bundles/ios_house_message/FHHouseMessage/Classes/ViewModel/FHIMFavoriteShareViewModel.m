//
//  FHIMFavoriteShareViewModel.m
//  AKCommentPlugin
//
//  Created by leo on 2019/4/28.
//

#import "FHIMFavoriteShareViewModel.h"
#import "RXCollection.h"
#import <UIKit/UIKit.h>
#import "IMManager.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHNewHouseItemModel.h"
#import "FHHouseListModel.h"
#import "FHDetailBaseModel.h"

@interface FHIMFavoriteShareModel : NSObject
@property (nonatomic, assign) NSInteger houseType;
@property (nonatomic, copy) NSString* houseId;
@property (nonatomic, copy) NSString* cover;
@property (nonatomic, copy) NSString* displayTitle;
@property (nonatomic, copy) NSString* displaySubTitle;
@property (nonatomic, copy) NSString* displayPrice;
@property (nonatomic, copy) NSString* displayPricePerSqm;
@end

@implementation FHIMFavoriteShareModel



@end

@interface FHIMFavoriteShareViewModel ()

@end

@implementation FHIMFavoriteShareViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)onItemSelected:(id)vm {
    [[_pageViewModels rx_filterWithBlock:^BOOL(id each) {
        return ![vm isEqual:each];
    }] enumerateObjectsUsingBlock:^(FHIMFavoriteSharePageViewModel1 * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cleanSelects];
    }];

    self.selectedItems = [_pageViewModels rx_foldInitialValue:[[NSMutableArray alloc] init] block:^id(NSMutableArray* memo, FHIMFavoriteSharePageViewModel1* each) {
        [[each selectedItems] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [memo addObject:obj];
        }];
        return memo;
    }];
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    [self willChangeValueForKey:@"currentPage"];
    _currentPage = currentPage;
    [self didChangeValueForKey:@"currentPage"];
}

-(void)sendSelectedItemToIM {
    NSLog(@"sendSelectedItemToIM: %@ ", self.selectedItems);
    NSArray* shareModels = [_selectedItems rx_mapWithBlock:^id(id each) {
        return [FHIMFavoriteShareViewModel convertCellModelToShareModel:each];
    }];
    [self sendMsg:shareModels toConversaction:_conversactionId];
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

-(void)sendMsg:(NSArray<FHIMFavoriteShareModel*>*)houses toConversaction:(NSString*)conversactionId {
    IMManager *manager = [IMManager shareInstance];
    [houses enumerateObjectsUsingBlock:^(FHIMFavoriteShareModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChatMsg *houseMsg = [[ChatMsg alloc] init];
        houseMsg.contentDic = @{};
        houseMsg.type = ChatMsgTypeHouseCard;

        NSString *houseTag = @"二手房";
        if (obj.houseType == 1) {
            houseTag = @"新房";
        } else if (obj.houseType == 3) {
            houseTag = @"租房";
        }
        NSDictionary *extra = @{
                                KSCHEMA_HOUSE_TAG: houseTag,
                                KSCHEMA_HOUSE_COVER: obj.cover ? : @"",
                                KSCHEMA_HOUSE_ID:obj.houseId ? : @"",
                                KSCHEMA_HOUSE_TYPE:[@(obj.houseType) stringValue],
                                KSCHEMA_HOUSE_TITLE:obj.displayTitle ? : @"",
                                KSCHEMA_HOUSE_DES:obj.displaySubTitle ? : @"",
                                KSCHEMA_HOUSE_PRICE:obj.displayPrice ? : @"",
                                KSCHEMA_HOUSE_AVG_PRICE:obj.displayPricePerSqm ? : @""
                                };
        houseMsg.extraDic = extra;
        [manager.messageService sendMessage:houseMsg ofConversationId:conversactionId];
    }];
}

+(FHIMFavoriteShareModel*)convertCellModelToShareModel:(FHSingleImageInfoCellModel*)model {
    if (model.secondModel != nil) {
        return [self convertSecondHouseToShareModel:model.secondModel];
    } else if (model.rentModel != nil) {
        return [self convertRentHouseToShareModel:model.rentModel];
    } else if (model.houseModel != nil) {
        return [self convertNewHouseModelToShareModel:model.houseModel];
    }
    return nil;
}

+(FHIMFavoriteShareModel*)convertNewHouseModelToShareModel:(FHNewHouseItemModel*)model {
    FHIMFavoriteShareModel* result = [[FHIMFavoriteShareModel alloc] init];
    result.houseId = model.houseId;
    result.houseType = [model.houseType integerValue];
    id<FHDetailPhotoHeaderModelProtocol> image = model.images.firstObject;
    if (image != nil) {
        result.cover = image.url;
    }
    result.displayTitle = model.displayTitle;
    result.displaySubTitle = model.displayDescription;
    result.displayPricePerSqm = model.displayPricePerSqm;
    return result;
}

+(FHIMFavoriteShareModel*)convertSecondHouseToShareModel:(FHSearchHouseDataItemsModel*)model {
    FHIMFavoriteShareModel* result = [[FHIMFavoriteShareModel alloc] init];
    result.houseId = model.hid;
    result.houseType = [model.houseType integerValue];
    id<FHDetailPhotoHeaderModelProtocol> image = model.houseImage.firstObject;
    if (image != nil) {
        result.cover = image.url;
    }
    result.displayTitle = model.displayTitle;
    result.displaySubTitle = model.displaySubtitle;
    result.displayPrice = model.displayPrice;
    result.displayPricePerSqm = model.displayPricePerSqm;
    return result;
}

+(FHIMFavoriteShareModel*)convertRentHouseToShareModel:(FHHouseRentDataItemsModel*)model {
    FHIMFavoriteShareModel* result = [[FHIMFavoriteShareModel alloc] init];
    result.houseId = model.id;
    result.houseType = [model.houseType integerValue];
    id<FHDetailPhotoHeaderModelProtocol> image = model.houseImage.firstObject;
    if (image != nil) {
        result.cover = image.url;
    }
    result.displayTitle = model.title;
    result.displaySubTitle = model.subtitle;
    result.displayPrice = model.pricing;
    return result;
}
@end
