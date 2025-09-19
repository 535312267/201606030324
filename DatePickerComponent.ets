import { hilog } from '@kit.PerformanceAnalysisKit';

// 日期选择器配置接口
export interface DatePickerConfig {
  // 可选择的日期范围（时间戳数组）
  selectableDates?: number[];
  // 默认选中的日期范围
  defaultSelectedRange?: [number, number];
  // 未来日期的选中状态自定义
  futureSelectedState?: boolean;
  // 网络请求数据回调
  onDataLoad?: (timestamps: number[]) => void;
}

// 月份数据结构
interface MonthData {
  year: number;
  month: number;
  days: DayData[];
  weeks: (DayData | null)[][]; // 预处理的周数据
}

// 日期数据结构
interface DayData {
  day: number;
  timestamp: number;
  isSelected: boolean;
  isFuture: boolean;
  isInRange: boolean;
  hasNetworkData: boolean;
}

@Component
export struct DatePickerComponent {
  @State private monthList: MonthData[] = [];
  @State private selectedDates: Set<number> = new Set();
  @State private networkDataTimestamps: Set<number> = new Set();
  @State private currentDisplayMonth: number = 0;
  @State private isLoading: boolean = false;
  
  // 配置参数 - 支持从外部传入
  @Prop config: DatePickerConfig = {};
  private selectableRange: [number, number] = [0, 0];
  
  // 回调函数 - 用于向父组件传递数据
  onSelectedDatesChange?: (dates: number[]) => void;
  
  // List组件控制器
  private listScroller: ListScroller = new ListScroller();
  
  // 性能优化：缓存计算结果
  private monthCache: Map<string, MonthData> = new Map();
  
  aboutToAppear() {
    this.initializeDateRange();
    this.generateInitialMonths();
    this.loadNetworkData();
  }
  
  // 初始化日期范围
  private initializeDateRange() {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth();
    
    // 下个月开始
    const nextMonth = new Date(currentYear, currentMonth + 1, 1);
    const startTime = nextMonth.getTime();
    
    // 到2010年1月结束
    const endTime = new Date(2010, 0, 1).getTime();
    
    this.selectableRange = [endTime, startTime];
    
    // 设置默认选中范围
    if (this.config.defaultSelectedRange) {
      const start = this.config.defaultSelectedRange[0];
      const end = this.config.defaultSelectedRange[1];
      for (let timestamp = start; timestamp <= end; timestamp += 24 * 60 * 60 * 1000) {
        this.selectedDates.add(timestamp);
      }
    }
  }
  
  // 生成初始月份数据（当前月份前后各3个月）
  private generateInitialMonths() {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth();
    
    // 生成从当前月份开始的6个月数据
    for (let i = 0; i < 6; i++) {
      const targetDate = new Date(currentYear, currentMonth + 1 + i, 1);
      const monthData = this.generateMonthData(targetDate.getFullYear(), targetDate.getMonth());
      this.monthList.push(monthData);
    }
  }
  
  // 生成单个月份的数据
  private generateMonthData(year: number, month: number): MonthData {
    const cacheKey = `${year}-${month}`;
    if (this.monthCache.has(cacheKey)) {
      return this.monthCache.get(cacheKey)!;
    }
    
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const days: DayData[] = [];
    const now = Date.now();
    
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(year, month, day);
      const timestamp = date.getTime();
      
      const dayData: DayData = {
        day,
        timestamp,
        isSelected: this.selectedDates.has(timestamp),
        isFuture: timestamp > now,
        isInRange: this.isDateInSelectableRange(timestamp),
        hasNetworkData: this.networkDataTimestamps.has(timestamp)
      };
      
      days.push(dayData);
    }
    
    // 预处理周数据
    const weeks = this.generateWeeksData(year, month, days);
    
    const monthData: MonthData = { year, month, days, weeks };
    this.monthCache.set(cacheKey, monthData);
    
    return monthData;
  }
  
  // 生成周数据
  private generateWeeksData(year: number, month: number, days: DayData[]): (DayData | null)[][] {
    // 计算第一天是星期几
    const firstDay = new Date(year, month, 1).getDay();
    const startIndex = firstDay === 0 ? 6 : firstDay - 1; // 周一为0
    
    let currentWeek: (DayData | null)[] = [];
    let weeks: (DayData | null)[][] = [];
    
    // 添加空白日期
    for (let i = 0; i < startIndex; i++) {
      currentWeek.push(null);
    }
    
    // 添加实际日期
    days.forEach((dayData) => {
      currentWeek.push(dayData);
      
      if (currentWeek.length === 7) {
        const weekCopy: (DayData | null)[] = [];
        for (let k = 0; k < currentWeek.length; k++) {
          weekCopy.push(currentWeek[k]);
        }
        weeks.push(weekCopy);
        currentWeek = [];
      }
    });
    
    // 补齐最后一周
    while (currentWeek.length > 0 && currentWeek.length < 7) {
      currentWeek.push(null);
    }
    if (currentWeek.length > 0) {
      weeks.push(currentWeek);
    }
    
    return weeks;
  }
  
  // 检查日期是否在可选择范围内
  private isDateInSelectableRange(timestamp: number): boolean {
    const start = this.selectableRange[0];
    const end = this.selectableRange[1];
    return timestamp >= start && timestamp <= end;
  }
  
  // 模拟网络请求加载数据
  private async loadNetworkData() {
    this.isLoading = true;
    
    try {
      // 模拟网络延迟
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // 模拟返回的时间戳数据
      const mockTimestamps = [
        new Date(2025, 8, 1).getTime(), // 2025年9月1日
        new Date(2025, 8, 3).getTime(), // 2025年9月3日
        new Date(2025, 8, 5).getTime(), // 2025年9月5日
      ];
      
      // 更新网络数据时间戳
      mockTimestamps.forEach(timestamp => {
        this.networkDataTimestamps.add(timestamp);
        // 如果网络数据中的日期在可选范围内，自动选中
        if (this.isDateInSelectableRange(timestamp)) {
          this.selectedDates.add(timestamp);
        }
      });
      
      // 更新月份数据
      this.updateMonthsWithNetworkData();
      
      // 调用配置回调
      if (this.config.onDataLoad) {
        this.config.onDataLoad(mockTimestamps);
      }
      
    } catch (error) {
      hilog.error(0x0000, 'DatePicker', `Network data load failed: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }
  
  // 使用网络数据更新月份
  private updateMonthsWithNetworkData() {
    const newMonthList: MonthData[] = [];
    
    for (let i = 0; i < this.monthList.length; i++) {
      const monthData = this.monthList[i];
      const updatedDays: DayData[] = [];
      
      for (let j = 0; j < monthData.days.length; j++) {
        const dayData = monthData.days[j];
        const updatedDayData: DayData = {
          day: dayData.day,
          timestamp: dayData.timestamp,
          isSelected: this.selectedDates.has(dayData.timestamp),
          isFuture: dayData.isFuture,
          isInRange: dayData.isInRange,
          hasNetworkData: this.networkDataTimestamps.has(dayData.timestamp)
        };
        updatedDays.push(updatedDayData);
      }
      
      // 重新生成周数据
      const weeks = this.generateWeeksData(monthData.year, monthData.month, updatedDays);
      
      const updatedMonthData: MonthData = {
        year: monthData.year,
        month: monthData.month,
        days: updatedDays,
        weeks: weeks
      };
      
      newMonthList.push(updatedMonthData);
    }
    
    this.monthList = newMonthList;
  }
  
  // 处理日期点击
  private onDateClick(dayData: DayData) {
    // 未来日期且不在选中范围内，不允许点击
    if (dayData.isFuture && !dayData.isInRange) {
      return;
    }
    
    // 不在可选择范围内的日期不允许点击
    if (!dayData.isInRange) {
      return;
    }
    
    // 切换选中状态
    if (this.selectedDates.has(dayData.timestamp)) {
      this.selectedDates.delete(dayData.timestamp);
    } else {
      this.selectedDates.add(dayData.timestamp);
    }
    
    // 更新对应的月份数据
    this.updateDaySelection(dayData.timestamp);
    
    // 通知父组件选中日期变化
    if (this.onSelectedDatesChange) {
      this.onSelectedDatesChange(this.getSelectedDates());
    }
  }
  
  // 更新日期选中状态
  private updateDaySelection(timestamp: number) {
    const targetDate = new Date(timestamp);
    const targetYear = targetDate.getFullYear();
    const targetMonth = targetDate.getMonth();
    
    const monthIndex = this.monthList.findIndex(month => 
      month.year === targetYear && month.month === targetMonth
    );
    
    if (monthIndex >= 0) {
      const dayIndex = this.monthList[monthIndex].days.findIndex(day => 
        day.timestamp === timestamp
      );
      
        if (dayIndex >= 0) {
          const dayData = this.monthList[monthIndex].days[dayIndex];
          const updatedDayData: DayData = {
            day: dayData.day,
            timestamp: dayData.timestamp,
            isSelected: this.selectedDates.has(timestamp),
            isFuture: dayData.isFuture,
            isInRange: dayData.isInRange,
            hasNetworkData: dayData.hasNetworkData
          };
          this.monthList[monthIndex].days[dayIndex] = updatedDayData;
          
          // 重新生成周数据
          const monthData = this.monthList[monthIndex];
          const weeks = this.generateWeeksData(monthData.year, monthData.month, monthData.days);
          const updatedMonthData: MonthData = {
            year: monthData.year,
            month: monthData.month,
            days: monthData.days,
            weeks: weeks
          };
          this.monthList[monthIndex] = updatedMonthData;
        }
    }
  }
  
  // 滑动到指定索引时加载更多月份
  private onScrollIndex = (start: number, end: number) => {
    // 当滑动到接近末尾时，加载更多历史月份
    if (end >= this.monthList.length - 2) {
      this.loadMoreHistoryMonths();
    }
    
    // 当滑动到接近开头时，加载更多未来月份（如果需要）
    if (start <= 1) {
      this.loadMoreFutureMonths();
    }
    
    // 更新当前显示的月份
    this.currentDisplayMonth = Math.floor((start + end) / 2);
  }
  
  // 加载更多历史月份
  private loadMoreHistoryMonths() {
    const lastMonth = this.monthList[this.monthList.length - 1];
    const lastDate = new Date(lastMonth.year, lastMonth.month, 1);
    
    // 添加6个更早的月份
    for (let i = 1; i <= 6; i++) {
      const targetDate = new Date(lastDate.getFullYear(), lastDate.getMonth() - i, 1);
      
      // 检查是否已经到达2010年1月
      if (targetDate.getFullYear() < 2010) {
        break;
      }
      
      const monthData = this.generateMonthData(targetDate.getFullYear(), targetDate.getMonth());
      this.monthList.push(monthData);
    }
  }
  
  // 加载更多未来月份（如果需要）
  private loadMoreFutureMonths() {
    const firstMonth = this.monthList[0];
    const firstDate = new Date(firstMonth.year, firstMonth.month, 1);
    
    // 检查是否需要添加更多未来月份
    const now = new Date();
    if (firstDate.getTime() > now.getTime()) {
      // 添加更早的月份到开头
      const newMonths: MonthData[] = [];
      for (let i = 1; i <= 3; i++) {
        const targetDate = new Date(firstDate.getFullYear(), firstDate.getMonth() - i, 1);
        const monthData = this.generateMonthData(targetDate.getFullYear(), targetDate.getMonth());
        newMonths.unshift(monthData);
      }
      
      // 合并数组
      const combinedList: MonthData[] = [];
      for (let i = 0; i < newMonths.length; i++) {
        combinedList.push(newMonths[i]);
      }
      for (let i = 0; i < this.monthList.length; i++) {
        combinedList.push(this.monthList[i]);
      }
      this.monthList = combinedList;
    }
  }
  
  build() {
    Column() {
      // 头部信息
      Row() {
        Text('记录经期')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        
        Blank()
        
        Button('回到今天')
          .backgroundColor('#FF69B4')
          .fontColor(Color.White)
          .borderRadius(20)
          .onClick(() => {
            // 滑动到当前月份
            const now = new Date();
            const currentYear = now.getFullYear();
            const currentMonth = now.getMonth();
            
            const targetIndex = this.monthList.findIndex(month => 
              month.year === currentYear && month.month === currentMonth + 1
            );
            
            if (targetIndex >= 0) {
              this.listScroller.scrollToIndex(targetIndex);
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      
      // 提示信息
      Row() {
        Text('☀️')
          .fontSize(16)
        Text('点击日期即可添加/删除/编辑经期')
          .fontSize(12)
          .fontColor('#666')
          .margin({ left: 4 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      .backgroundColor('#FFF5E6')
      .borderRadius(8)
      .margin({ left: 16, right: 16 })
      
      // 星期标题
      Row() {
        ForEach(['周一', '周二', '周三', '周四', '周五', '周六', '周日'], (day: string) => {
          Text(day)
            .fontSize(12)
            .fontColor('#999')
            .width('14.28%')
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      
      // 月份列表
      List({ scroller: this.listScroller }) {
        ForEach(this.monthList, (monthData: MonthData, monthIndex: number) => {
          ListItem() {
            this.MonthView(monthData)
          }
        }, (monthData: MonthData) => `${monthData.year}-${monthData.month}`)
      }
      .layoutWeight(1)
      .onScrollIndex(this.onScrollIndex)
      
      // 加载指示器
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
          Text('加载中...')
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 8 })
        }
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
  
  // 月份视图组件
  @Builder
  MonthView(monthData: MonthData) {
    Column() {
      // 月份标题
      Text(`${monthData.year}年${monthData.month + 1}月`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
        .width('100%')
        .textAlign(TextAlign.Center)
      
      // 日期网格
      Column() {
        ForEach(monthData.weeks, (week: (DayData | null)[], weekIndex: number) => {
          Row() {
            ForEach(week, (dayData: DayData | null, dayIndex: number) => {
              if (dayData) {
                this.DayView(dayData)
              } else {
                // 空白日期
                Text('')
                  .width('14.28%')
                  .height(40)
              }
            }, (dayData: DayData | null, index: number) => `${weekIndex}-${index}`)
          }
          .width('100%')
        }, (week: (DayData | null)[], index: number) => `week-${index}`)
      }
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ left: 16, right: 16, top: 4, bottom: 4 })
  }
  
  // 单个日期视图
  @Builder
  DayView(dayData: DayData) {
    Stack() {
      // 背景圆圈
      Circle()
        .width(32)
        .height(32)
        .fill(this.getDayBackgroundColor(dayData))
        .stroke({ color: this.getDayBorderColor(dayData), width: 1 })
      
      // 日期数字
      Text(dayData.day.toString())
        .fontSize(14)
        .fontColor(this.getDayTextColor(dayData))
        .fontWeight(dayData.isSelected ? FontWeight.Bold : FontWeight.Normal)
      
      // 网络数据指示点
      if (dayData.hasNetworkData) {
        Circle()
          .width(4)
          .height(4)
          .fill('#FF69B4')
          .position({ x: '70%', y: '20%' })
      }
    }
    .width('14.28%')
    .height(40)
    .onClick(() => this.onDateClick(dayData))
    .opacity(dayData.isFuture && !dayData.isInRange ? 0.3 : 1.0)
  }
  
  // 获取日期背景色
  private getDayBackgroundColor(dayData: DayData): ResourceColor {
    if (dayData.isSelected) {
      return '#FF69B4';
    }
    return Color.Transparent;
  }
  
  // 获取日期边框色
  private getDayBorderColor(dayData: DayData): ResourceColor {
    if (dayData.isSelected) {
      return '#FF69B4';
    }
    return Color.Transparent;
  }
  
  // 获取日期文字颜色
  private getDayTextColor(dayData: DayData): ResourceColor {
    if (dayData.isSelected) {
      return Color.White;
    }
    if (dayData.isFuture && !dayData.isInRange) {
      return '#CCC';
    }
    return Color.Black;
  }
  
  // 公共方法：设置配置
  public setConfig(config: DatePickerConfig) {
    // 手动合并配置对象
    if (config.selectableDates !== undefined) {
      this.config.selectableDates = config.selectableDates;
    }
    if (config.defaultSelectedRange !== undefined) {
      this.config.defaultSelectedRange = config.defaultSelectedRange;
    }
    if (config.futureSelectedState !== undefined) {
      this.config.futureSelectedState = config.futureSelectedState;
    }
    if (config.onDataLoad !== undefined) {
      this.config.onDataLoad = config.onDataLoad;
    }
    
    // 重新初始化
    if (config.selectableDates) {
      let minDate = config.selectableDates[0];
      let maxDate = config.selectableDates[0];
      
      for (let i = 1; i < config.selectableDates.length; i++) {
        if (config.selectableDates[i] < minDate) {
          minDate = config.selectableDates[i];
        }
        if (config.selectableDates[i] > maxDate) {
          maxDate = config.selectableDates[i];
        }
      }
      
      this.selectableRange = [minDate, maxDate];
    }
    
    if (config.defaultSelectedRange) {
      this.selectedDates.clear();
      const start = config.defaultSelectedRange[0];
      const end = config.defaultSelectedRange[1];
      for (let timestamp = start; timestamp <= end; timestamp += 24 * 60 * 60 * 1000) {
        this.selectedDates.add(timestamp);
      }
    }
  }
  
  // 公共方法：获取选中的日期
  public getSelectedDates(): number[] {
    const result: number[] = [];
    this.selectedDates.forEach(timestamp => {
      result.push(timestamp);
    });
    return result;
  }
  
  // 公共方法：清除所有选中
  public clearSelection() {
    this.selectedDates.clear();
    this.updateAllMonthsSelection();
  }
  
  // 更新所有月份的选中状态
  private updateAllMonthsSelection() {
    const newMonthList: MonthData[] = [];
    
    for (let i = 0; i < this.monthList.length; i++) {
      const monthData = this.monthList[i];
      const updatedDays: DayData[] = [];
      
      for (let j = 0; j < monthData.days.length; j++) {
        const dayData = monthData.days[j];
        const updatedDayData: DayData = {
          day: dayData.day,
          timestamp: dayData.timestamp,
          isSelected: this.selectedDates.has(dayData.timestamp),
          isFuture: dayData.isFuture,
          isInRange: dayData.isInRange,
          hasNetworkData: dayData.hasNetworkData
        };
        updatedDays.push(updatedDayData);
      }
      
      // 重新生成周数据
      const weeks = this.generateWeeksData(monthData.year, monthData.month, updatedDays);
      
      const updatedMonthData: MonthData = {
        year: monthData.year,
        month: monthData.month,
        days: updatedDays,
        weeks: weeks
      };
      
      newMonthList.push(updatedMonthData);
    }
    
    this.monthList = newMonthList;
  }
}