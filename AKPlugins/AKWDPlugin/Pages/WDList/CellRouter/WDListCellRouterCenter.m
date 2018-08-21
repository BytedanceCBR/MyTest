//
//  WDListCellRouterCenter.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import "WDListCellRouterCenter.h"
#import "WDListCellDataModel.h"
#import "WDWendaListCell.h"
#import "WDWendaListLightPureCharacterCell.h"
#import "WDWendaListLightSingleImageCell.h"
#import "WDWendaListLightMultiImageCell.h"
#import "WDWendaListLightLargeVideoCell.h"
#import "WDWendaMoreListCell.h"
#import "WDWendaMoreListLightCell.h"

@implementation WDListCellRouterCenter

+ (instancetype)sharedInstance
{
    static WDListCellRouterCenter *routerCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routerCenter = [[WDListCellRouterCenter alloc] init];
    });
    return routerCenter;
}

- (BOOL)canRecgonizeData:(WDListCellDataModel *)data {
    return (data.cellType == WDWendaListCellTypeANSWER && !isEmptyString(data.uniqueId) && data.answerEntity);
}

- (Class)cellClassFromData:(WDListCellDataModel *)data pageType:(WDWendaListRequestType)pageType {
    if (pageType == WDWendaListRequestTypeNICE) {
        if (data.layoutType == WDWendaListLayoutTypeDEFAULT_ANSWER) {
            return [WDWendaListCell class];
        } else if (data.layoutType == WDWendaListLayoutTypeLIGHT_ANSWER) {
            if (data.dataType == WDListCellDataModelTypeOnlyCharacter) {
                return [WDWendaListLightPureCharacterCell class];
            } else if (data.dataType == WDListCellDataModelTypeSingleImage) {
                return [WDWendaListLightSingleImageCell class];
            } else if (data.dataType == WDListCellDataModelTypeMultiImage) {
                return [WDWendaListLightMultiImageCell class];
            } else if (data.dataType == WDListCellDataModelTypeLargeVideo) {
                return [WDWendaListLightLargeVideoCell class];
            }
        }
    }
    else if (pageType == WDWendaListRequestTypeNORMAL) {
        if (data.layoutType == WDWendaListLayoutTypeDEFAULT_ANSWER) {
            return [WDWendaMoreListCell class];
        } else if (data.layoutType == WDWendaListLayoutTypeLIGHT_ANSWER) {
            return [WDWendaMoreListLightCell class];
        }
    }
    return nil;
}

- (CGFloat)heightForCellLayoutModel:(id <WDListCellLayoutModelBaseProtocol>)cellLayoutModel cellWidth:(CGFloat)cellWidth {
    [cellLayoutModel calculateLayoutIfNeedWithCellWidth:cellWidth];
    return cellLayoutModel.cellCacheHeight;
}

- (UITableViewCell <WDListCellBaseProtocol>*)dequeueTableCellForLayoutModel:(id <WDListCellLayoutModelBaseProtocol>)cellLayoutModel
                                                                  tableView:(UITableView *)tableView
                                                                  indexPath:(NSIndexPath *)indexPath
                                                                  gdExtJson:(NSDictionary *)gdExtJson
                                                                  apiParams:(NSDictionary *)apiParams
                                                                   pageType:(WDWendaListRequestType)pageType {
    Class cellClass = [self cellClassFromData:cellLayoutModel.dataModel pageType:pageType];
    NSString *identifier = NSStringFromClass(cellClass);
    if (isEmptyString(identifier)) {
        return nil;
    }
    UITableViewCell<WDListCellBaseProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier gdExtJson:gdExtJson apiParams:apiParams];
    }
    return cell;
}

@end
