//
//  ErshouHousePriceChartCell.swift
//  Article
//
//  Created by 张静 on 2018/8/6.
//

import UIKit
import Charts
import SnapKit
import RxSwift
import RxCocoa


class FHFloatValueFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return String(format: "%.2f", value)
    }
}


class FHMonthValueFormatter: IAxisValueFormatter {
    
    var priceTrend:PriceTrend?
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        guard let priceTrend = self.priceTrend else{
            
            return ""
        }
        if priceTrend.values.count < 1 {
            return ""
        }
        let timeStamp = priceTrend.values[min(max(Int(value), 0), priceTrend.values.count - 1)].timestamp
        
        return CommonUIStyle.DateTime.monthDataFormat.string(from: Date(timeIntervalSince1970: TimeInterval(timeStamp ?? 0)))
        
    }
}


class ErshouHousePriceChartCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "ErshouHousePriceChartCell"
    }
    
    var clickCallBack : (() -> Void)? = nil

    var monthFormatter = FHMonthValueFormatter()
    
    lazy var priceUpValueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangSemibold(24)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var priceUpTrend: UIImageView = {
        let re = UIImageView()
        return re
    }()
    
    lazy var pricePerKeyLabel: UILabel = {
        let re = UILabel()
        let fontSize : CGFloat = TTDeviceHelper.isScreenWidthLarge320() ?  14 : 12
        re.font = CommonUIStyle.Font.pingFangRegular(fontSize)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        re.text = "本房源单价比小区均价"
        return re
    }()
    
    lazy var priceKeyLabel: UILabel = {
        let re = UILabel()
        let fontSize : CGFloat = TTDeviceHelper.isScreenWidthLarge320() ? 14 : 12
        re.font = CommonUIStyle.Font.pingFangRegular(fontSize)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        re.text = "小区均价"
        return re
    }()
    
    lazy var priceValueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var monthUpKeyLabel: UILabel = {
        let re = UILabel()
        let fontSize : CGFloat = TTDeviceHelper.isScreenWidthLarge320() ? 14 : 12
        re.font = CommonUIStyle.Font.pingFangRegular(fontSize)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        re.text = "环比上月"
        return re
    }()
    
    lazy var monthUpValueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var monthUpTrend: UIImageView = {
        let re = UIImageView()
        return re
    }()
    
    lazy var priceView: UIView = {
        
        let view = UIView()
        return view
    }()
    
    lazy var titleView: UIView = {

        let view = UIView()
        return view
    }()

    lazy var priceLabel: UILabel = {
        
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#8a9299")
        label.text = "(万元/平）"
        return label
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


    fileprivate var priceTrends:[PriceTrend] = [] {

        didSet {

            self.maxValue = (Double(priceTrends.first?.values.first?.price ?? "") ?? 0.0) / 100.0 / 10000.0
            self.minValue = self.maxValue
            
            if var thePriceTrend = priceTrends.first {
                
                for priceTrend in priceTrends {
                    
                    if priceTrend.values.count >= thePriceTrend.values.count {
                        thePriceTrend = priceTrend
                    }
                }
                self.monthFormatter.priceTrend = thePriceTrend
            }
            
            var trailing: CGFloat = 20
            
            self.titleView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
            
            priceTrends.enumerated().forEach {[weak self] (offset, priceTrend) in
                
                var trendName:String? = priceTrend.name
                if let count = priceTrend.name?.count, count > 7 {
                    trendName = String(priceTrend.name?.prefix(7) ?? "") + "..."
                }
                let icon = UIImageView(image: UIImage(named: imgNameByIndex(offset)))
                self?.titleView.addSubview(icon)
                
                let label = UILabel()
                label.font = CommonUIStyle.Font.pingFangRegular(14)
                label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
                label.text = trendName
                self?.titleView.addSubview(label)

                icon.sizeToFit()
                icon.x = trailing
                icon.centerY = 13
                
                label.sizeToFit()
                label.x = icon.right + 5
                label.centerY = icon.centerY
                
                trailing = label.right + 20
            }

            let dataSets = priceTrends.enumerated().map {[weak self] (index, priceTrend) -> LineChartDataSet in

                let yVals1 = priceTrend.values.enumerated().map {[weak self] (index, item) -> ChartDataEntry in

                    let valString = String(format: "%.2f", (Double(item.price ?? "") ?? 0.00) / 100 / 10000.00)
                    let val = Double(valString) ?? 0
                    if let max = self?.maxValue, val > max {
                        self?.maxValue = val
                    }
                    if let min = self?.minValue, val < min {
                        self?.minValue = val
                    }
                    
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
                set1.lineWidth = 2
                set1.circleRadius = 1
                // 选中效果
                set1.highlightColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
                set1.highlightLineDashLengths = [2,2]
                set1.drawHorizontalHighlightIndicatorEnabled = false


                return set1
                
            }

            let (set, _) = dataSets.enumerated().map { (index,item) -> (LineChartDataSet, Double) in

                let count = item.values.reduce(0) { (result, entry) in
                    result + entry.y
                }
                return (item, count)
            }.sorted(by: { $0.1 > $1.1 }).first ?? (nil,0)

            let data = LineChartData(dataSets: dataSets)
            let setPadding = (self.maxValue - self.minValue)/3
            self.maxValue = self.maxValue + setPadding
            self.minValue = self.minValue - setPadding
//            chartView.setVisibleYRange(minYRange: self.minValue - setPadding, maxYRange: self.maxValue + setPadding, axis: .left)

            chartView.data = data

//            if let x = set?.values.last?.x,let y = set?.values.last?.y {
//
//                chartView.highlightValue(x: x, y: y, dataSetIndex: 0, callDelegate: true)
//
//            }
  

            let leftAxis = chartView.leftAxis
            leftAxis.drawBottomYLabelEntryEnabled = true
            leftAxis.drawTopYLabelEntryEnabled = true
            // 横轴的虚线
            leftAxis.spaceBottom = 0.0
            leftAxis.axisMaximum = self.maxValue
            leftAxis.axisMinimum = self.minValue
            leftAxis.setLabelCount(3, force: true)
            

        }

    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(priceView)
        priceView.isHidden = true
        priceView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(0)
        }
        
        priceView.addSubview(priceUpValueLabel)
        priceUpValueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(0)
            maker.height.equalTo(30)
        }
        
        priceView.addSubview(priceUpTrend)
        priceUpTrend.snp.makeConstraints { maker in
            maker.left.equalTo(priceUpValueLabel.snp.right).offset(1)
            maker.centerY.equalTo(priceUpValueLabel.snp.centerY)
            maker.width.height.equalTo(16)
        }
        
        priceView.addSubview(pricePerKeyLabel)
        pricePerKeyLabel.snp.makeConstraints { maker in
            maker.top.equalTo(priceUpValueLabel.snp.bottom).offset(4)
            maker.height.equalTo(20)
            maker.left.equalTo(priceUpValueLabel)
        }
        
        priceView.addSubview(priceValueLabel)
        priceValueLabel.snp.makeConstraints { maker in
            
            maker.right.equalTo(-20)
            maker.centerY.equalTo(priceUpValueLabel)
            maker.height.equalTo(20)
        }
        
        priceView.addSubview(priceKeyLabel)
        priceKeyLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(priceValueLabel.snp.centerY)
            maker.height.equalTo(20)
            maker.right.equalTo(priceValueLabel.snp.left).offset(-10)
        }
        
        priceView.addSubview(monthUpKeyLabel)
        monthUpKeyLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(pricePerKeyLabel.snp.centerY)
            maker.height.equalTo(20)
            maker.left.equalTo(priceKeyLabel)
        }
        
        priceView.addSubview(monthUpValueLabel)
        monthUpValueLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(monthUpKeyLabel.snp.centerY)
            maker.left.equalTo(monthUpKeyLabel.snp.right).offset(10)
            maker.height.equalTo(20)
        }
        
        priceView.addSubview(monthUpTrend)
        monthUpTrend.snp.makeConstraints { maker in
            maker.left.equalTo(monthUpValueLabel.snp.right).offset(1)
            maker.centerY.equalTo(monthUpKeyLabel)
            maker.width.height.equalTo(16)
        }
        
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(priceView.snp.bottom)
            maker.height.equalTo(26)
        }
        
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(titleView.snp.bottom).offset(15)
        }

        contentView.addSubview(chartView)
        chartView.snp.makeConstraints { maker in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.top.equalTo(priceLabel.snp.bottom)
            maker.height.equalTo(180)
            maker.bottom.equalToSuperview().offset(-20)
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

        // 线条描述的间距
//        l.xOffset = 20
//        l.yOffset = 15
//        l.formToTextSpace = 5
//        l.xEntrySpace = 6

        // 月份,也就是竖轴,不显示虚线
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12)
        xAxis.labelTextColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        xAxis.granularity = 1 // 粒度
        xAxis.drawGridLinesEnabled = false
        xAxis.axisLineColor = hexStringToUIColor(hex: kFHSilver2Color)
        xAxis.axisLineWidth = 0.5
        xAxis.drawAxisLineEnabled = false
        xAxis.yOffset = 10
        xAxis.valueFormatter = self.monthFormatter

        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        leftAxis.axisLineColor = hexStringToUIColor(hex: kFHSilver2Color)
        leftAxis.xOffset = 20
        leftAxis.labelCount = 3
        leftAxis.drawAxisLineEnabled = false
        leftAxis.gridColor = hexStringToUIColor(hex: kFHSilver2Color)
        leftAxis.drawBottomYLabelEntryEnabled = true
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.forceLabelsEnabled = true
        // 横轴的虚线
        leftAxis.spaceBottom = 0.0
        leftAxis.drawGridLinesEnabled = true
//        leftAxis.zeroLineColor = hexStringToUIColor(hex: kFHSilver2Color)
        leftAxis.drawZeroLineEnabled = false
//        leftAxis.zeroLineWidth = 0.5
        leftAxis.valueFormatter = FHFloatValueFormatter()

        // 右边轴
        let rightAxis = chartView.rightAxis
        rightAxis.labelTextColor = .red
        rightAxis.axisMaximum = 0
        rightAxis.axisMinimum = 0
        rightAxis.drawZeroLineEnabled = false
        rightAxis.drawAxisLineEnabled = false
        rightAxis.axisLineColor = hexStringToUIColor(hex: kFHSilver2Color)
        rightAxis.xOffset = 10

        let marker: ErshouPriceMarkerView = ErshouPriceMarkerView.viewFromXib()! as! ErshouPriceMarkerView
        marker.markerData = {[unowned self] index in
            if self.hasClick {
                self.clickCallBack?()
            }
            self.hasClick = true //第一次初始化不上报埋点
            
            guard self.priceTrends.count > 0 else {
                
                return []
            }
            var items = [(String,TrendItem)]()

            for priceTrend in self.priceTrends {
                
                if index >= 0 && index < priceTrend.values.count {
                    
                    items.append((priceTrend.name ?? "",priceTrend.values[index]))
                }
                
            }

            return items
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
fileprivate func lineColorByIndex(_ index: Int) -> UIColor {

    switch index {
        
    case 0:
        return hexStringToUIColor(hex: kFHCoralColor)
    case 1:
        return hexStringToUIColor(hex: kFHClearBlueColor)
    case 2:
        return hexStringToUIColor(hex: kFHSilverColor)
    default:
        return hexStringToUIColor(hex: kFHSilverColor)
        
    }
    
}

fileprivate func imgNameByIndex(_ index: Int) -> String {
    
    switch index {
        
    case 0:
        return "img-new-house-circle-red"
    case 1:
        return "img-new-house-circle-blue"
    case 2:
        return "img-new-house-circle-gray"
    default:
        return "img-new-house-circle-red"
        
    }
}

fileprivate func highlightImgNameByIndex(_ index: Int) -> String {
    
    switch index {
        
    case 0:
        return "img-summary-graph-circle-red"
    case 1:
        return "img-summary-graph-circle-blue"
    case 2:
        return "img-summary-graph-circle-gray"
    default:
        return "img-summary-graph-circle-red"
        
    }
}

extension ErshouHousePriceChartCell:ChartViewDelegate {

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


func parseErshouHousePriceChartNode(_ ershouHouseData: ErshouHouseData,traceExtension: TracerParams = TracerParams.momoid(), navVC: UINavigationController?,
    callBack: @escaping () -> Void) -> () -> TableSectionNode? {
    return {
        
        if let count = ershouHouseData.priceTrend?.count, count > 0 {
            
            let render = curry(fillErshouHousePriceChartCell)(ershouHouseData)(callBack)
            let params = TracerParams.momoid() <|>
                toTracerParams("price_trend", key: "element_type") <|>
                traceExtension
//                toTracerParams(ershouHouseData.logPB ?? [:], key: "log_pb")
            return TableSectionNode(
                items: [oneTimeRender(render)],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: ErshouHousePriceChartCell.identifier))
        } else {
            return nil
        }
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
                label: "",
                type: .node(identifier: ErshouHousePriceChartCell.identifier))
        } else {
            
            return nil
        }
    }



}


func fillErshouHousePriceChartCell(_ data: ErshouHouseData, callBack: @escaping () -> Void, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHousePriceChartCell {
        theCell.clickCallBack = callBack

        theCell.priceValueLabel.text = data.neighborhoodInfo?.pricingPerSqm
        theCell.priceView.isHidden = false
        let pricingPerSqm = Double(data.neighborhoodInfo?.pricingPerSqmValue ?? 0)
        if pricingPerSqm > 0 {
            let pricingPerSqmValue = Double(data.pricingPerSqmValue)
            let priceUp = (pricingPerSqm - pricingPerSqmValue) / pricingPerSqm * 100
            if priceUp == 0 {
                theCell.priceUpValueLabel.text = "持平"
                theCell.monthUpTrend.isHidden = true
            } else {
                theCell.priceUpValueLabel.text = String(format: "%.2f%%", abs(priceUp))
                theCell.monthUpTrend.isHidden = false
                if priceUp > 0 {
                    theCell.priceUpTrend.image = UIImage(named: "ion-arrow-up-a-ionicons")
                } else {
                    theCell.priceUpTrend.image = UIImage(named: "ion-arrow-down-a-ionicons")
                }
            }
        }

        theCell.priceView.snp.updateConstraints { (maker) in
            maker.height.equalTo(95)
        }
        if let monthUp = data.neighborhoodInfo?.monthUp {
            let absValue = abs(monthUp) * 100
            if absValue == 0 {
                theCell.monthUpValueLabel.text = "持平"
                theCell.monthUpTrend.isHidden = true
            } else {
                theCell.monthUpValueLabel.text = String(format: "%.2f%%", arguments: [absValue])
                theCell.monthUpTrend.isHidden = false
                if monthUp > 0 {
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_up")
                } else {
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_down")
                }
            }
        }
        if let priceTrend = data.priceTrend {
            
            theCell.priceTrends = priceTrend
        }
    }
}

func fillNeighboorhoodPriceChartCell(_ neighboorData: NeighborhoodDetailData, callBack: @escaping () -> Void, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHousePriceChartCell {
        
        theCell.priceView.isHidden = true
        if let priceTrend = neighboorData.priceTrend{

            theCell.priceTrends = priceTrend
        }
        
    }
}

