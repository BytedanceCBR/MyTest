//
//  WDQuestionDescEntity.h
//  Article
//
//  Created by 延晋 张 on 2016/10/24.
//
//

#import "TTEntityBase.h"
#import "TTImageInfosModel.h"

@class WDQuestionDescStructModel;
@class TTImageInfosModel;

@interface WDQuestionDescEntity : TTEntityBase

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSArray<TTImageInfosModel *> *largeImageList;
@property (nonatomic, copy) NSArray<TTImageInfosModel *> *thumbImageList;

- (instancetype)initWithWDQuestionDescStructModel:(WDQuestionDescStructModel *)model;

@end
