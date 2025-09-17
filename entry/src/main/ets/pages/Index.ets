import { RulerComponent, RulerOptions } from '../components/RulerComponent';
import { InteractiveRulerComponent, InteractiveRulerOptions } from '../components/InteractiveRulerComponent';

@Entry
@Component
struct Index {
  @State selectedValue: number = 50;

  build() {
    Column() {
      // 页面标题
      Text('鸿蒙刻度尺组件演示')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 30 })

      // 水平刻度尺示例
      Column() {
        Text('水平刻度尺 (0-100)')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 10 })
          .alignSelf(ItemAlign.Start)

        RulerComponent({
          options: {
            width: '90%',
            height: 60,
            direction: 'horizontal',
            minValue: 0,
            maxValue: 100,
            step: 1,
            majorStep: 10,
            showLabels: true,
            backgroundColor: '#f5f5f5',
            rulerColor: '#333333',
            textColor: '#666666',
            fontSize: 12,
            majorTickHeight: 20,
            minorTickHeight: 10
          } as RulerOptions
        })
      }
      .width('100%')
      .margin({ bottom: 40 })

      // 精密刻度尺示例
      Column() {
        Text('精密刻度尺 (0-50, 步长0.5)')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 10 })
          .alignSelf(ItemAlign.Start)

        RulerComponent({
          options: {
            width: '90%',
            height: 80,
            direction: 'horizontal',
            minValue: 0,
            maxValue: 50,
            step: 0.5,
            majorStep: 5,
            showLabels: true,
            backgroundColor: '#ffffff',
            rulerColor: '#2196F3',
            textColor: '#2196F3',
            fontSize: 14,
            majorTickHeight: 25,
            minorTickHeight: 15,
            rulerWidth: 2
          } as RulerOptions
        })
      }
      .width('100%')
      .margin({ bottom: 40 })

      // 垂直刻度尺示例
      Row() {
        Column() {
          Text('垂直刻度尺')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })

          RulerComponent({
            options: {
              width: 80,
              height: 300,
              direction: 'vertical',
              minValue: 0,
              maxValue: 200,
              step: 5,
              majorStep: 20,
              showLabels: true,
              backgroundColor: '#fafafa',
              rulerColor: '#4CAF50',
              textColor: '#4CAF50',
              fontSize: 12,
              majorTickHeight: 25,
              minorTickHeight: 12
            } as RulerOptions
          })
        }

        Column() {
          Text('自定义样式垂直尺')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })

          RulerComponent({
            options: {
              width: 100,
              height: 300,
              direction: 'vertical',
              minValue: -50,
              maxValue: 150,
              step: 2,
              majorStep: 25,
              showLabels: true,
              backgroundColor: '#f0f0f0',
              rulerColor: '#FF5722',
              textColor: '#FF5722',
              fontSize: 11,
              majorTickHeight: 30,
              minorTickHeight: 15,
              rulerWidth: 1.5
            } as RulerOptions
          })
        }
        .margin({ left: 40 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 40 })

      // 交互式刻度尺演示
      Column() {
        Text('交互式刻度尺')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        // 水平交互式刻度尺
        Column() {
          Text('可点击和拖拽的水平刻度尺')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })
            .alignSelf(ItemAlign.Start)

          InteractiveRulerComponent({
            options: {
              width: '90%',
              height: 80,
              direction: 'horizontal',
              minValue: 0,
              maxValue: 100,
              step: 1,
              majorStep: 10,
              showLabels: true,
              backgroundColor: '#f0f8ff',
              rulerColor: '#333333',
              selectedColor: '#FF6B35',
              textColor: '#666666',
              pointerColor: '#FF6B35',
              fontSize: 12,
              majorTickHeight: 25,
              minorTickHeight: 12,
              showPointer: true,
              enableTouch: true,
              onValueChange: (value: number) => {
                console.log('水平刻度尺值变化:', value);
              }
            } as InteractiveRulerOptions
          })
        }
        .width('100%')
        .margin({ bottom: 30 })

        // 垂直交互式刻度尺
        Row() {
          InteractiveRulerComponent({
            options: {
              width: 120,
              height: 250,
              direction: 'vertical',
              minValue: -20,
              maxValue: 80,
              step: 2,
              majorStep: 20,
              showLabels: true,
              backgroundColor: '#fff5f5',
              rulerColor: '#666666',
              selectedColor: '#E91E63',
              textColor: '#666666',
              pointerColor: '#E91E63',
              fontSize: 11,
              majorTickHeight: 30,
              minorTickHeight: 15,
              showPointer: true,
              enableTouch: true,
              onValueChange: (value: number) => {
                console.log('垂直刻度尺值变化:', value);
              }
            } as InteractiveRulerOptions
          })

          Column() {
            Text('交互式垂直刻度尺')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 10 })

            Text('• 支持触摸选择\n• 实时值反馈\n• 按钮微调\n• 回调事件')
              .fontSize(12)
              .lineHeight(18)
              .fontColor('#666666')
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 20 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .margin({ bottom: 40 })

      // 使用说明
      Column() {
        Text('组件特性')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 15 })

        Text('基础刻度尺：\n• 支持水平和垂直方向\n• 可自定义刻度间距和样式\n• 支持主刻度和次刻度\n• 可配置颜色、字体大小等\n• 支持负数范围\n• 响应式布局\n\n交互式刻度尺：\n• 支持触摸点击选择\n• 支持拖拽操作\n• 实时数值显示\n• 按钮精确调节\n• 值变化回调事件')
          .fontSize(14)
          .lineHeight(22)
          .fontColor('#666666')
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#f9f9f9')
      .borderRadius(8)

    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .backgroundColor('#ffffff')
  }
}