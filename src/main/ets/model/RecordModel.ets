/**
 * 年月查询记录信息数据模型
 */
export class RecordViewData {
  dateInfo: number = 0; // 日期时间戳毫秒
  todayFlag: boolean = false; // 是否是今日
  predictFlag: boolean = false; // 是否是预测周期
  physiologyStatus: number = 0; // 生理状态枚举
}

/**
 * 月份数据模型
 */
export class MonthData {
  year: number;
  month: number;
  records: RecordViewData[];

  constructor(year: number, month: number, records: RecordViewData[] = []) {
    this.year = year;
    this.month = month;
    this.records = records;
  }
}

/**
 * 日历日期模型
 */
export class CalendarDay {
  date: number; // 日期（1-31）
  isCurrentMonth: boolean; // 是否是当前月
  record?: RecordViewData; // 对应的记录数据

  constructor(date: number, isCurrentMonth: boolean, record?: RecordViewData) {
    this.date = date;
    this.isCurrentMonth = isCurrentMonth;
    this.record = record;
  }
}