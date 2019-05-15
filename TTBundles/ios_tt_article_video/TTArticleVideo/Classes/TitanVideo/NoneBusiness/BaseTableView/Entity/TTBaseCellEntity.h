
@interface TTBaseCellEntity : NSObject
@property (nonatomic, assign) Class         cellClass;
@property (nonatomic, assign) Class         nextCellClass;
@property (nonatomic ,assign) float         heightOfCell;
@property (nonatomic ,assign) float         widthOfCell;
//contentview
@property (nonatomic ,assign) float         heightOfContent;
@property (nonatomic, assign) Class         contentViewClass;
@property (nonatomic, assign) UIEdgeInsets cellInsets;
//data
@property (nonatomic ,strong) id            originData;//网络请求下来的数据
@end
