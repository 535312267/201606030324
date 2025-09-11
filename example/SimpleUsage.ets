// 简单使用示例
import { CalendarPage } from '../src/main/ets/pages/CalendarPage';

@Entry
@Component
struct MainPage {
  build() {
    Navigation() {
      CalendarPage()
    }
    .title('月历应用')
    .titleMode(NavigationTitleMode.Mini)
  }
}

// 如果需要单独使用月历组件
import { MonthCalendar } from '../src/main/ets/components/MonthCalendar';
import { recordViewData, PhysiologyStatus } from '../src/main/ets/models/RecordModels';

@Component
struct CustomCalendarPage {
  @State currentYearMonth: string = '202409';
  @State records: recordViewData[] = [];

  aboutToAppear() {
    this.loadSampleData();
  }

  // 加载示例数据
  loadSampleData() {
    const sampleRecords: recordViewData[] = [];
    
    // 创建一些示例数据
    for (let day = 1; day <= 30; day++) {
      const record = new recordViewData();
      const date = new Date(2024, 8, day); // 2024年9月
      record.dateInfo = date.getTime();
      record.todayFlag = day === 15; // 假设15号是今天
      
      // 设置一些生理状态
      if (day >= 5 && day <= 9) {
        record.physiologyStatus = PhysiologyStatus.MENSTRUATION;
      } else if (day === 18) {
        record.physiologyStatus = PhysiologyStatus.OVULATION;
      } else if (day >= 16 && day <= 20) {
        record.physiologyStatus = PhysiologyStatus.FERTILE;
      } else if (day >= 25 && day <= 28) {
        record.physiologyStatus = PhysiologyStatus.PREDICTED;
        record.predictFlag = true;
      }
      
      sampleRecords.push(record);
    }
    
    this.records = sampleRecords;
  }

  build() {
    Column() {
      Text('自定义月历示例')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })
      
      MonthCalendar({
        yearMonth: this.currentYearMonth,
        records: this.records
      })
      
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}