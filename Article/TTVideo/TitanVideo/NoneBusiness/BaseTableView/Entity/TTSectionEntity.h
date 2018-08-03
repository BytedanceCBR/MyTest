
#import <Foundation/Foundation.h>
#import "TTBaseCellEntity.h"
#import "TTSectionViewEntity.h"

@interface TTSectionEntity : NSObject
@property (nonatomic) TTSectionViewEntity *sectionData;
@property (nonatomic) NSMutableArray *items;
@end
