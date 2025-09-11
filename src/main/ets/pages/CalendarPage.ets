import { CalendarComponent } from '../view/CalendarComponent';

@Entry
@Component
struct CalendarPage {
  build() {
    Column() {
      // 页面标题
      Row() {
        Text('生理周期日历')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')

      // 日历组件
      CalendarComponent()
        .layoutWeight(1)

      // 底部说明
      Column() {
        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill('#FF6B6B')
            .opacity(0.3)
          Text('经期')
            .fontSize(12)
            .margin({ left: 4 })
        }
        .margin({ bottom: 4 })

        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill('#4ECDC4')
            .opacity(0.3)
          Text('安全期')
            .fontSize(12)
            .margin({ left: 4 })
        }
        .margin({ bottom: 4 })

        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill('#45B7D1')
            .opacity(0.3)
          Text('排卵期')
            .fontSize(12)
            .margin({ left: 4 })
        }
        .margin({ bottom: 4 })

        Row() {
          Text('预')
            .fontSize(8)
            .fontColor('#FF6B6B')
            .width(12)
            .height(12)
            .textAlign(TextAlign.Center)
          Text('预测期')
            .fontSize(12)
            .margin({ left: 4 })
        }
      }
      .padding({ horizontal: 16, vertical: 12 })
      .backgroundColor('#F8F8F8')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}