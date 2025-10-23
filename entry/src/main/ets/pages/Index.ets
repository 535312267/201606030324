import { DrawingCanvas } from '../components/DrawingCanvas'
import { ImageUploader } from '../components/ImageUploader'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  @State currentTab: number = 0
  @State canvasRef: DrawingCanvas | null = null

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('鸿蒙绘图上传')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .height(60)
      .backgroundColor('#f8f9fa')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // Tab导航
      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          DrawingPage({ canvasRef: $canvasRef })
        }
        .tabBar(this.TabBuilder('绘制', 0, $r('app.media.icon_draw')))

        TabContent() {
          UploadPage({ canvasRef: this.canvasRef })
        }
        .tabBar(this.TabBuilder('上传', 1, $r('app.media.icon_upload')))
      }
      .width('100%')
      .height('100%')
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTab = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }

  @Builder TabBuilder(title: string, targetIndex: number, selectedImg: Resource) {
    Column() {
      Image(selectedImg)
        .size({ width: 25, height: 25 })
        .fillColor(this.currentTab === targetIndex ? '#007DFF' : '#999999')
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTab === targetIndex ? '#007DFF' : '#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct DrawingPage {
  @Link canvasRef: DrawingCanvas | null

  build() {
    Column() {
      // 绘制区域
      DrawingCanvas({ 
        onCanvasReady: (canvas: DrawingCanvas) => {
          this.canvasRef = canvas
        }
      })
        .width('100%')
        .layoutWeight(1)
        .margin({ top: 10, left: 10, right: 10 })
        .borderRadius(8)
        .backgroundColor('#f5f5f5')

      // 工具栏
      Row() {
        Button('清空')
          .fontSize(14)
          .backgroundColor('#ff6b6b')
          .fontColor('#ffffff')
          .borderRadius(20)
          .onClick(() => {
            this.canvasRef?.clearCanvas()
          })

        Button('撤销')
          .fontSize(14)
          .backgroundColor('#4ecdc4')
          .fontColor('#ffffff')
          .borderRadius(20)
          .onClick(() => {
            this.canvasRef?.undo()
          })

        Button('保存')
          .fontSize(14)
          .backgroundColor('#45b7d1')
          .fontColor('#ffffff')
          .borderRadius(20)
          .onClick(() => {
            this.canvasRef?.saveDrawing()
          })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#ffffff')
      .margin({ bottom: 10 })
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct UploadPage {
  @Prop canvasRef: DrawingCanvas | null

  build() {
    Column() {
      ImageUploader({ canvasRef: this.canvasRef })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}