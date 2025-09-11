import { recordViewData, CalendarDay, WeekInfo, PhysiologyStatus } from '../models/RecordModels';
import { AppConfig } from '../config/AppConfig';
import { DateUtils } from '../utils/DateUtils';

@Component
export struct MonthCalendar {
  @Prop yearMonth: string; // YYYYMM格式
  @Prop records: recordViewData[];
  @State weeks: WeekInfo[] = [];
  @State currentDate: Date = new Date();

  // 周标签
  private weekLabels: string[] = ['日', '一', '二', '三', '四', '五', '六'];

  aboutToAppear() {
    this.generateCalendar();
  }

  // 当props更新时重新生成日历
  onPageShow() {
    this.generateCalendar();
  }

  // 生成日历数据
  generateCalendar() {
    if (!this.yearMonth || this.yearMonth.length !== 6) return;

    const year = parseInt(this.yearMonth.substring(0, 4));
    const month = parseInt(this.yearMonth.substring(4, 6)) - 1; // month is 0-based

    // 获取当月第一天和最后一天
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    
    // 获取当月第一天是周几
    const firstDayOfWeek = firstDay.getDay();
    
    // 计算需要显示的天数
    const daysInMonth = lastDay.getDate();
    
    const weeks: WeekInfo[] = [];
    let currentWeek: CalendarDay[] = [];
    
    // 填充第一周的空白天数（如果需要）
    for (let i = 0; i < firstDayOfWeek; i++) {
      currentWeek.push({
        day: 0,
        date: new Date(),
        isCurrentMonth: false,
        isToday: false
      });
    }
    
    // 填充当月的天数
    for (let day = 1; day <= daysInMonth; day++) {
      const currentDate = new Date(year, month, day);
      const isToday = this.isToday(currentDate);
      
      // 查找对应的记录数据
      const record = this.findRecordForDate(currentDate);
      
      const calendarDay: CalendarDay = {
        day: day,
        date: currentDate,
        record: record,
        isCurrentMonth: true,
        isToday: isToday
      };
      
      currentWeek.push(calendarDay);
      
      // 如果当前周已满7天，开始新的一周
      if (currentWeek.length === 7) {
        weeks.push({ days: [...currentWeek] });
        currentWeek = [];
      }
    }
    
    // 填充最后一周的空白天数（如果需要）
    while (currentWeek.length > 0 && currentWeek.length < 7) {
      currentWeek.push({
        day: 0,
        date: new Date(),
        isCurrentMonth: false,
        isToday: false
      });
    }
    
    if (currentWeek.length > 0) {
      weeks.push({ days: [...currentWeek] });
    }
    
    this.weeks = weeks;
  }

  // 判断是否是今天
  isToday(date: Date): boolean {
    return DateUtils.isToday(date);
  }

  // 查找指定日期的记录
  findRecordForDate(date: Date): recordViewData | undefined {
    if (!this.records) return undefined;
    
    return this.records.find(record => {
      const recordDate = new Date(record.dateInfo);
      return recordDate.getFullYear() === date.getFullYear() &&
             recordDate.getMonth() === date.getMonth() &&
             recordDate.getDate() === date.getDate();
    });
  }

  // 获取生理状态对应的颜色
  getStatusColor(status: number): string {
    switch (status) {
      case PhysiologyStatus.MENSTRUATION:
        return AppConfig.STATUS_COLORS.MENSTRUATION;
      case PhysiologyStatus.OVULATION:
        return AppConfig.STATUS_COLORS.OVULATION;
      case PhysiologyStatus.FERTILE:
        return AppConfig.STATUS_COLORS.FERTILE;
      case PhysiologyStatus.PREDICTED:
        return AppConfig.STATUS_COLORS.PREDICTED;
      default:
        return AppConfig.STATUS_COLORS.NORMAL;
    }
  }

  // 获取生理状态对应的背景色
  getStatusBackgroundColor(status: number, isPredicted: boolean): string {
    const baseColor = this.getStatusColor(status);
    const alpha = isPredicted ? AppConfig.BACKGROUND_ALPHA.PREDICTED : AppConfig.BACKGROUND_ALPHA.NORMAL;
    return baseColor + alpha;
  }

  build() {
    Column() {
      // 周标签行
      Row() {
        ForEach(this.weekLabels, (label: string) => {
          Text(label)
            .width('14.28%')
            .textAlign(TextAlign.Center)
            .fontSize(14)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)
            .padding({ top: 8, bottom: 8 })
        })
      }
      .width('100%')
      .backgroundColor('#F5F5F5')

      // 日历内容
      Column() {
        ForEach(this.weeks, (week: WeekInfo, weekIndex: number) => {
          Row() {
            ForEach(week.days, (day: CalendarDay, dayIndex: number) => {
              Stack() {
                if (day.isCurrentMonth) {
                  // 背景圆圈（如果有生理状态）
                  if (day.record && day.record.physiologyStatus !== PhysiologyStatus.NORMAL) {
                    Circle()
                      .width(32)
                      .height(32)
                      .fill(this.getStatusBackgroundColor(day.record.physiologyStatus, day.record.predictFlag))
                  }
                  
                  // 今天的背景
                  if (day.isToday) {
                    Circle()
                      .width(32)
                      .height(32)
                      .stroke('#2196F3', 2)
                      .fill(Color.Transparent)
                  }
                  
                  // 日期文字
                  Text(day.day.toString())
                    .fontSize(16)
                    .fontColor(day.isToday ? '#2196F3' : '#333333')
                    .fontWeight(day.isToday ? FontWeight.Bold : FontWeight.Normal)
                  
                  // 状态指示点
                  if (day.record && day.record.physiologyStatus !== PhysiologyStatus.NORMAL) {
                    Circle()
                      .width(6)
                      .height(6)
                      .fill(this.getStatusColor(day.record.physiologyStatus))
                      .margin({ top: 20 })
                  }
                }
              }
              .width('14.28%')
              .height(40)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            })
          }
          .width('100%')
          .margin({ bottom: 4 })
        })
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }
}