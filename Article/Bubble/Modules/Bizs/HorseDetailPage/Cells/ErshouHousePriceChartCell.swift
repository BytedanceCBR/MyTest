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
    
    var unitPerSquare: Double = 100.0 * 10000.0
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if unitPerSquare >= 100.0 * 10000.0 {
            return String(format: "%.2f", value)
        }
        return String(format: "%d", Int(value))
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


class ErshouHousePriceChartCell: BaseUITableViewCell , RefreshableTableViewCell {

    var refreshCallback: CellRefreshCallback?
    var traceParams: TracerParams = TracerParams.momoid()
    var isPriceChartFoldState:Bool = true
    
    open override class var identifier: String {
        return "ErshouHousePriceChartCell"
    }
    
    var clickCallBack : (() -> Void)? = nil

    var monthFormatter = FHMonthValueFormatter()
    
    lazy var bgView: UIImageView = {
        let re = UIImageView(image: UIImage(named: "group-7"))
        re.contentMode = .scaleAspectFill
        re.layer.masksToBounds = true
        return re
    }()
    
    lazy var line: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHPaleGreyColor)
        return re
    }()
    
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
        // let fontSize : CGFloat = TTDeviceHelper.isScreenWidthLarge320() ? 14 : 12
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        re.text = "小区均价"
        return re
    }()
    
    lazy var priceValueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(24)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var monthUpKeyLabel: UILabel = {
        let re = UILabel()
        // let fontSize : CGFloat = TTDeviceHelper.isScreenWidthLarge320() ? 14 : 12
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        re.text = "环比上月"
        return re
    }()
    
    lazy var monthUpValueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
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
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        label.text = "(万元/平）"
        return label
    }()
    
    lazy var chartBgView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var bottomBgView: UIView = {
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
    
    lazy var foldButton: CommonFoldViewButton = {
        let view = CommonFoldViewButton(downText: "更多信息", upText: "收起")
        return view
    }()
    
    private var hasClick: Bool = false
    
    private var minValue: Double = 0
    private var maxValue: Double = 0
    
    private let disposeBag = DisposeBag()

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

            chartView.data = data

            let leftAxis = chartView.leftAxis
            leftAxis.drawBottomYLabelEntryEnabled = true
            leftAxis.drawTopYLabelEntryEnabled = true
            // 横轴的虚线
            leftAxis.axisMaximum = maxValue
            leftAxis.axisMinimum = minValue
            leftAxis.setLabelCount(4, force: true)
            

        }

    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(priceView)
        priceView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(0)
            maker.height.equalTo(138)
        }

        priceView.addSubview(bgView)

        // 小区均价
        priceView.addSubview(priceKeyLabel)
        priceKeyLabel.snp.makeConstraints { maker in
            maker.top.equalTo(0)
            maker.left.equalTo(20)
            maker.height.equalTo(20)
        }
        // 均价值
        priceView.addSubview(priceValueLabel)
        priceValueLabel.snp.makeConstraints { maker in
            
            maker.left.equalTo(priceKeyLabel)
            maker.top.equalTo(priceKeyLabel.snp.bottom).offset(8)
            maker.height.equalTo(24)
        }
        
        // "本房源单价比小区均价"
        priceView.addSubview(pricePerKeyLabel)
        pricePerKeyLabel.snp.makeConstraints { maker in
            maker.top.equalTo(priceValueLabel.snp.bottom).offset(20)
            maker.height.equalTo(20)
            maker.left.equalTo(priceValueLabel)
        }
        
        // value
        priceView.addSubview(priceUpValueLabel)
        priceUpValueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(pricePerKeyLabel)
            maker.top.equalTo(pricePerKeyLabel.snp.bottom).offset(11)
            maker.height.equalTo(20)

        }
        
        priceView.addSubview(priceUpTrend)
        priceUpTrend.snp.makeConstraints { maker in
            maker.right.equalTo(pricePerKeyLabel.snp.right)
            maker.centerY.equalTo(priceUpValueLabel)
            maker.width.height.equalTo(16)
        }
        
        bgView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(priceUpValueLabel.snp.bottom).offset(18)
            maker.bottom.equalToSuperview()
        }
        
        priceView.addSubview(line)
        line.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(pricePerKeyLabel).offset(10)
            maker.height.equalTo(30)
            maker.width.equalTo(1) // TTDeviceHelper.ssOnePixel()
        }
        
        priceView.addSubview(monthUpKeyLabel)
        monthUpKeyLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(pricePerKeyLabel.snp.centerY)
            maker.height.equalTo(20)
            maker.left.equalTo(line.snp.right).offset(30)
        }
        
        priceView.addSubview(monthUpValueLabel)
        monthUpValueLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(priceUpValueLabel.snp.centerY)
            maker.left.equalTo(monthUpKeyLabel)
            maker.height.equalTo(20)
        }
        
        priceView.addSubview(monthUpTrend)
        monthUpTrend.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-20)
            maker.centerY.equalTo(monthUpValueLabel)
            maker.width.height.equalTo(16)
        }
        
        contentView.addSubview(bottomBgView)
        bottomBgView.addSubview(chartBgView)
        bottomBgView.addSubview(foldButton)
        
        bottomBgView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalToSuperview().offset(138)
            maker.height.equalTo(58)
            maker.bottom.equalToSuperview()
        }
        
        chartBgView.addSubview(titleView)
        chartBgView.addSubview(priceLabel)
        chartBgView.addSubview(chartView)
        
        
        titleView.snp.remakeConstraints { maker in
            maker.right.equalToSuperview()
            maker.left.equalTo(70)
            maker.centerY.equalTo(priceLabel)
            maker.height.equalTo(20)
        }
        
        priceLabel.snp.remakeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(20)
        }
        
        chartView.snp.remakeConstraints { maker in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.top.equalTo(priceLabel.snp.bottom).offset(10)
            maker.height.equalTo(180)
            maker.bottom.equalToSuperview()
        }
    
        chartView.delegate = self
        setupChartUI()
        
        updateChartConstraints()
        
        foldButton.rx.tap
            .bind(onNext: { [weak self] () in
                self?.refreshCell()
                self?.foldButton.isFold = self?.isPriceChartFoldState ?? true
                
                if let isFold = self?.foldButton.isFold, let traceParams = self?.traceParams, isFold == false {
                    
                    recordEvent(key: TraceEventName.click_price_rank, params: traceParams <|>
                        EnvContext.shared.homePageParams <|>
                        toTracerParams("old_detail", key: "page_type"))
                }
            }).disposed(by: disposeBag)
    }
    
    func updateChartConstraints() {
        
        if self.isPriceChartFoldState {
            chartBgView.isHidden = true
            bottomBgView.snp.updateConstraints { (maker) in
                maker.height.equalTo(58)
            }
            chartBgView.snp.remakeConstraints { maker in
                maker.left.right.equalToSuperview()
                maker.top.equalToSuperview().offset(0)
                maker.height.equalTo(0)
            }
            foldButton.snp.remakeConstraints { (maker) in
                maker.left.right.equalToSuperview()
                maker.top.equalTo(chartBgView.snp.bottom)
                maker.height.equalTo(58)
                maker.bottom.equalToSuperview()
            }
        } else {
            chartBgView.isHidden = false
            bottomBgView.snp.updateConstraints { (maker) in
                maker.height.equalTo(315)
            }
            chartBgView.snp.remakeConstraints { maker in
                maker.left.right.equalToSuperview()
                maker.top.equalToSuperview().offset(0)
                maker.height.equalTo(257)
            }
            foldButton.snp.remakeConstraints { (maker) in
                maker.left.right.equalToSuperview()
                maker.top.equalTo(chartBgView.snp.bottom)
                maker.height.equalTo(58)
                maker.bottom.equalToSuperview()
            }
        }
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
        xAxis.axisLineColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        xAxis.axisLineWidth = 0.5
        xAxis.drawAxisLineEnabled = true
        xAxis.yOffset = 10
        xAxis.xOffset = -20
        xAxis.valueFormatter = self.monthFormatter
        xAxis.enabled = true
        xAxis.spaceMin = 0.5
        xAxis.spaceMax = 0.5

        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        leftAxis.axisLineColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        leftAxis.xOffset = 20
        leftAxis.labelCount = 4
        leftAxis.drawAxisLineEnabled = true
        leftAxis.gridColor = hexStringToUIColor(hex: kFHSilver2Color)
        leftAxis.drawBottomYLabelEntryEnabled = true
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.forceLabelsEnabled = true
        // 左边轴的虚线
        leftAxis.drawGridLinesEnabled = true
//        leftAxis.zeroLineColor = hexStringToUIColor(hex: kFHSilver2Color)
        leftAxis.drawZeroLineEnabled = false
//        leftAxis.zeroLineWidth = 0.5
        leftAxis.valueFormatter = FHFloatValueFormatter()
        leftAxis.spaceTop = 0.5
        leftAxis.spaceBottom = 1
        leftAxis.spaceMax = 0.5
        leftAxis.spaceMin = 0.5
        leftAxis.yOffset = 10
        

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
func lineColorByIndex(_ index: Int) -> UIColor {

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

func imgNameByIndex(_ index: Int) -> String {
    
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

func highlightImgNameByIndex(_ index: Int) -> String {
    
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
            
            let render = curry(fillErshouHousePriceChartCell)(ershouHouseData)(traceExtension)(callBack)

            let params = EnvContext.shared.homePageParams <|>
                toTracerParams("price_trend", key: "element_type") <|>
                toTracerParams("old_detail", key: "page_type") <|>
            traceExtension

            return TableSectionNode(
                items: [render],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: ErshouHousePriceChartCell.identifier))
        } else {
            return nil
        }
    }
}

func fillErshouHousePriceChartCell(_ data: ErshouHouseData,traceExtension: TracerParams = TracerParams.momoid(), callBack: @escaping () -> Void, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHousePriceChartCell {
        theCell.clickCallBack = callBack

        theCell.traceParams = traceExtension
        theCell.priceValueLabel.text = data.neighborhoodInfo?.pricingPerSqm
        theCell.priceView.isHidden = false
        
        theCell.foldButton.isFold = theCell.isPriceChartFoldState
        theCell.updateChartConstraints()

        let pricingPerSqm = Double(data.neighborhoodInfo?.pricingPerSqmValue ?? 0)
        if pricingPerSqm > 0 {
            let pricingPerSqmValue = Double(data.pricingPerSqmValue)
            let priceUp = (pricingPerSqmValue - pricingPerSqm) / pricingPerSqm * 100
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
