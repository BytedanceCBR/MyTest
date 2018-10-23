//
//  TTIconLabel+TTImageInfosModel.m
//  Article
//
//  Created by lizhuoli on 17/3/22.
//
//

#import "TTIconLabel+TTImageInfosModel.h"

@implementation TTIconLabel (TTImageInfosModel)

- (void)addIconWithImageInfosModel:(TTImageInfosModel *)model
{
    if (!model || ![model isKindOfClass:[TTImageInfosModel class]]) {
        return;
    }
    
    NSString *urlString = [model urlStringAtIndex:0];
    if (isEmptyString(urlString)) {
        return;
    }
    
    CGSize size = CGSizeMake(model.width, model.height);
    
    [self addIconWithDayIconURL:[NSURL URLWithString:urlString] nightIconURL:nil size:size];
}

- (void)addIconsWithImageInfosModels:(NSArray<TTImageInfosModel *> *)models
{
    if (SSIsEmptyArray(models)) {
        return;
    }
    
    [models enumerateObjectsUsingBlock:^(TTImageInfosModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model isKindOfClass:[TTImageInfosModel class]]) {
            NSString *urlString = [model urlStringAtIndex:0];
            if (!isEmptyString(urlString)) {
                CGSize size = CGSizeMake(model.width, model.height);
                [self addIconWithDayIconURL:[NSURL URLWithString:urlString] nightIconURL:nil size:size];
            }
        }
    }];
}

- (void)insertIconWithImageInfosModel:(TTImageInfosModel *)model atIndex:(NSUInteger)index
{
    if (!model || ![model isKindOfClass:[TTImageInfosModel class]]) {
        return;
    }
    NSString *urlString = [model urlStringAtIndex:0];
    if (isEmptyString(urlString)) {
        return;
    }
    
    CGSize size = CGSizeMake(model.width, model.height);
    [self insertIconWithDayIconURL:[NSURL URLWithString:urlString] nightIconURL:nil size:size atIndex:index];
}

- (NSUInteger)indexOfImageInfosModel:(TTImageInfosModel *)model
{
    if (!model || ![model isKindOfClass:[TTImageInfosModel class]]) {
        return NSNotFound;
    }
    
    NSString *urlString = [model urlStringAtIndex:0];
    
    return [self indexOfDayIconURL:[NSURL URLWithString:urlString]];
}

@end
