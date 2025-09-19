import { DatePickerComponent, DatePickerConfig } from './DatePickerComponent';

@Entry
@Component
struct DatePickerExample {
  @State private selectedDates: number[] = [];
  @State private datePickerConfig: DatePickerConfig = {};
  @State private networkData: number[] = [];
  
  aboutToAppear() {
    this.initializeDatePicker();
    this.simulateNetworkRequest();
  }
  
  // 初始化日期选择器配置
  private initializeDatePicker() {
    this.datePickerConfig = {
      // 设置默认选中范围（示例：选中当前日期前后3天）
      defaultSelectedRange: [
        Date.now() - 3 * 24 * 60 * 60 * 1000, // 3天前
        Date.now() + 3 * 24 * 60 * 60 * 1000  // 3天后
      ],
      // 未来日期的选中状态
      futureSelectedState: true,
      // 网络数据加载回调
      onDataLoad: (timestamps: number[]) => {
        console.log('Network data loaded:', timestamps);
        this.networkData = timestamps;
      }
    };
  }
  
  // 模拟网络请求
  private async simulateNetworkRequest() {
    // 模拟延迟
    setTimeout(() => {
      // 模拟服务器返回的时间戳数据
      const mockData = [
        new Date(2025, 8, 1).getTime(),  // 2025年9月1日
        new Date(2025, 8, 3).getTime(),  // 2025年9月3日
        new Date(2025, 8, 5).getTime(),  // 2025年9月5日
        new Date(2025, 8, 10).getTime(), // 2025年9月10日
      ];
      
      // 更新配置以触发组件重新加载数据
      this.updateConfigWithNetworkData(mockData);
    }, 2000);
  }
  
  // 使用网络数据更新配置
  private updateConfigWithNetworkData(networkData: number[]) {
    const newConfig: DatePickerConfig = {
      selectableDates: this.datePickerConfig.selectableDates,
      defaultSelectedRange: this.datePickerConfig.defaultSelectedRange,
      futureSelectedState: this.datePickerConfig.futureSelectedState,
      onDataLoad: (timestamps: number[]) => {
        console.log('Network data updated:', timestamps);
        this.networkData = timestamps;
      }
    };
    this.datePickerConfig = newConfig;
  }
  
  // 处理选中日期变化
  private handleSelectedDatesChange = (dates: number[]) => {
    this.selectedDates = dates;
    console.log('Selected dates changed:', dates);
    
    // 可以在这里调用API保存数据
    // this.saveSelectedDatesToServer(dates);
  }
  
  // 清除所有选择
  private clearAllSelection = () => {
    const newConfig: DatePickerConfig = {
      selectableDates: this.datePickerConfig.selectableDates,
      futureSelectedState: this.datePickerConfig.futureSelectedState,
      onDataLoad: this.datePickerConfig.onDataLoad,
      defaultSelectedRange: undefined
    };
    this.datePickerConfig = newConfig;
    this.selectedDates = [];
  }
  
  // 设置预设范围
  private setPresetRange = (days: number) => {
    const now = Date.now();
    const newConfig: DatePickerConfig = {
      selectableDates: this.datePickerConfig.selectableDates,
      futureSelectedState: this.datePickerConfig.futureSelectedState,
      onDataLoad: this.datePickerConfig.onDataLoad,
      defaultSelectedRange: [
        now,
        now + days * 24 * 60 * 60 * 1000
      ]
    };
    this.datePickerConfig = newConfig;
  }
  
  // 格式化日期显示
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('经期记录示例')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Blank()
        
        Button('清除')
          .backgroundColor(Color.Transparent)
          .fontColor(Color.White)
          .border({ width: 1, color: Color.White, radius: 16 })
          .onClick(this.clearAllSelection)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FF69B4')
      
      // 快捷操作按钮
      Row() {
        Button('今天')
          .fontSize(12)
          .backgroundColor('#FFB6C1')
          .fontColor(Color.White)
          .onClick(() => this.setPresetRange(1))
        
        Button('未来3天')
          .fontSize(12)
          .backgroundColor('#FFB6C1')
          .fontColor(Color.White)
          .margin({ left: 8 })
          .onClick(() => this.setPresetRange(3))
        
        Button('未来7天')
          .fontSize(12)
          .backgroundColor('#FFB6C1')
          .fontColor(Color.White)
          .margin({ left: 8 })
          .onClick(() => this.setPresetRange(7))
        
        Blank()
        
        Text(`网络数据: ${this.networkData.length}条`)
          .fontSize(12)
          .fontColor('#666')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')
      
      // 日期选择器组件
      DatePickerComponent({
        config: this.datePickerConfig,
        onSelectedDatesChange: this.handleSelectedDatesChange
      })
        .layoutWeight(1)
      
      // 选中日期详情
      if (this.selectedDates.length > 0) {
        Column() {
          Text('已选择的日期:')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
            .alignSelf(ItemAlign.Start)
          
          // 显示前5个选中的日期
          Column() {
            ForEach(this.selectedDates.slice(0, 5), (timestamp: number, index: number) => {
              Text(`${index + 1}. ${this.formatDate(timestamp)}`)
                .fontSize(12)
                .fontColor('#666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 2 })
            }, (timestamp: number) => timestamp.toString())
            
            if (this.selectedDates.length > 5) {
              Text(`... 还有 ${this.selectedDates.length - 5} 个日期`)
                .fontSize(12)
                .fontColor('#999')
                .alignSelf(ItemAlign.Start)
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .border({ width: 1, color: '#E5E5E5' })
      }
      
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
          .enabled(this.selectedDates.length > 0)
          .onClick(() => {
            // 保存选中的日期
            console.log('Saving selected dates:', this.selectedDates);
            
            // 这里可以调用实际的API
            // this.saveToServer(this.selectedDates);
            
            // 显示保存成功提示
            // AlertDialog.show({ message: '保存成功！' });
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
  
  // 实际项目中的API调用示例
  // private async saveToServer(dates: number[]) {
  //   try {
  //     const response = await fetch('/api/save-dates', {
  //       method: 'POST',
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: JSON.stringify({ dates })
  //     });
  //     
  //     if (response.ok) {
  //       console.log('保存成功');
  //     } else {
  //       console.error('保存失败');
  //     }
  //   } catch (error) {
  //     console.error('网络错误:', error);
  //   }
  // }
}