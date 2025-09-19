import { DatePickerComponent, DatePickerConfig } from './DatePickerComponent';

@Entry
@Component
struct Index {
  @State private selectedDates: number[] = [];
  @State private datePickerConfig: DatePickerConfig = {};
  
  aboutToAppear() {
    // 配置日期选择器
    this.datePickerConfig = {
      // 设置默认选中范围（示例：选中未来7天）
      defaultSelectedRange: [
        Date.now(),
        Date.now() + 7 * 24 * 60 * 60 * 1000
      ],
      // 未来日期的选中状态（true表示未来日期如果在选中范围内可以显示选中状态）
      futureSelectedState: true,
      // 网络数据加载回调
      onDataLoad: (timestamps: number[]) => {
        console.log('Network data loaded:', timestamps);
        // 可以在这里处理网络数据
      }
    };
  }
  
  // 处理选中日期变化
  private handleSelectedDatesChange = (dates: number[]) => {
    this.selectedDates = dates;
    console.log('Selected dates changed:', dates);
  }
  
  // 清除选择
  private clearSelection = () => {
    // 通过更新配置来清除选择
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
        Text('经期记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Blank()
        
        Button('清除选择')
          .backgroundColor(Color.Transparent)
          .fontColor(Color.White)
          .border({ width: 1, color: Color.White, radius: 16 })
          .onClick(this.clearSelection)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FF69B4')
      
      // 日期选择器组件
      DatePickerComponent({
        config: this.datePickerConfig,
        onSelectedDatesChange: this.handleSelectedDatesChange
      })
        .layoutWeight(1)
      
      // 底部操作栏
      Row() {
        Column() {
          Text('已选择日期')
            .fontSize(12)
            .fontColor('#666')
          Text(`${this.selectedDates.length} 天`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF69B4')
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        Button('保存')
          .backgroundColor('#FF69B4')
          .fontColor(Color.White)
          .borderRadius(20)
          .padding({ left: 24, right: 24 })
          .onClick(() => {
            // 保存选中的日期
            console.log('Selected dates:', this.selectedDates);
            // 这里可以调用API保存数据
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: 1, color: '#E5E5E5' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}