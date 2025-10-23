@Entry
@Component
struct Index {
  @State changeTime: Date = new Date() // 更换时间
  @State currentTime: Date = new Date() // 当前时间
  @State waveOffset: number = 0 // 波浪偏移量
  @State animationRunning: boolean = true // 动画运行状态
  
  // 固定更换时间间隔（3小时 = 3 * 60 * 60 * 1000 毫秒）
  private readonly CHANGE_INTERVAL: number = 3 * 60 * 60 * 1000
  
  // 计算时间比例（0-1之间）
  private getTimeRatio(): number {
    const timeDiff = this.currentTime.getTime() - this.changeTime.getTime()
    const ratio = Math.min(timeDiff / this.CHANGE_INTERVAL, 1.0)
    return Math.max(ratio, 0)
  }
  
  // 更新当前时间
  private updateTime() {
    this.currentTime = new Date()
  }
  
  // 重置更换时间
  private resetChangeTime() {
    this.changeTime = new Date()
    this.currentTime = new Date()
  }
  
  aboutToAppear() {
    // 启动定时器更新时间和动画
    setInterval(() => {
      this.updateTime()
      if (this.animationRunning) {
        this.waveOffset = (this.waveOffset + 2) % 360
      }
    }, 100)
  }

  build() {
    Column() {
      // 标题
      Text('卫生巾使用时间监控')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
      
      // 时间信息显示
      Column() {
        Text(`更换时间: ${this.changeTime.toLocaleTimeString()}`)
          .fontSize(16)
          .margin(5)
        
        Text(`当前时间: ${this.currentTime.toLocaleTimeString()}`)
          .fontSize(16)
          .margin(5)
        
        Text(`使用比例: ${(this.getTimeRatio() * 100).toFixed(1)}%`)
          .fontSize(16)
          .fontColor(this.getTimeRatio() > 0.8 ? Color.Red : Color.Blue)
          .margin(5)
      }
      .padding(10)
      .backgroundColor('#f5f5f5')
      .borderRadius(10)
      .margin(10)
      
      // 卫生巾轮廓图和波浪动画
      SanitaryPadView({
        timeRatio: this.getTimeRatio(),
        waveOffset: this.waveOffset
      })
        .width('80%')
        .height(400)
        .margin(20)
      
      // 控制按钮
      Row() {
        Button('重置更换时间')
          .onClick(() => {
            this.resetChangeTime()
          })
          .margin(10)
        
        Button(this.animationRunning ? '暂停动画' : '开始动画')
          .onClick(() => {
            this.animationRunning = !this.animationRunning
          })
          .margin(10)
      }
      .margin(20)
      
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }
}

@Component
struct SanitaryPadView {
  @Prop timeRatio: number
  @Prop waveOffset: number
  
  build() {
    Stack() {
      Canvas(this.context)
        .onReady(() => {
          this.drawSanitaryPad()
        })
        .width('100%')
        .height('100%')
        .backgroundColor('#f8f8ff')
    }
  }
  
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D()
  
  private drawSanitaryPad() {
    // 获取画布尺寸
    const canvasWidth = 300
    const canvasHeight = 400
    
    // 清除画布
    this.context.clearRect(0, 0, canvasWidth, canvasHeight)
    
    // 绘制卫生巾轮廓
    this.drawSanitaryPadOutline()
    
    // 绘制波浪动画
    this.drawWaveAnimation()
  }
  
  // 使用Path2D绘制更精确的卫生巾轮廓
  private drawSanitaryPadOutline() {
    const centerX = 150
    const centerY = 200
    
    // 创建卫生巾主体轮廓路径
    const mainPath = new Path2D()
    
    // 绘制卫生巾的椭圆形主体
    // 上半部分（较窄）
    mainPath.ellipse(centerX, centerY - 40, 45, 60, 0, 0, 2 * Math.PI)
    
    // 中间部分（较宽）
    const middlePath = new Path2D()
    middlePath.ellipse(centerX, centerY, 65, 80, 0, 0, 2 * Math.PI)
    
    // 下半部分（较窄）
    const bottomPath = new Path2D()
    bottomPath.ellipse(centerX, centerY + 40, 45, 60, 0, 0, 2 * Math.PI)
    
    // 绘制外轮廓
    this.context.strokeStyle = '#ff69b4'
    this.context.lineWidth = 4
    this.context.stroke(middlePath)
    
    // 绘制翅膀部分
    this.drawWings(centerX, centerY)
    
    // 绘制吸收层轮廓
    this.drawAbsorptionLayers(centerX, centerY)
  }
  
  // 绘制卫生巾翅膀
  private drawWings(centerX: number, centerY: number) {
    // 左翅膀
    const leftWing = new Path2D()
    leftWing.moveTo(centerX - 65, centerY - 30)
    leftWing.quadraticCurveTo(centerX - 95, centerY - 15, centerX - 90, centerY)
    leftWing.quadraticCurveTo(centerX - 95, centerY + 15, centerX - 65, centerY + 30)
    leftWing.lineTo(centerX - 65, centerY - 30)
    
    // 右翅膀
    const rightWing = new Path2D()
    rightWing.moveTo(centerX + 65, centerY - 30)
    rightWing.quadraticCurveTo(centerX + 95, centerY - 15, centerX + 90, centerY)
    rightWing.quadraticCurveTo(centerX + 95, centerY + 15, centerX + 65, centerY + 30)
    rightWing.lineTo(centerX + 65, centerY - 30)
    
    // 绘制翅膀
    this.context.strokeStyle = '#ff1493'
    this.context.lineWidth = 2
    this.context.stroke(leftWing)
    this.context.stroke(rightWing)
    
    // 填充翅膀
    this.context.fillStyle = 'rgba(255, 182, 193, 0.3)'
    this.context.fill(leftWing)
    this.context.fill(rightWing)
  }
  
  // 绘制吸收层
  private drawAbsorptionLayers(centerX: number, centerY: number) {
    // 外层吸收区域
    this.context.beginPath()
    this.context.ellipse(centerX, centerY, 55, 70, 0, 0, 2 * Math.PI)
    this.context.strokeStyle = '#dda0dd'
    this.context.lineWidth = 2
    this.context.setLineDash([8, 4])
    this.context.stroke()
    
    // 内层吸收区域
    this.context.beginPath()
    this.context.ellipse(centerX, centerY, 35, 50, 0, 0, 2 * Math.PI)
    this.context.strokeStyle = '#ba55d3'
    this.context.lineWidth = 1
    this.context.setLineDash([4, 2])
    this.context.stroke()
    
    // 重置虚线样式
    this.context.setLineDash([])
  }
  
  private drawWaveAnimation() {
    const centerX = 150
    const centerY = 200
    const maxWaveHeight = this.timeRatio * 70 // 根据时间比例确定波浪高度
    
    if (maxWaveHeight <= 0) return
    
    // 创建裁剪区域（卫生巾内部椭圆区域）
    this.context.save()
    this.context.beginPath()
    this.context.ellipse(centerX, centerY, 53, 68, 0, 0, 2 * Math.PI)
    this.context.clip()
    
    // 绘制多层波浪
    this.drawMultiLayerWaves(centerX, centerY, maxWaveHeight)
    
    this.context.restore()
  }
  
  private drawMultiLayerWaves(centerX: number, centerY: number, maxHeight: number) {
    const waveCount = 4 // 波浪层数
    
    for (let layer = 0; layer < waveCount; layer++) {
      const layerHeight = maxHeight * (1 - layer * 0.15)
      const waveBottom = centerY + 68 - layerHeight
      
      this.drawSingleWave(centerX, waveBottom, layer, layerHeight)
    }
    
    // 绘制波浪表面效果
    this.drawWaveEffects(centerX, centerY + 68 - maxHeight)
  }
  
  private drawSingleWave(centerX: number, waveBottom: number, layer: number, height: number) {
    const waveWidth = 106 // 波浪宽度
    const amplitude = 6 - layer * 1.5 // 波浪振幅
    const frequency = 0.03 + layer * 0.005 // 波浪频率
    const phaseOffset = (this.waveOffset + layer * 45) * Math.PI / 180
    
    // 创建波浪路径
    const wavePath = new Path2D()
    let firstPoint = true
    
    for (let x = centerX - waveWidth / 2; x <= centerX + waveWidth / 2; x += 1) {
      const angle = (x - centerX) * frequency + phaseOffset
      const y = waveBottom + Math.sin(angle) * amplitude
      
      if (firstPoint) {
        wavePath.moveTo(x, y)
        firstPoint = false
      } else {
        wavePath.lineTo(x, y)
      }
    }
    
    // 闭合波浪路径
    wavePath.lineTo(centerX + waveWidth / 2, waveBottom + height)
    wavePath.lineTo(centerX - waveWidth / 2, waveBottom + height)
    wavePath.closePath()
    
    // 设置波浪颜色（根据时间比例和层级变化）
    const alpha = 0.4 - layer * 0.08
    let color: string
    
    if (this.timeRatio < 0.3) {
      color = `rgba(173, 216, 230, ${alpha})` // 浅蓝色 - 安全
    } else if (this.timeRatio < 0.6) {
      color = `rgba(255, 218, 185, ${alpha})` // 桃色 - 注意
    } else if (this.timeRatio < 0.8) {
      color = `rgba(255, 165, 0, ${alpha})` // 橙色 - 警告
    } else {
      color = `rgba(255, 99, 71, ${alpha})` // 红色 - 危险
    }
    
    this.context.fillStyle = color
    this.context.fill(wavePath)
    
    // 添加波浪边缘高光
    if (layer === 0) {
      this.context.strokeStyle = `rgba(255, 255, 255, ${alpha * 0.8})`
      this.context.lineWidth = 1
      this.context.stroke(wavePath)
    }
  }
  
  // 绘制波浪表面效果
  private drawWaveEffects(centerX: number, waveTop: number) {
    // 绘制气泡效果
    this.drawBubbles(centerX, waveTop)
    
    // 绘制闪光效果
    this.drawSparkles(centerX, waveTop)
  }
  
  private drawBubbles(centerX: number, waveTop: number) {
    const bubbleCount = Math.floor(this.timeRatio * 8) + 2
    
    for (let i = 0; i < bubbleCount; i++) {
      const bubbleX = centerX + (Math.random() - 0.5) * 80
      const bubbleY = waveTop + Math.random() * 20 - 10
      const bubbleRadius = Math.random() * 3 + 1
      
      this.context.beginPath()
      this.context.arc(bubbleX, bubbleY, bubbleRadius, 0, 2 * Math.PI)
      this.context.fillStyle = 'rgba(255, 255, 255, 0.6)'
      this.context.fill()
      
      // 气泡高光
      this.context.beginPath()
      this.context.arc(bubbleX - bubbleRadius * 0.3, bubbleY - bubbleRadius * 0.3, bubbleRadius * 0.3, 0, 2 * Math.PI)
      this.context.fillStyle = 'rgba(255, 255, 255, 0.9)'
      this.context.fill()
    }
  }
  
  private drawSparkles(centerX: number, waveTop: number) {
    const sparkleCount = 6
    
    for (let i = 0; i < sparkleCount; i++) {
      const sparkleX = centerX + (Math.random() - 0.5) * 60
      const sparkleY = waveTop + Math.sin((this.waveOffset + i * 60) * Math.PI / 180) * 8
      const sparkleSize = 3 + Math.sin((this.waveOffset + i * 90) * Math.PI / 180) * 2
      
      // 绘制十字形闪光
      this.context.strokeStyle = 'rgba(255, 255, 255, 0.8)'
      this.context.lineWidth = 1
      
      this.context.beginPath()
      this.context.moveTo(sparkleX - sparkleSize, sparkleY)
      this.context.lineTo(sparkleX + sparkleSize, sparkleY)
      this.context.moveTo(sparkleX, sparkleY - sparkleSize)
      this.context.lineTo(sparkleX, sparkleY + sparkleSize)
      this.context.stroke()
    }
  }
}