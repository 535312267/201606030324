import { drawing } from '@kit.ArkGraphics2D'
import { common } from '@kit.AbilityKit'
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'
import { promptAction } from '@kit.ArkUI'

export interface PathPoint {
  x: number
  y: number
}

export interface DrawingPath {
  points: PathPoint[]
  color: string
  width: number
}

@Component
export struct DrawingCanvas {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  
  @State private paths: DrawingPath[] = []
  @State private currentPath: PathPoint[] = []
  @State private isDrawing: boolean = false
  @State private strokeColor: string = '#000000'
  @State private strokeWidth: number = 3
  
  private canvasWidth: number = 0
  private canvasHeight: number = 0
  
  onCanvasReady?: (canvas: DrawingCanvas) => void

  aboutToAppear() {
    this.onCanvasReady?.(this)
  }

  build() {
    Column() {
      // 颜色选择器
      Row() {
        Text('画笔颜色:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 10 })

        ForEach(['#000000', '#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff'], (color: string) => {
          Circle({ width: 30, height: 30 })
            .fill(color)
            .border({ 
              width: this.strokeColor === color ? 3 : 1, 
              color: this.strokeColor === color ? '#007DFF' : '#cccccc' 
            })
            .margin({ right: 8 })
            .onClick(() => {
              this.strokeColor = color
            })
        })
      }
      .width('100%')
      .padding({ horizontal: 15, vertical: 10 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 画笔粗细选择
      Row() {
        Text('画笔粗细:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 10 })

        Slider({
          value: this.strokeWidth,
          min: 1,
          max: 20,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width(200)
          .blockColor('#007DFF')
          .trackColor('#cccccc')
          .selectedColor('#007DFF')
          .showTips(true)
          .onChange((value: number) => {
            this.strokeWidth = value
          })

        Text(`${this.strokeWidth}px`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 10 })
      }
      .width('100%')
      .padding({ horizontal: 15, vertical: 5 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 画布区域
      Canvas(this.context)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#ffffff')
        .border({ width: 1, color: '#e0e0e0', radius: 8 })
        .margin({ horizontal: 15, vertical: 10 })
        .onReady(() => {
          this.canvasWidth = this.context.width
          this.canvasHeight = this.context.height
          this.redrawCanvas()
        })
        .onTouch((event: TouchEvent) => {
          this.handleTouch(event)
        })
    }
    .width('100%')
    .height('100%')
  }

  private handleTouch(event: TouchEvent) {
    const touch = event.touches[0]
    const x = touch.x
    const y = touch.y

    switch (event.type) {
      case TouchType.Down:
        this.isDrawing = true
        this.currentPath = [{ x, y }]
        break

      case TouchType.Move:
        if (this.isDrawing) {
          this.currentPath.push({ x, y })
          this.drawCurrentPath()
        }
        break

      case TouchType.Up:
        if (this.isDrawing) {
          this.isDrawing = false
          if (this.currentPath.length > 1) {
            this.paths.push({
              points: [...this.currentPath],
              color: this.strokeColor,
              width: this.strokeWidth
            })
          }
          this.currentPath = []
        }
        break
    }
  }

  private drawCurrentPath() {
    if (this.currentPath.length < 2) return

    this.redrawCanvas()

    // 绘制当前正在画的路径
    this.context.strokeStyle = this.strokeColor
    this.context.lineWidth = this.strokeWidth
    this.context.lineCap = 'round'
    this.context.lineJoin = 'round'

    this.context.beginPath()
    const firstPoint = this.currentPath[0]
    this.context.moveTo(firstPoint.x, firstPoint.y)

    for (let i = 1; i < this.currentPath.length; i++) {
      const point = this.currentPath[i]
      this.context.lineTo(point.x, point.y)
    }

    this.context.stroke()
  }

  private redrawCanvas() {
    // 清空画布
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight)

    // 重绘所有路径
    for (const path of this.paths) {
      if (path.points.length < 2) continue

      this.context.strokeStyle = path.color
      this.context.lineWidth = path.width
      this.context.lineCap = 'round'
      this.context.lineJoin = 'round'

      this.context.beginPath()
      const firstPoint = path.points[0]
      this.context.moveTo(firstPoint.x, firstPoint.y)

      for (let i = 1; i < path.points.length; i++) {
        const point = path.points[i]
        this.context.lineTo(point.x, point.y)
      }

      this.context.stroke()
    }
  }

  public clearCanvas() {
    this.paths = []
    this.currentPath = []
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
    
    promptAction.showToast({
      message: '画布已清空',
      duration: 1500
    })
  }

  public undo() {
    if (this.paths.length > 0) {
      this.paths.pop()
      this.redrawCanvas()
      
      promptAction.showToast({
        message: '已撤销上一步操作',
        duration: 1500
      })
    }
  }

  public async saveDrawing(): Promise<string | null> {
    try {
      // 获取画布图像数据
      const imageData = this.context.getImageData(0, 0, this.canvasWidth, this.canvasHeight)
      
      // 创建图片
      const pixelMap = await image.createPixelMap(imageData.data, {
        size: { height: this.canvasHeight, width: this.canvasWidth },
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        editable: true
      })

      // 保存到文件
      const context = getContext(this) as common.UIAbilityContext
      const filesDir = context.filesDir
      const fileName = `drawing_${Date.now()}.png`
      const filePath = `${filesDir}/${fileName}`

      const imagePackerApi = image.createImagePacker()
      const packOpts: image.PackingOption = {
        format: "image/png",
        quality: 100
      }

      const imageData_packed = await imagePackerApi.packing(pixelMap, packOpts)
      await fileIo.write(fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE), imageData_packed)

      promptAction.showToast({
        message: `绘图已保存: ${fileName}`,
        duration: 2000
      })

      return filePath
    } catch (error) {
      console.error('保存绘图失败:', error)
      promptAction.showToast({
        message: '保存失败，请重试',
        duration: 2000
      })
      return null
    }
  }

  public getCanvasImageData(): ImageData | null {
    try {
      return this.context.getImageData(0, 0, this.canvasWidth, this.canvasHeight)
    } catch (error) {
      console.error('获取画布数据失败:', error)
      return null
    }
  }

  public getPathsData(): DrawingPath[] {
    return [...this.paths]
  }

  public loadPathsData(paths: DrawingPath[]) {
    this.paths = [...paths]
    this.redrawCanvas()
  }
}