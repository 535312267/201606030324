import { RecordViewData, MonthData, CalendarDay } from '../model/RecordModel';
import { DataService } from '../service/DataService';
import { CalendarUtils } from '../utils/CalendarUtils';

@Component
export struct CalendarComponent {
  @State private swiperIndex: number = 1; // 当前显示的页面索引（0, 1, 2）
  @State private monthsData: MonthData[] = []; // 三页的月份数据
  @State private isLoading: boolean = true;
  private dataService: DataService = DataService.getInstance();
  
  // 当前日期信息
  private currentDate: Date = new Date();
  private baseYear: number = this.currentDate.getFullYear();
  private baseMonth: number = this.currentDate.getMonth() + 1;

  aboutToAppear() {
    this.initializeCalendar();
  }

  /**
   * 初始化日历数据
   */
  private async initializeCalendar() {
    this.isLoading = true;
    
    // 初始化三个月的数据：上月、当月、下月
    const prevMonth = CalendarUtils.getPrevMonth(this.baseYear, this.baseMonth);
    const currentMonth = {year: this.baseYear, month: this.baseMonth};
    const nextMonth = CalendarUtils.getNextMonth(this.baseYear, this.baseMonth);
    
    // 并行获取三个月的数据
    const [prevData, currentData, nextData] = await Promise.all([
      this.dataService.getMonthData(prevMonth.year, prevMonth.month),
      this.dataService.getMonthData(currentMonth.year, currentMonth.month),
      this.dataService.getMonthData(nextMonth.year, nextMonth.month)
    ]);
    
    this.monthsData = [
      new MonthData(prevMonth.year, prevMonth.month, prevData),
      new MonthData(currentMonth.year, currentMonth.month, currentData),
      new MonthData(nextMonth.year, nextMonth.month, nextData)
    ];
    
    this.isLoading = false;
  }

  /**
   * 处理滑动事件
   * @param index 新的索引
   */
  private async onSwiperChange(index: number) {
    if (this.isLoading) return;
    
    const prevIndex = this.swiperIndex;
    this.swiperIndex = index;
    
    // 根据滑动方向更新数据
    if (prevIndex === 1 && index === 2) {
      // 向左滑动（显示下个月）
      await this.slideToNext();
    } else if (prevIndex === 1 && index === 0) {
      // 向右滑动（显示上个月）
      await this.slideToPrev();
    } else if (prevIndex === 2 && index === 0) {
      // 从最后一页滑动到第一页（循环滑动，显示下个月）
      await this.slideToNext();
    } else if (prevIndex === 0 && index === 2) {
      // 从第一页滑动到最后一页（循环滑动，显示上个月）
      await this.slideToPrev();
    }
  }

  /**
   * 滑动到下个月
   */
  private async slideToNext() {
    // 重新排列数据：[1, 2, new] -> [0, 1, 2]
    const currentMonth = this.monthsData[2];
    const nextMonth = CalendarUtils.getNextMonth(currentMonth.year, currentMonth.month);
    const nextData = await this.dataService.getMonthData(nextMonth.year, nextMonth.month);
    
    this.monthsData = [
      this.monthsData[1], // 原来的中间页变成左页
      this.monthsData[2], // 原来的右页变成中间页
      new MonthData(nextMonth.year, nextMonth.month, nextData) // 新的右页
    ];
    
    this.swiperIndex = 1; // 重置到中间页
  }

  /**
   * 滑动到上个月
   */
  private async slideToPrev() {
    // 重新排列数据：[new, 0, 1] -> [0, 1, 2]
    const currentMonth = this.monthsData[0];
    const prevMonth = CalendarUtils.getPrevMonth(currentMonth.year, currentMonth.month);
    const prevData = await this.dataService.getMonthData(prevMonth.year, prevMonth.month);
    
    this.monthsData = [
      new MonthData(prevMonth.year, prevMonth.month, prevData), // 新的左页
      this.monthsData[0], // 原来的左页变成中间页
      this.monthsData[1]  // 原来的中间页变成右页
    ];
    
    this.swiperIndex = 1; // 重置到中间页
  }

  build() {
    Column() {
      if (this.isLoading) {
        // 加载状态
        Row() {
          LoadingProgress()
            .width(30)
            .height(30)
          Text('加载中...')
            .margin({ left: 10 })
        }
        .justifyContent(FlexAlign.Center)
        .height(200)
      } else {
        // 月份标题
        Text(CalendarUtils.getMonthDisplayText(
          this.monthsData[this.swiperIndex]?.year || this.baseYear,
          this.monthsData[this.swiperIndex]?.month || this.baseMonth
        ))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        // 周标签
        Row() {
          ForEach(CalendarUtils.getWeekLabels(), (label: string, index: number) => {
            Text(label)
              .fontSize(14)
              .fontColor('#666666')
              .width('14.28%')
              .textAlign(TextAlign.Center)
          })
        }
        .width('100%')
        .margin({ bottom: 8 })

        // Swiper容器
        Swiper() {
          ForEach(this.monthsData, (monthData: MonthData, index: number) => {
            this.buildMonthView(monthData)
          })
        }
        .width('100%')
        .height(300)
        .index(this.swiperIndex)
        .loop(true)
        .indicator(false)
        .onChange((index: number) => {
          this.onSwiperChange(index);
        })
      }
    }
    .width('100%')
    .padding(16)
  }

  /**
   * 构建单个月份视图
   * @param monthData 月份数据
   * @returns 月份视图组件
   */
  @Builder
  private buildMonthView(monthData: MonthData) {
    Column() {
      Grid() {
        ForEach(CalendarUtils.getCalendarDays(monthData.year, monthData.month, monthData.records), 
          (day: CalendarDay, index: number) => {
            GridItem() {
              this.buildDayItem(day)
            }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(4)
      .width('100%')
    }
  }

  /**
   * 构建单日组件
   * @param day 日期数据
   * @returns 单日组件
   */
  @Builder
  private buildDayItem(day: CalendarDay) {
    Stack() {
      // 背景圆圈（根据生理状态显示不同颜色）
      if (day.record && day.isCurrentMonth) {
        Circle()
          .width(32)
          .height(32)
          .fill(CalendarUtils.getStatusColor(day.record.physiologyStatus))
          .opacity(0.3)
      }

      // 日期文字
      Text(day.date.toString())
        .fontSize(14)
        .fontColor(day.isCurrentMonth ? '#000000' : '#CCCCCC')
        .fontWeight(day.record?.todayFlag ? FontWeight.Bold : FontWeight.Normal)

      // 今日标记
      if (day.record?.todayFlag) {
        Circle()
          .width(6)
          .height(6)
          .fill('#FF4444')
          .position({ x: '70%', y: '20%' })
      }

      // 预测标记
      if (day.record?.predictFlag && day.isCurrentMonth) {
        Text('预')
          .fontSize(8)
          .fontColor('#FF6B6B')
          .position({ x: '70%', y: '70%' })
      }
    }
    .width(40)
    .height(40)
    .onClick(() => {
      if (day.isCurrentMonth && day.record) {
        this.onDayClick(day);
      }
    })
  }

  /**
   * 处理日期点击事件
   * @param day 被点击的日期
   */
  private onDayClick(day: CalendarDay) {
    console.log('点击日期:', day.date, '记录:', day.record);
    // 这里可以添加点击日期的处理逻辑
  }
}