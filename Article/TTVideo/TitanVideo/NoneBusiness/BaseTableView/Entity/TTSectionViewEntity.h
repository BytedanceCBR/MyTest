
#import <Foundation/Foundation.h>

@interface TTSectionViewEntity : NSObject
@property (nonatomic, copy) NSString *headerTitle;
@property (nonatomic, copy) NSString *footerTitle;
@property (nonatomic, assign) Class    sectionClass;
@property (nonatomic ,assign) CGFloat  heightOfSection;
@property (nonatomic ,assign) CGFloat  heightOfFooter;
- (void)update;
@end
