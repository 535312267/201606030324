import { DatePickerComponent, DatePickerConfig } from './DatePickerComponent';

@Entry
@Component
struct TestAutoSelect {
  @State private selectedDates: number[] = [];
  @State private datePickerConfig: DatePickerConfig = {};
  
  aboutToAppear() {
    // 测试自动选择功能
    this.datePickerConfig = {
      // 点击日期自动选中后续3天
      autoSelectDays: 3,
      // 启用智能选择模式
      smartSelectionMode: false,
      futureSelectedState: true,
      onDataLoad: (timestamps: number[]) => {
        console.log('TestAutoSelect: Network data loaded:', timestamps.length);
      }
    };
  }
  
  private handleSelectedDatesChange = (dates: number[]) => {
    this.selectedDates = dates;
    console.log('TestAutoSelect: Selected dates changed:', dates.length);
  }
  
  private toggleMode = () => {
    const newConfig: DatePickerConfig = {
      autoSelectDays: this.datePickerConfig.autoSelectDays,
      smartSelectionMode: !this.datePickerConfig.smartSelectionMode,
      futureSelectedState: this.datePickerConfig.futureSelectedState,
      onDataLoad: this.datePickerConfig.onDataLoad
    };
    this.datePickerConfig = newConfig;
  }
  
  build() {
    Column() {
      // 简单的控制界面
      Row() {
        Text('自动选择测试')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Button(this.datePickerConfig.smartSelectionMode ? '智能模式' : '普通模式')
          .backgroundColor('#FF69B4')
          .fontColor(Color.White)
          .fontSize(14)
          .borderRadius(16)
          .onClick(this.toggleMode)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')
      
      // 状态显示
      Text(`已选择 ${this.selectedDates.length} 天 | 自动选中 ${this.datePickerConfig.autoSelectDays} 天`)
        .fontSize(14)
        .fontColor('#666')
        .padding(8)
      
      // 日期选择器
      DatePickerComponent({
        config: this.datePickerConfig,
        onSelectedDatesChange: this.handleSelectedDatesChange
      })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}