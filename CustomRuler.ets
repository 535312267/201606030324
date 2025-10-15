/**
 * 自定义交互式刻度尺组件
 * 支持滑动选择数值，自动对齐到刻度
 */

@Component
export struct CustomRuler {
  // 组件属性
  @Prop minValue: number = 0          // 最小值
  @Prop maxValue: number = 100        // 最大值
  @Prop step: number = 1              // 步长
  @Prop currentValue: number = 50     // 当前值
  @Link selectedValue: number         // 选中的值（双向绑定）
  
  // 内部状态
  @State private offsetX: number = 0  // 水平偏移量
  @State private isDragging: boolean = false // 是否正在拖拽
  
  // 样式常量
  private readonly RULER_WIDTH = 345
  private readonly RULER_HEIGHT = 135
  private readonly BACKGROUND_COLOR = '#F7F7F7'
  private readonly SCALE_COLOR = '#99999999' // #999999 with 59% opacity
  private readonly MAJOR_SCALE_HEIGHT = 18
  private readonly MINOR_SCALE_HEIGHT = 12
  private readonly SCALE_WIDTH = 4
  private readonly INDICATOR_COLOR = '#FF69B4' // 粉色指示器
  
  // 计算属性
  private get totalSteps(): number {
    return Math.floor((this.maxValue - this.minValue) / this.step)
  }
  
  private get scaleSpacing(): number {
    return 8 // 刻度间距
  }
  
  private get centerX(): number {
    return this.RULER_WIDTH / 2
  }
  
  // 根据当前值计算偏移量
  private getOffsetForValue(value: number): number {
    const valueIndex = (value - this.minValue) / this.step
    return -valueIndex * this.scaleSpacing + this.centerX
  }
  
  // 根据偏移量计算当前值
  private getValueForOffset(offset: number): number {
    const valueIndex = Math.round((-offset + this.centerX) / this.scaleSpacing)
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
    })
  }
  
  aboutToAppear() {
    // 初始化偏移量
    this.offsetX = this.getOffsetForValue(this.currentValue)
    this.selectedValue = this.currentValue
  }
  
  build() {
    Column() {
      // 数值显示区域
      Text(`${this.selectedValue}`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 10 })
      
      // 刻度尺容器
      Stack({ alignContent: Alignment.Center }) {
        // 背景
        Rect()
          .width(this.RULER_WIDTH)
          .height(this.RULER_HEIGHT)
          .fill(this.BACKGROUND_COLOR)
          .radius(8)
        
        // 刻度尺内容
        Stack() {
          // 刻度绘制
          Canvas(this.getCanvasContext.bind(this))
            .width(this.RULER_WIDTH * 4) // 扩展画布宽度
            .height(this.RULER_HEIGHT)
            .translate({ x: this.offsetX })
            .onReady(() => {
              this.drawRuler()
            })
        }
        .width(this.RULER_WIDTH)
        .height(this.RULER_HEIGHT)
        .clip(true)
        
        // 中间指示器
        Column() {
          // 指示器线条
          Rect()
            .width(2)
            .height(40)
            .fill(this.INDICATOR_COLOR)
          
          // 指示器三角形
          Polygon({ points: [[0, 0], [8, 12], [-8, 12]] })
            .fill(this.INDICATOR_COLOR)
            .margin({ top: -1 })
        }
        .position({ x: this.centerX - 1, y: 30 })
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
              
              // 实时更新选中值
              this.selectedValue = this.getValueForOffset(this.offsetX)
              
              // 重新绘制刻度尺
              this.drawRuler()
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
  
  private canvasContext: CanvasRenderingContext2D | null = null
  
  private getCanvasContext(context: CanvasRenderingContext2D) {
    this.canvasContext = context
  }
  
  private drawRuler() {
    if (!this.canvasContext) return
    
    const ctx = this.canvasContext
    const canvasWidth = this.RULER_WIDTH * 4 // 扩展画布宽度以支持滑动
    ctx.clearRect(0, 0, canvasWidth, this.RULER_HEIGHT)
    
    // 计算绘制范围
    const visibleStartIndex = Math.floor(-this.offsetX / this.scaleSpacing) - 20
    const visibleEndIndex = Math.ceil((-this.offsetX + this.RULER_WIDTH) / this.scaleSpacing) + 20
    
    // 绘制刻度
    for (let i = visibleStartIndex; i <= visibleEndIndex; i++) {
      const value = this.minValue + i * this.step
      
      // 跳过超出范围的值
      if (value < this.minValue || value > this.maxValue) continue
      
      const x = this.centerX + i * this.scaleSpacing
      const isMajorScale = (value - this.minValue) % (this.step * 5) === 0
      const scaleHeight = isMajorScale ? this.MAJOR_SCALE_HEIGHT : this.MINOR_SCALE_HEIGHT
      
      // 绘制刻度线
      ctx.fillStyle = this.SCALE_COLOR
      ctx.fillRect(
        x - this.SCALE_WIDTH / 2, 
        this.RULER_HEIGHT - scaleHeight - 30, 
        this.SCALE_WIDTH, 
        scaleHeight
      )
      
      // 绘制主刻度数字
      if (isMajorScale) {
        ctx.fillStyle = '#666666'
        ctx.font = '12px HarmonyOS-Sans, sans-serif'
        ctx.textAlign = 'center'
        ctx.fillText(value.toString(), x, this.RULER_HEIGHT - scaleHeight - 35)
      }
    }
  }
}

// 使用示例组件
@Entry
@Component
struct RulerDemo {
  @State selectedValue: number = 3000
  
  build() {
    Column({ space: 20 }) {
      Text('自定义刻度尺演示')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50 })
      
      Text(`当前选中值: ${this.selectedValue}ml`)
        .fontSize(16)
        .fontColor('#666666')
      
      CustomRuler({
        minValue: 2000,
        maxValue: 4000,
        step: 10,
        currentValue: this.selectedValue,
        selectedValue: $selectedValue
      })
      
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding(20)
  }
}