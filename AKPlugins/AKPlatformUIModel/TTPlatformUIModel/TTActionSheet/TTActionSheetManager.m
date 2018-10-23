//
//  TTActionSheetManager.m
//  Article
//
//  Created by zhaoqin on 8/29/16.
//
//

#import "TTActionSheetManager.h"
#import "TTActionSheetModel.h"
#import "TTActionSheetCellModel.h"
#import "MJExtension.h"

@implementation TTActionSheetManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _criticismInput = @"";
    }
    return self;
}

- (void)addActionSheetMode:(TTActionSheetModel *)model {
    switch (model.type) {
        case TTActionSheetTypeDislike: {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dictionary in model.dataArray) {
                TTActionSheetCellModel *cellModel = [[TTActionSheetCellModel alloc] init];
                cellModel.identifier = dictionary[@"id"];
                cellModel.text = dictionary[@"name"];
                cellModel.isSelected = NO;
                cellModel.source = TTActionSheetTypeDislike;
                [mutableArray addObject:cellModel];
            }
            model.dataArray = mutableArray;
            _dislikeModel = model;
        }
            break;
        case TTActionSheetTypeReport: {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dictionary in model.dataArray) {
                TTActionSheetCellModel *cellModel = [[TTActionSheetCellModel alloc] init];
                cellModel.identifier = dictionary[@"type"];
                cellModel.text = dictionary[@"text"];
                cellModel.isSelected = NO;
                cellModel.source = TTActionSheetTypeReport;
                [mutableArray addObject:cellModel];
            }
            if ([self.adID integerValue] == 0) {
                [mutableArray removeLastObject];
            }
            model.dataArray = mutableArray;
            _reportModel = model;
        }
            break;
    }
}

- (void)resetManager {
    self.dislikeModel = nil;
    self.reportModel = nil;
    self.criticismInput = @"";
}

@end
