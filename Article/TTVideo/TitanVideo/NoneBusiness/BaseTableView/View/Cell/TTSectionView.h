
#import <UIKit/UIKit.h>
#import "TTSectionViewEntity.h"
#import "SSThemed.h"

@interface TTSectionView : SSThemedView
@property (nonatomic) TTSectionViewEntity *cellEntity;
@property (nonatomic ,assign) NSInteger   section;

- (void)renderView;
- (void)fillContent;

@end
