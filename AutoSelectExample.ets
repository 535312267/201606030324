import { DatePickerComponent, DatePickerConfig } from './DatePickerComponent';

@Entry
@Component
struct AutoSelectExample {
  @State private selectedDates: number[] = [];
  @State private datePickerConfig: DatePickerConfig = {};
  @State private currentMode: string = '普通模式';
  @State private autoSelectDays: number = 5;
  
  aboutToAppear() {
    this.updateConfig();
  }
  
  private updateConfig() {
    this.datePickerConfig = {
      // 默认选择今天
      defaultSelectedRange: [
        Date.now(),
        Date.now()
      ],
      futureSelectedState: true,
      // 自动选中后续天数
      autoSelectDays: this.autoSelectDays,
      // 智能选择模式
      smartSelectionMode: this.currentMode === '智能模式',
      onDataLoad: (timestamps: number[]) => {
        console.log('AutoSelect: Network data loaded:', timestamps.length);
      }
    };
  }
  
  private handleSelectedDatesChange = (dates: number[]) => {
    this.selectedDates = dates;
    console.log('AutoSelect: Selected dates changed:', dates.length);
  }
  
  private switchMode = () => {
    this.currentMode = this.currentMode === '普通模式' ? '智能模式' : '普通模式';
    this.updateConfig();
  }
  
  private changeDays = (days: number) => {
    this.autoSelectDays = days;
    this.updateConfig();
  }
  
  private clearSelection = () => {
    const newConfig: DatePickerConfig = {
      selectableDates: this.datePickerConfig.selectableDates,
      futureSelectedState: this.datePickerConfig.futureSelectedState,
      onDataLoad: this.datePickerConfig.onDataLoad,
      autoSelectDays: this.datePickerConfig.autoSelectDays,
      smartSelectionMode: this.datePickerConfig.smartSelectionMode,
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
      // 标题栏
      Row() {
        Column() {
          Text('自动选择示例')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text(`${this.currentMode} | ${this.autoSelectDays}天`)
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
      
      // 控制面板
      Column() {
        // 模式切换
        Row() {
          Text('选择模式:')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Button(this.currentMode)
            .backgroundColor('#FF69B4')
            .fontColor(Color.White)
            .fontSize(12)
            .borderRadius(16)
            .padding({ left: 12, right: 12 })
            .onClick(this.switchMode)
        }
        .width('100%')
        .margin({ bottom: 8 })
        
        // 天数选择
        Row() {
          Text('自动选中天数:')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Row() {
            ForEach([3, 5, 7], (days: number) => {
              Button(days.toString())
                .backgroundColor(this.autoSelectDays === days ? '#FF69B4' : '#E0E0E0')
                .fontColor(this.autoSelectDays === days ? Color.White : '#666')
                .fontSize(12)
                .borderRadius(12)
                .padding({ left: 8, right: 8 })
                .margin({ left: 4 })
                .onClick(() => this.changeDays(days))
            })
          }
        }
        .width('100%')
        .margin({ bottom: 8 })
        
        // 功能说明
        Column() {
          Text('💡 功能说明:')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
          
          if (this.currentMode === '普通模式') {
            Text(`• 点击日期自动选中后续 ${this.autoSelectDays} 天`)
              .fontSize(11)
              .fontColor('#666')
              .alignSelf(ItemAlign.Start)
            Text('• 点击已选中日期取消连续选中的范围')
              .fontSize(11)
              .fontColor('#666')
              .alignSelf(ItemAlign.Start)
          } else {
            Text('• 点击日期智能选中到最近的已选日期')
              .fontSize(11)
              .fontColor('#666')
              .alignSelf(ItemAlign.Start)
            Text('• 点击已选日期取消整个连续范围')
              .fontSize(11)
              .fontColor('#666')
              .alignSelf(ItemAlign.Start)
          }
        }
        .alignItems(HorizontalAlign.Start)
        
        // 状态显示
        Row() {
          Text(`已选择: ${this.selectedDates.length} 天`)
            .fontSize(12)
            .fontColor('#FF69B4')
          
          if (this.selectedDates.length > 0) {
            Text(`最新: ${this.formatDate(this.selectedDates[this.selectedDates.length - 1])}`)
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
      
      // 选中日期详情
      if (this.selectedDates.length > 0) {
        Column() {
          Text('选中的日期:')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
            .alignSelf(ItemAlign.Start)
          
          // 显示选中的日期（按时间排序）
          Scroll() {
            Row() {
              ForEach(this.selectedDates.sort((a, b) => a - b).slice(0, 10), (timestamp: number, index: number) => {
                Text(this.formatDate(timestamp))
                  .fontSize(12)
                  .fontColor(Color.White)
                  .backgroundColor('#FF69B4')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)
                  .margin({ right: 4 })
              }, (timestamp: number) => timestamp.toString())
              
              if (this.selectedDates.length > 10) {
                Text(`+${this.selectedDates.length - 10}`)
                  .fontSize(12)
                  .fontColor('#666')
                  .backgroundColor('#E0E0E0')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)
              }
            }
            .alignItems(VerticalAlign.Center)
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .alignItems(HorizontalAlign.Start)
      }
      
      // 底部提示
      Row() {
        Text('🎯 试试点击不同的日期，体验自动选择功能')
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