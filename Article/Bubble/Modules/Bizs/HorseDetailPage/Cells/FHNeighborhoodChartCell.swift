//
//  FHNeighborhoodChartCell.swift
//  Article
//
//  Created by 张静 on 2018/11/13.
//

import UIKit
import Charts
import SnapKit
import RxSwift
import RxCocoa


class FHNeighborhoodChartCell: BaseUITableViewCell {
    
    open override class var identifier: String {
        return "FHNeighborhoodChartCell"
    }
    
    var clickCallBack : (() -> Void)? = nil
    
    var monthFormatter = FHMonthValueFormatter()
    
    lazy var titleView: UIView = {
        
        let view = UIView()
        return view
    }()
    
    lazy var priceLabel: UILabel = {
        
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        label.text = "(万元/平）"
        return label
    }()
    
    lazy var chartBgView: UIView = {
        
        let view = UIView()
        return view
    }()
    
    lazy var chartView: LineChartView = {
        
        let view = LineChartView()
        view.dragEnabled = false
        view.setScaleEnabled(false)
        view.pinchZoomEnabled = false
        view.chartDescription?.enabled = false
        view.chartDescription?.text = "(万元/平）"
        view.chartDescription?.font = CommonUIStyle.Font.pingFangRegular(12)
        view.chartDescription?.position = CGPoint(x: 10, y: 10)
        return view
    }()

    private var hasClick: Bool = false
    
    private var minValue: Double = 0
    private var maxValue: Double = 0
    
    // 单位，万元/平或元/平
    private var unitPerSquare: Double = 100.0 * 10000.0 {
        
        didSet {
            
            if unitPerSquare >= 100 * 10000 {
                self.priceLabel.text = "万元/平"
            }else {
                self.priceLabel.text = "元/平"
            }
            let leftAxis = chartView.leftAxis
            if let formatter = leftAxis.valueFormatter as? FHFloatValueFormatter {
                formatter.unitPerSquare = unitPerSquare
            }
            
        }
    }
    
    fileprivate var priceTrends:[PriceTrend] = [] {
        
        didSet {
            
            self.maxValue = (Double(priceTrends.first?.values.first?.price ?? "") ?? 0.0)
            self.minValue = self.maxValue
            
            var trailing: CGFloat = UIScreen.main.bounds.width - 20 - 70
            let fontSize : CGFloat = TTDeviceHelper.isScreenWidthLarge320() ? 14 : 12
            
            self.titleView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
            
            priceTrends.enumerated().reversed().forEach {[weak self] (offset, priceTrend) in
                
                var trendName:String? = priceTrend.name
                if let count = priceTrend.name?.count, count > 7 {
                    trendName = String(priceTrend.name?.prefix(7) ?? "") + "..."
                }
                let icon = UIView()
                icon.width = 8
                icon.height = 8
                icon.layer.cornerRadius = 4
                icon.layer.masksToBounds = true
                icon.backgroundColor = lineColorByIndex(offset)
                self?.titleView.addSubview(icon)
                
                let label = UILabel()
                label.font = CommonUIStyle.Font.pingFangRegular(fontSize)
                label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
                label.text = trendName
                self?.titleView.addSubview(label)
                
                label.sizeToFit()
                label.x = trailing - label.width
                label.height = 20
                label.y = 0
                trailing = label.left - 10
                
                icon.x = trailing - icon.width
                icon.centerY = label.centerY
                trailing = icon.left - 20
                
                priceTrend.values.enumerated().forEach({[weak self] (offset, item) in
                    let price = Double(item.price ?? "") ?? 0
                    if let maxValue = self?.maxValue, price > maxValue {
                        self?.maxValue = price
                    }
                    if let minValue = self?.minValue, price < minValue {
                        self?.minValue = price
                    }
                })
                
            }
            
            if self.maxValue >= 100 * 10000.0 {
                self.unitPerSquare = 100.0 * 10000.0
            }else {
                self.unitPerSquare = 100.0
                
            }
            
            if var thePriceTrend = priceTrends.first {
                
                for priceTrend in priceTrends {
                    
                    if priceTrend.values.count >= thePriceTrend.values.count {
                        thePriceTrend = priceTrend
                    }
                }
                self.monthFormatter.priceTrend = thePriceTrend
            }
            
            let dataSets = priceTrends.enumerated().map {[weak self] (index, priceTrend) -> LineChartDataSet in
                
                let yVals1 = priceTrend.values.enumerated().map {[weak self] (index, item) -> ChartDataEntry in
                    
                    let unitPerSquare = self?.unitPerSquare ?? (100 * 10000.00)
                    let valString = String(format: "%.2f", (Double(item.price ?? "") ?? 0.00) / unitPerSquare)
                    let val = Double(valString) ?? 0
                    
                    let entry = ChartDataEntry(x: Double(index), y: val)
                    entry.data = index as AnyObject
                    return entry
                    
                }
                
                let set1 = LineChartDataSet(values: yVals1, label: nil)
                set1.drawIconsEnabled = true
                set1.drawValuesEnabled = false
                set1.drawValuesEnabled = false
                
                set1.axisDependency = .left
                
                set1.setColor(lineColorByIndex(index))
                set1.setCircleColor(lineColorByIndex(index))
                set1.lineWidth = 1
                set1.circleRadius = 3
                set1.circleHoleColor = .white
                set1.circleHoleRadius = 2
                // 选中效果
                set1.highlightLineWidth = 1
                set1.highlightColor = hexStringToUIColor(hex: kFHClearBlueColor)
                set1.highlightLineDashLengths = [3,2]
                set1.drawHorizontalHighlightIndicatorEnabled = false
                
                return set1
                
            }
            
            let (_, _) = dataSets.enumerated().map { (index,item) -> (LineChartDataSet, Double) in
                
                let count = item.values.reduce(0) { (result, entry) in
                    result + entry.y
                }
                return (item, count)
                }.sorted(by: { $0.1 > $1.1 }).first ?? (nil,0)
            
            
            let data = LineChartData(dataSets: dataSets)
            let setPadding = (self.maxValue - self.minValue) / self.unitPerSquare / 4
            let maxValue = self.maxValue / unitPerSquare + setPadding
            let minValue = self.minValue / unitPerSquare - setPadding
            
            let leftAxis = chartView.leftAxis
            leftAxis.drawBottomYLabelEntryEnabled = false
            leftAxis.drawTopYLabelEntryEnabled = true
            // 横轴的虚线
            if maxValue != minValue {
                
                leftAxis.axisMaximum = maxValue
                leftAxis.axisMinimum = minValue
            }
            leftAxis.setLabelCount(6, force: true)
            
            chartView.data = data
            
            chartView.setViewPortOffsets(left: chartView.viewPortHandler.offsetLeft, top: -20, right: 20, bottom: chartView.viewPortHandler.offsetBottom)
            
            
        }
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(chartBgView)
        chartBgView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(0)
            maker.bottom.equalTo(-20)
        }
        
        chartBgView.addSubview(titleView)
        chartBgView.addSubview(priceLabel)
        
        titleView.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.left.equalTo(70)
            maker.centerY.equalTo(priceLabel)
            maker.height.equalTo(20)
        }
        
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalToSuperview()
        }
        
        chartBgView.addSubview(chartView)
        chartView.snp.makeConstraints { maker in
            maker.left.equalTo(8)
            maker.right.equalTo(0)
            maker.top.equalTo(priceLabel.snp.bottom).offset(10)
            maker.height.equalTo(180 * CommonUIStyle.Screen.widthScale)
            maker.bottom.equalToSuperview()
        }

        
        chartView.delegate = self
        setupChartUI()
        
    }
    
    func setupChartUI() {
        
        // 左边竖轴的区间
        let l = chartView.legend
        l.form = .none
        l.font = CommonUIStyle.Font.pingFangRegular(14)
        l.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = true
        l.wordWrapEnabled = true
        l.xEntrySpace = -20
        
        // 月份,也就是竖轴,不显示虚线
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12)
        xAxis.labelTextColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        xAxis.granularity = 1 // 粒度
        xAxis.drawGridLinesEnabled = false
        xAxis.axisLineColor = hexStringToUIColor(hex: "#dae1e7")
        xAxis.axisLineWidth = 1
        xAxis.drawAxisLineEnabled = true
        xAxis.yOffset = 10
        xAxis.xOffset = -20
        xAxis.valueFormatter = self.monthFormatter
        xAxis.enabled = true
        xAxis.spaceMin = 0.5
        xAxis.spaceMax = 0.5
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        leftAxis.labelFont = .systemFont(ofSize: 12)
        leftAxis.axisLineColor = hexStringToUIColor(hex: "#dae1e7")
        leftAxis.xOffset = 12
        leftAxis.labelCount = 4
        leftAxis.drawAxisLineEnabled = true
        leftAxis.gridColor = hexStringToUIColor(hex: "#ebeff2")
        leftAxis.drawBottomYLabelEntryEnabled = true
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.forceLabelsEnabled = true
        // 左边轴的虚线
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawZeroLineEnabled = false
        leftAxis.valueFormatter = FHFloatValueFormatter()
        leftAxis.axisLineWidth = 1
        
        chartView.extraTopOffset = 40
        
        // 右边轴
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        
        let marker: ErshouPriceMarkerView = ErshouPriceMarkerView.viewFromXib()! as! ErshouPriceMarkerView
        marker.markerData = {[unowned self] index in
            if self.hasClick {
                self.clickCallBack?()
            }
            self.hasClick = true //第一次初始化不上报埋点
            
            guard self.priceTrends.count > 0 else {
                
                return (self.unitPerSquare, [])
            }
            var items = [(String,TrendItem)]()
            
            for priceTrend in self.priceTrends {
                
                if index >= 0 && index < priceTrend.values.count {
                    
                    items.append((priceTrend.name ?? "",priceTrend.values[index]))
                }
                
            }
            
            return (self.unitPerSquare, items)
        }
        marker.chartView = chartView
        chartView.marker = marker
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    
}

extension FHNeighborhoodChartCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let sets = chartView.data?.dataSets
        let selectIndex = entry.data as? Int ?? 0
        sets?.enumerated().forEach({ (offset,set) in
            
            for i in 0 ..< set.entryCount {
                
                if i == selectIndex {
                    set.entryForIndex(i)?.icon = UIImage(named: highlightImgNameByIndex(offset))
                }else {
                    set.entryForIndex(i)?.icon = nil
                }
            }
            
        })
        
        
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        let sets = chartView.data?.dataSets
        sets?.enumerated().forEach({ (offset,set) in
            
            for i in 0 ..< set.entryCount {
                
                set.entryForIndex(i)?.icon = nil
            }
            
        })
    }
    
    
}

func parseNeighboorhoodPriceChartNode(_ neighborhoodData: NeighborhoodDetailData,traceExtension: TracerParams = TracerParams.momoid(), navVC: UINavigationController?,callBack: @escaping () -> Void) -> () -> TableSectionNode? {
    
    return {
        
        if let count = neighborhoodData.priceTrend?.count, count > 0 {
            
            let render = curry(fillNeighboorhoodPriceChartCell)(neighborhoodData)(callBack)
            let params = TracerParams.momoid() <|>
                toTracerParams("price_trend", key: "element_type") <|>
            traceExtension
            return TableSectionNode(
                items: [oneTimeRender(render)],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                sectionTracer: nil,
                label: "",
                type: .node(identifier: FHNeighborhoodChartCell.identifier))
        } else {
            
            return nil
        }
    }
    
    
    
}

func fillNeighboorhoodPriceChartCell(_ neighboorData: NeighborhoodDetailData, callBack: @escaping () -> Void, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FHNeighborhoodChartCell {
        
        if let priceTrend = neighboorData.priceTrend{
            
            theCell.priceTrends = priceTrend
        }
        
    }
}


