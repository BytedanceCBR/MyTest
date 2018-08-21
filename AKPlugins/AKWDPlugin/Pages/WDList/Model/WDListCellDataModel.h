//
//  WDListCellDataModel.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/2.
//

#import "WDBaseModel.h"
#import "WDApiModel.h"
#import "WDAnswerEntity.h"

/*
 * 1.2 列表页的数据模型“盒子”类：内部包括回答模型，等等
 */

typedef NS_ENUM(NSUInteger, WDListCellDataModelType) {
    WDListCellDataModelTypeOnlyCharacter = 0,
    WDListCellDataModelTypeSingleImage = 1,
    WDListCellDataModelTypeMultiImage = 2,
    WDListCellDataModelTypeLargeVideo = 3,
};

@interface WDListCellDataModel : WDBaseModel

/*
 * 数据源类型和显示样式类型，暂时只支持cellType=0；layoutType=0||1。
 */
@property (nonatomic, assign, readonly) WDWendaListCellType cellType;
@property (nonatomic, assign, readonly) WDWendaListLayoutType layoutType;

@property (nonatomic, strong, readonly) WDAnswerEntity *answerEntity;

@property (nonatomic, assign, readonly) NSInteger showLines;
@property (nonatomic, assign, readonly) NSInteger maxLines;

@property (nonatomic, copy, readonly) NSString *uniqueId;

@property (nonatomic, assign, readonly) WDListCellDataModelType dataType;

@property (nonatomic, assign, readonly) BOOL hasAnswerEntity;

- (instancetype)initWithListCellStructModel:(WDWendaListCellStructModel *)structModel;

@end
