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



class ErshouHousePriceChartCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "ErshouHousePriceChartCell"
    }

    lazy var nameKey: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.text = "均价走势分析"
        return re
    }()

    lazy var priceLabel: UILabel = {

        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(11)
        label.textColor = hexStringToUIColor(hex: "999999")
        label.text = "价格(元/平）"

        return label
    }()

    lazy var chartView: LineChartView = {

        let view = LineChartView()
        view.dragEnabled = false
        view.setScaleEnabled(false)
        view.pinchZoomEnabled = false
        view.chartDescription?.enabled = false

        return view
    }()
    
    lazy var bottomLine: UIView = {
        
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        
        return view
    }()

    fileprivate var priceTrends:[PriceTrend] = [] {

        didSet {

            let dataSets = priceTrends.enumerated().map { (index, priceTrend) -> LineChartDataSet in

                let yVals1 = priceTrend.values.enumerated().map { (index, item) -> ChartDataEntry in

                    let entry = ChartDataEntry(x: Double(index), y: (Double(item.price ?? "") ?? 0) / 100.0)
                    entry.data = index as AnyObject
                    return entry

                }

                let set1 = LineChartDataSet(values: yVals1, label: priceTrend.name)
                set1.drawIconsEnabled = true
                set1.drawValuesEnabled = false

                set1.axisDependency = .left


                let color: ((Int) -> UIColor) = { (index) -> UIColor in

                    switch index {

                    case 0:
                        return hexStringToUIColor(hex: "ffaf45")
                    case 1:
                        return hexStringToUIColor(hex: "46a3fe")
                    case 2:
                        return hexStringToUIColor(hex: "b5b5b5")
                    default:
                        return hexStringToUIColor(hex: "ffaf45")

                    }
                }

                set1.setColor(color(index))
                set1.setCircleColor(color(index))
                set1.lineWidth = 2
                set1.circleRadius = 3
                // 选中效果
                set1.highlightColor = hexStringToUIColor(hex: "ffaf45")
                set1.drawHorizontalHighlightIndicatorEnabled = false


                return set1
                
            }

            let (set, _) = dataSets.enumerated().map { (index,item) -> (LineChartDataSet, Double) in

                let count = item.values.reduce(0) { (result, entry) in
                    result + entry.y
                }
                return (item, count)
            }.sorted(by: { $0.1 > $1.1 }).first ?? (nil,0)

            let gradientColors = [hexStringToUIColor(hex: "ffaf45").cgColor,
                hexStringToUIColor(hex: "ffd87b",alpha: 0).cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

            set?.fillAlpha = 0.15
            set?.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
            set?.drawFilledEnabled = true

            let data = LineChartData(dataSets: dataSets)
            chartView.data = data

            if let x = set?.values.last?.x,let y = set?.values.last?.y {
                
                chartView.highlightValue(x: x, y: y, dataSetIndex: 0, callDelegate: true)
                
            }


        }

    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameKey)
        nameKey.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.top.equalToSuperview().offset(15)
        }

        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(nameKey)
            maker.top.equalTo(nameKey.snp.bottom).offset(10)
        }

        contentView.addSubview(chartView)
        chartView.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.top.equalTo(nameKey.snp.bottom).offset(30)
            maker.height.equalTo(200)
        }

        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.top.equalTo(chartView.snp.bottom)
            maker.height.equalTo(1)
            maker.bottom.equalToSuperview()
        }

        chartView.delegate = self


        setupChartUI()
    }

    func setupChartUI() {

        // 左边竖轴的区间
        let l = chartView.legend
        l.form = .line
        l.font = CommonUIStyle.Font.pingFangRegular(13)
        l.textColor = hexStringToUIColor(hex: "505050")
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.wordWrapEnabled = true

        // 线条描述的间距
//        l.xOffset = 50
        l.yOffset = 20
        l.formToTextSpace = 5
        l.xEntrySpace = 10
        l.calculatedLineSizes = [CGSize(width: 20, height: 20)]
        l.stackSpace = 20

        // 月份,也就是竖轴,不显示虚线
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = hexStringToUIColor(hex: "999999")
        xAxis.granularity = 1 // 粒度
        xAxis.drawGridLinesEnabled = false
        xAxis.axisLineColor = hexStringToUIColor(hex: "ffaf45")
        xAxis.axisLineWidth = 0.5
        xAxis.drawAxisLineEnabled = true

        xAxis.valueFormatter = self

        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = hexStringToUIColor(hex: "999999")
        leftAxis.labelCount = 3
        leftAxis.axisLineColor = hexStringToUIColor(hex: "ffaf45")

        leftAxis.gridColor = hexStringToUIColor(hex: "ffaf45")

        // 横轴的虚线
        leftAxis.drawGridLinesEnabled = false
        leftAxis.zeroLineColor = hexStringToUIColor(hex: "ffaf45")
        leftAxis.drawZeroLineEnabled = false

        // 右边轴
        let rightAxis = chartView.rightAxis
        rightAxis.labelTextColor = .red
        rightAxis.axisMaximum = 0
        rightAxis.axisMinimum = 0
        rightAxis.drawZeroLineEnabled = false
        rightAxis.axisLineColor = hexStringToUIColor(hex: "ffaf45")

        let marker: ErshouPriceMarkerView = ErshouPriceMarkerView.viewFromXib()! as! ErshouPriceMarkerView
        marker.markerData = {[unowned self] index in

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

extension ErshouHousePriceChartCell:ChartViewDelegate {

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {

    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {

    }


}

extension ErshouHousePriceChartCell: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        guard let trend = self.priceTrends.first,trend.values.count > 0 else{
            
            return ""
            
        }

        let timeStamp = trend.values[min(max(Int(value), 0), trend.values.count - 1)].timestamp
        return CommonUIStyle.DateTime.monthDataFormat.string(from: Date(timeIntervalSince1970: TimeInterval(timeStamp ?? 0)))

        
    }
}



func parseErshouHousePriceChartNode(_ ershouHouseData: ErshouHouseData, navVC: UINavigationController?) -> () -> TableSectionNode {

    return {
        let render = curry(fillErshouHousePriceChartCell)(ershouHouseData.priceTrend)
        let params = TracerParams.momoid() <|>
                toTracerParams("price_trend", key: "element_type")
        return TableSectionNode(
                items: [render],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: ErshouHousePriceChartCell.identifier))
    }
    


}

func fillErshouHousePriceChartCell(_ data: [PriceTrend]?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHousePriceChartCell,let theData = data,theData.count > 0 {

        theCell.priceTrends = theData

        
    }
}

