/**
 * 主页面 - 展示刻度尺组件使用示例
 */

import { RulerComponent } from '../components/RulerComponent'

@Entry
@Component
struct Index {
  build() {
    Column() {
      // 页面标题
      Text('鸿蒙刻度尺组件示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50, bottom: 30 })
      
      // 刻度尺组件
      RulerComponent()
        .margin({ top: 20, bottom: 20 })
      
      // 使用说明
      Text('滑动刻度尺查看不同数值')
        .fontSize(16)
        .fontColor(Color.Gray)
        .margin({ top: 20 })
      
      Text('红线指示当前选中的刻度值')
        .fontSize(14)
        .fontColor(Color.Gray)
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#f5f5f5')
  }
}