//
//  FRBaseEntity.h
//  Forum
//
//  Created by zhaopengwei on 15/5/10.
//
//

#import <Foundation/Foundation.h>

@interface FRBaseEntity : NSObject

@property (nonatomic, assign) CGFloat _cellHeight;
@property(nonatomic, assign) int64_t _entityHeightChangeFlag;
@property (strong, nonatomic) id _extObj;

- (void)entityHeightChanged;

@end
