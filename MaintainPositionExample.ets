import { DatePickerComponent, DatePickerConfig } from './DatePickerComponent';

@Entry
@Component
struct MaintainPositionExample {
  @State private selectedDates: number[] = [];
  @State private datePickerConfig: DatePickerConfig = {};
  @State private loadInfo: string = '';
  
  aboutToAppear() {
    this.datePickerConfig = {
      // 默认选择今天
      defaultSelectedRange: [
        Date.now(),
        Date.now()
      ],
      futureSelectedState: true,
      onDataLoad: (timestamps: number[]) => {
        console.log('MaintainPosition: Network data loaded:', timestamps.length);
        this.loadInfo = `网络数据: ${timestamps.length} 条`;
      }
    };
  }
  
  private handleSelectedDatesChange = (dates: number[]) => {
    this.selectedDates = dates;
    console.log('MaintainPosition: Selected dates changed:', dates.length);
  }
  
  private clearSelection = () => {
    const newConfig: DatePickerConfig = {
      selectableDates: this.datePickerConfig.selectableDates,
      futureSelectedState: this.datePickerConfig.futureSelectedState,
      onDataLoad: this.datePickerConfig.onDataLoad,
      defaultSelectedRange: undefined
    };
    this.datePickerConfig = newConfig;
    this.selectedDates = [];
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Column() {
          Text('位置保持示例')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text('maintainVisibleContentPosition')
            .fontSize(12)
            .fontColor('#FFE4E1')
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        Button('清除')
          .backgroundColor(Color.Transparent)
          .fontColor(Color.White)
          .fontSize(14)
          .border({ width: 1, color: Color.White, radius: 12 })
          .onClick(this.clearSelection)
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FF69B4')
      
      // 功能说明
      Column() {
        Text('🎯 功能特点:')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 4 })
        
        Text('• 向下滑动自动加载历史月份')
          .fontSize(12)
          .fontColor('#666')
          .alignSelf(ItemAlign.Start)
        
        Text('• 加载时保持当前显示位置不变')
          .fontSize(12)
          .fontColor('#666')
          .alignSelf(ItemAlign.Start)
        
        Text('• 无缝的用户体验，无跳跃感')
          .fontSize(12)
          .fontColor('#666')
          .alignSelf(ItemAlign.Start)
        
        // 状态信息
        Row() {
          Text(`已选择: ${this.selectedDates.length} 天`)
            .fontSize(12)
            .fontColor('#FF69B4')
          
          if (this.loadInfo) {
            Text(this.loadInfo)
              .fontSize(12)
              .fontColor('#999')
              .margin({ left: 16 })
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F9F9F9')
      .alignItems(HorizontalAlign.Start)
      
      // 日期选择器组件
      DatePickerComponent({
        config: this.datePickerConfig,
        onSelectedDatesChange: this.handleSelectedDatesChange
      })
        .layoutWeight(1)
      
      // 底部提示
      Row() {
        Text('💡 试试向下滑动到顶部，观察数据加载时位置是否保持不变')
          .fontSize(12)
          .fontColor('#666')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFACD')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}