import { DatePickerComponent, DatePickerConfig } from './DatePickerComponent';

@Entry
@Component
struct TestDatePicker {
  @State private selectedDates: number[] = [];
  @State private datePickerConfig: DatePickerConfig = {};
  
  aboutToAppear() {
    // 简单的测试配置
    this.datePickerConfig = {
      // 默认选择今天
      defaultSelectedRange: [
        Date.now(),
        Date.now()
      ],
      futureSelectedState: true,
      onDataLoad: (timestamps: number[]) => {
        console.log('Test: Network data loaded:', timestamps);
      }
    };
  }
  
  private handleSelectedDatesChange = (dates: number[]) => {
    this.selectedDates = dates;
    console.log('Test: Selected dates changed:', dates.length);
  }
  
  build() {
    Column() {
      // 简单的标题
      Text('日期选择器测试')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .padding(16)
      
      // 显示选中数量
      Text(`已选择: ${this.selectedDates.length} 天`)
        .fontSize(16)
        .fontColor('#666')
        .padding({ bottom: 16 })
      
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