//
//  WDListCellDataModel.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/2.
//

#import "WDListCellDataModel.h"
#import "WDAnswerEntity.h"
#import "WDDefines.h"

@interface WDListCellDataModel ()

@property (nonatomic, assign) WDWendaListCellType cellType;
@property (nonatomic, assign) WDWendaListLayoutType layoutType;

@property (nonatomic, strong) WDAnswerEntity *answerEntity;

@property (nonatomic, assign) NSInteger showLines;
@property (nonatomic, assign) NSInteger maxLines;

@property (nonatomic, copy) NSString *uniqueId;

@property (nonatomic, assign) WDListCellDataModelType dataType;

@end

@implementation WDListCellDataModel

- (instancetype)initWithListCellStructModel:(WDWendaListCellStructModel *)structModel {
    if (self) {
        self.cellType = structModel.cell_type;
        self.layoutType = structModel.layout_type;
        if (self.cellType == WDWendaListCellTypeANSWER) {
            self.answerEntity = [WDAnswerEntity generateAnswerEntityFromAnswerModel:structModel.answer];
            self.uniqueId = self.answerEntity.ansid;
            self.dataType = WDListCellDataModelTypeOnlyCharacter;
            NSUInteger imageCount = self.answerEntity.contentAbstract.thumb_image_list.count;
            NSUInteger videoCount = self.answerEntity.contentAbstract.video_list.count;
            if (videoCount > 0) {
                WDVideoInfoStructModel *videoModel = self.answerEntity.contentAbstract.video_list.firstObject;
                if (videoModel && !isEmptyString(videoModel.video_id)) {
                    self.dataType = WDListCellDataModelTypeLargeVideo;
                }
            } else if (imageCount >0) {
                self.dataType = WDListCellDataModelTypeSingleImage;
                if (imageCount > 1) {
                    self.dataType = WDListCellDataModelTypeMultiImage;
                }
            }
        }
        // 此两项只有cellType == 0 && layoutType == 1时才有效
        self.showLines = structModel.show_lines ? structModel.show_lines.integerValue : 8;
        self.maxLines = structModel.max_lines ? structModel.max_lines.integerValue : 12;
    }
    return self;
}

- (BOOL)hasAnswerEntity {
    if (self.cellType == WDWendaListCellTypeANSWER && self.answerEntity) {
        return YES;
    }
    return NO;
}

@end
