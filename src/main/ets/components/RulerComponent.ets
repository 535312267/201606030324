/**
 * 刻度尺组件
 * 组件大小：高135，宽345
 * 使用Stack和Scroll组件实现滑动功能
 * 刻度样式：宽4，默认高12，每第5个刻度高18
 */

@Component
export struct RulerComponent {
  @State scrollOffset: number = 0 // 滑动偏移量
  @State currentValue: number = 3000 // 当前刻度值，默认3000
  private scroller: Scroller = new Scroller()
  
  aboutToAppear() {
    // 组件初始化时滚动到默认位置（3000对应的位置）
    setTimeout(() => {
      const defaultPosition = (3000 / this.SCALE_VALUE_STEP) * this.SCALE_SPACING
      this.scroller.scrollTo({ xOffset: defaultPosition, yOffset: 0 })
    }, 100)
  }
  
  // 刻度配置
  private readonly RULER_WIDTH = 345
  private readonly RULER_HEIGHT = 135
  private readonly SCALE_WIDTH = 4
  private readonly SCALE_HEIGHT_NORMAL = 12
  private readonly SCALE_HEIGHT_MAJOR = 18
  private readonly SCALE_SPACING = 8 // 刻度间距
  private readonly TOTAL_SCALES = 250 // 总刻度数，支持0-10000范围
  private readonly SCALE_VALUE_STEP = 40 // 每个刻度代表的数值步长，使5个刻度为200
  
  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 背景容器
      Column()
        .width(this.RULER_WIDTH)
        .height(this.RULER_HEIGHT)
        .backgroundColor('#f8f8f8')
        .borderRadius(8)
      
      // 滑动容器
      Scroll(this.scroller) {
        Row() {
          // 左侧填充，使中心刻度能对齐到中心线
          Column().width(this.RULER_WIDTH / 2)
          
          // 生成刻度
          ForEach(Array.from({ length: this.TOTAL_SCALES }, (_, index) => index), (index: number) => {
            this.buildScale(index)
          })
          
          // 右侧填充
          Column().width(this.RULER_WIDTH / 2)
        }
        .height(this.RULER_HEIGHT)
        .justifyContent(FlexAlign.Start)
      }
      .width(this.RULER_WIDTH)
      .height(this.RULER_HEIGHT)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .onScroll((xOffset: number, yOffset: number) => {
        this.scrollOffset = xOffset
        // 计算当前刻度值，考虑初始偏移和步长
        const scaleIndex = Math.round(xOffset / this.SCALE_SPACING)
        this.currentValue = Math.max(0, scaleIndex * this.SCALE_VALUE_STEP)
      })
      
      // 中心指示线和数值显示区域
      Column() {
        // 当前数值显示背景
        Column() {
          Row() {
            Text(`${this.currentValue}`)
              .fontSize(20)
              .fontColor('#ff69b4')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
            
            Text('mL')
              .fontSize(14)
              .fontColor('#ff69b4')
              .textAlign(TextAlign.Center)
              .margin({ left: 2, top: 4 })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Bottom)
        }
        .width(90)
        .height(35)
        .backgroundColor('#ffe4e1')
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .border({ width: 2, color: '#ff69b4' })
        .margin({ bottom: 8 })
        
        // 中心指示线
        Column()
          .width(2)
          .height(50)
          .backgroundColor('#ff4081')
      }
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      .position({ x: this.RULER_WIDTH / 2 - 40, y: 20 })
    }
    .width(this.RULER_WIDTH)
    .height(this.RULER_HEIGHT)
    .clip(true)
  }
  
  /**
   * 构建单个刻度
   * @param index 刻度索引
   */
  @Builder
  buildScale(index: number) {
    Column() {
      // 每第5个刻度显示数值
      if (index % 5 === 0) {
        Text(`${index * this.SCALE_VALUE_STEP}`)
          .fontSize(10)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .width(30)
          .margin({ bottom: 4 })
      } else {
        // 占位空间，保持对齐
        Column()
          .height(18)
          .margin({ bottom: 4 })
      }
      
      // 刻度线
      Column()
        .width(this.SCALE_WIDTH)
        .height(index % 5 === 0 ? this.SCALE_HEIGHT_MAJOR : this.SCALE_HEIGHT_NORMAL)
        .backgroundColor(index % 5 === 0 ? '#333333' : '#cccccc')
        .borderRadius(2)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
    .width(this.SCALE_SPACING)
  }
}