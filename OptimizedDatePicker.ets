import { DatePickerComponent, DatePickerConfig } from './DatePickerComponent';

@Entry
@Component
struct OptimizedDatePicker {
  @State private selectedDates: number[] = [];
  @State private datePickerConfig: DatePickerConfig = {};
  @State private loadingStatus: string = '';
  
  aboutToAppear() {
    this.datePickerConfig = {
      // 默认选择今天
      defaultSelectedRange: [
        Date.now(),
        Date.now()
      ],
      futureSelectedState: true,
      onDataLoad: (timestamps: number[]) => {
        console.log('Optimized: Network data loaded:', timestamps.length);
        this.loadingStatus = `加载了 ${timestamps.length} 条网络数据`;
        
        // 模拟清除状态
        setTimeout(() => {
          this.loadingStatus = '';
        }, 2000);
      }
    };
  }
  
  private handleSelectedDatesChange = (dates: number[]) => {
    this.selectedDates = dates;
    console.log('Optimized: Selected dates changed:', dates.length);
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
  
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}/${date.getDate()}`;
  }
  
  build() {
    Column() {
      // 性能优化版标题
      Row() {
        Text('优化版日期选择器')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Blank()
        
        Button('清除')
          .backgroundColor(Color.Transparent)
          .fontColor(Color.White)
          .fontSize(14)
          .border({ width: 1, color: Color.White, radius: 12 })
          .onClick(this.clearSelection)
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FF69B4')
      
      // 状态信息
      Row() {
        Column() {
          Text(`已选择: ${this.selectedDates.length} 天`)
            .fontSize(14)
            .fontColor('#333')
          
          if (this.loadingStatus) {
            Text(this.loadingStatus)
              .fontSize(12)
              .fontColor('#666')
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        // 显示最近选中的日期
        if (this.selectedDates.length > 0) {
          Text(`最新: ${this.formatDate(this.selectedDates[this.selectedDates.length - 1])}`)
            .fontSize(12)
            .fontColor('#FF69B4')
        }
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F5F5F5')
      
      // 优化后的日期选择器
      DatePickerComponent({
        config: this.datePickerConfig,
        onSelectedDatesChange: this.handleSelectedDatesChange
      })
        .layoutWeight(1)
      
      // 底部提示
      Row() {
        Text('💡 优化说明: 提前加载数据、缓存机制、异步处理')
          .fontSize(12)
          .fontColor('#666')
      }
      .width('100%')
      .padding(8)
      .backgroundColor('#FFFACD')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}