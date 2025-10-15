/**
 * 改进版自定义交互式刻度尺组件
 * 支持滑动选择数值，自动对齐到刻度，性能优化
 */

@Component
export struct ImprovedCustomRuler {
  // 组件属性
  @Prop minValue: number = 0          // 最小值
  @Prop maxValue: number = 100        // 最大值
  @Prop step: number = 1              // 步长
  @Prop currentValue: number = 50     // 当前值
  @Link selectedValue: number         // 选中的值（双向绑定）
  @Prop unit: string = ''             // 单位
  
  // 内部状态
  @State private offsetX: number = 0  // 水平偏移量
  @State private isDragging: boolean = false // 是否正在拖拽
  @State private displayValue: number = 50 // 显示的数值
  
  // 样式常量
  private readonly RULER_WIDTH = 345
  private readonly RULER_HEIGHT = 135
  private readonly BACKGROUND_COLOR = '#F7F7F7'
  private readonly SCALE_COLOR = '#99999999' // #999999 with 59% opacity (0.59 * 255 ≈ 150)
  private readonly MAJOR_SCALE_HEIGHT = 18
  private readonly MINOR_SCALE_HEIGHT = 12
  private readonly SCALE_WIDTH = 4
  private readonly INDICATOR_COLOR = '#FF69B4' // 粉色指示器
  private readonly SCALE_SPACING = 8 // 刻度间距
  
  // 计算属性
  private get totalSteps(): number {
    return Math.floor((this.maxValue - this.minValue) / this.step)
  }
  
  private get centerX(): number {
    return this.RULER_WIDTH / 2
  }
  
  // 根据当前值计算偏移量
  private getOffsetForValue(value: number): number {
    const valueIndex = (value - this.minValue) / this.step
    return -valueIndex * this.SCALE_SPACING + this.centerX
  }
  
  // 根据偏移量计算当前值
  private getValueForOffset(offset: number): number {
    const valueIndex = Math.round((-offset + this.centerX) / this.SCALE_SPACING)
    const clampedIndex = Math.max(0, Math.min(this.totalSteps, valueIndex))
    return this.minValue + clampedIndex * this.step
  }
  
  // 对齐到最近的刻度
  private snapToScale() {
    const targetValue = this.getValueForOffset(this.offsetX)
    const targetOffset = this.getOffsetForValue(targetValue)
    
    // 动画过渡到目标位置
    animateTo({
      duration: 200,
      curve: Curve.EaseOut
    }, () => {
      this.offsetX = targetOffset
      this.selectedValue = targetValue
      this.displayValue = targetValue
    })
  }
  
  aboutToAppear() {
    // 初始化偏移量和显示值
    this.offsetX = this.getOffsetForValue(this.currentValue)
    this.selectedValue = this.currentValue
    this.displayValue = this.currentValue
  }
  
  build() {
    Column() {
      // 数值显示区域
      Text(`${this.displayValue}${this.unit}`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF69B4')
        .margin({ bottom: 15 })
      
      // 刻度尺容器
      Stack({ alignContent: Alignment.Center }) {
        // 背景
        Rect()
          .width(this.RULER_WIDTH)
          .height(this.RULER_HEIGHT)
          .fill(this.BACKGROUND_COLOR)
          .radius(8)
        
        // 刻度和数字绘制区域
        this.buildScales()
        
        // 中间指示器
        Column() {
          // 指示器上方的小圆点
          Circle({ width: 6, height: 6 })
            .fill(this.INDICATOR_COLOR)
            .margin({ bottom: 2 })
          
          // 指示器线条
          Rect()
            .width(2)
            .height(35)
            .fill(this.INDICATOR_COLOR)
          
          // 指示器三角形
          Polygon({ points: [[0, 0], [6, 10], [-6, 10]] })
            .fill(this.INDICATOR_COLOR)
            .margin({ top: -1 })
        }
        .position({ x: this.centerX - 1, y: 25 })
        .zIndex(10)
      }
      .width(this.RULER_WIDTH)
      .height(this.RULER_HEIGHT)
      .gesture(
        PanGesture({ fingers: 1, direction: PanDirection.Horizontal })
          .onActionStart(() => {
            this.isDragging = true
          })
          .onActionUpdate((event: GestureEvent) => {
            if (this.isDragging) {
              this.offsetX += event.offsetX
              // 限制拖拽范围
              const minOffset = this.getOffsetForValue(this.maxValue)
              const maxOffset = this.getOffsetForValue(this.minValue)
              this.offsetX = Math.max(minOffset, Math.min(maxOffset, this.offsetX))
              
              // 实时更新选中值和显示值
              const newValue = this.getValueForOffset(this.offsetX)
              this.selectedValue = newValue
              this.displayValue = newValue
            }
          })
          .onActionEnd(() => {
            this.isDragging = false
            // 滑动结束后对齐到最近的刻度
            this.snapToScale()
          })
      )
    }
    .alignItems(HorizontalAlign.Center)
  }
  
  @Builder
  private buildScales() {
    Stack() {
      // 使用ForEach动态生成刻度，提高性能
      ForEach(this.getVisibleScales(), (scaleInfo: ScaleInfo) => {
        Column() {
          // 数字标签（仅主刻度显示）
          if (scaleInfo.isMajor) {
            Text(scaleInfo.value.toString())
              .fontSize(12)
              .fontColor('#666666')
              .margin({ bottom: 4 })
          }
          
          // 刻度线
          Rect()
            .width(this.SCALE_WIDTH)
            .height(scaleInfo.isMajor ? this.MAJOR_SCALE_HEIGHT : this.MINOR_SCALE_HEIGHT)
            .fill(this.SCALE_COLOR)
            .radius(2)
        }
        .position({ 
          x: scaleInfo.x - this.SCALE_WIDTH / 2, 
          y: scaleInfo.isMajor ? 45 : 53 
        })
      }, (item: ScaleInfo) => item.value.toString())
    }
    .width(this.RULER_WIDTH)
    .height(this.RULER_HEIGHT)
    .clip(true)
  }
  
  // 获取可见的刻度信息
  private getVisibleScales(): ScaleInfo[] {
    const scales: ScaleInfo[] = []
    
    // 计算可见范围
    const visibleStart = Math.floor((-this.offsetX - this.RULER_WIDTH / 2) / this.SCALE_SPACING) - 5
    const visibleEnd = Math.ceil((-this.offsetX + this.RULER_WIDTH / 2) / this.SCALE_SPACING) + 5
    
    for (let i = visibleStart; i <= visibleEnd; i++) {
      const value = this.minValue + i * this.step
      
      // 跳过超出范围的值
      if (value < this.minValue || value > this.maxValue) continue
      
      const x = this.centerX + i * this.SCALE_SPACING + this.offsetX
      const isMajor = (value - this.minValue) % (this.step * 5) === 0
      
      scales.push({
        value: value,
        x: x,
        isMajor: isMajor
      })
    }
    
    return scales
  }
}

// 刻度信息接口
interface ScaleInfo {
  value: number
  x: number
  isMajor: boolean
}

// 使用示例组件
@Entry
@Component
struct ImprovedRulerDemo {
  @State selectedValue: number = 3000
  
  build() {
    Column({ space: 30 }) {
      Text('改进版自定义刻度尺')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60 })
      
      Text(`当前选中值: ${this.selectedValue}ml`)
        .fontSize(18)
        .fontColor('#666666')
      
      ImprovedCustomRuler({
        minValue: 2000,
        maxValue: 4000,
        step: 10,
        currentValue: this.selectedValue,
        selectedValue: $selectedValue,
        unit: 'ml'
      })
      
      // 添加一些预设按钮
      Row({ space: 15 }) {
        Button('2500ml')
          .fontSize(14)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.selectedValue = 2500
          })
        
        Button('3000ml')
          .fontSize(14)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.selectedValue = 3000
          })
        
        Button('3500ml')
          .fontSize(14)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.selectedValue = 3500
          })
      }
      .margin({ top: 20 })
      
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding(20)
  }
}