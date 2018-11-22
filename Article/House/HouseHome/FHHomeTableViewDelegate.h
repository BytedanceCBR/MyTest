//
//  FHHomeTableViewDelegate.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeTableViewDelegate : NSObject <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) NSArray <JSONModel *>*modelsArray;

- (instancetype)initWithModels:(NSArray <JSONModel *>*)modelsArray;

@end

NS_ASSUME_NONNULL_END
