import { MonthCalendar } from '../components/MonthCalendar';
import { DataManager } from '../utils/DataManager';
import { ApiService } from '../services/ApiService';
import { recordViewData } from '../models/RecordModels';
import { DateUtils } from '../utils/DateUtils';
import { AppConfig } from '../config/AppConfig';

@Entry
@Component
struct CalendarPage {
  @State currentIndex: number = 1; // 当前显示的页面索引，初始为中间页
  @State monthsData: Map<string, recordViewData[]> = new Map(); // 存储月份数据
  @State monthsList: string[] = []; // 三个月份的列表
  @State isLoading: boolean = false;
  
  private dataManager: DataManager = DataManager.getInstance();
  private apiService: ApiService = ApiService.getInstance();
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear() {
    this.initializeData();
  }

  // 初始化数据
  async initializeData() {
    try {
      // 初始化数据管理器
      await this.dataManager.init(getContext(this));
      
      // 生成当前月份及前后月份
      this.generateInitialMonths();
      
      // 加载初始数据
      await this.loadInitialData();
    } catch (error) {
      console.error('初始化数据失败:', error);
    }
  }

  // 生成初始的三个月份
  generateInitialMonths() {
    const currentYearMonth = DateUtils.getCurrentYearMonth();
    const prevYearMonth = DateUtils.getPrevMonth(currentYearMonth);
    const nextYearMonth = DateUtils.getNextMonth(currentYearMonth);

    this.monthsList = [prevYearMonth, currentYearMonth, nextYearMonth];
  }

  // 加载初始数据
  async loadInitialData() {
    this.isLoading = true;
    
    try {
      // 并行加载三个月的数据
      const loadPromises = this.monthsList.map(async (yearMonth) => {
        return await this.loadMonthData(yearMonth);
      });
      
      await Promise.all(loadPromises);
    } catch (error) {
      console.error('加载初始数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 加载单个月份数据
  async loadMonthData(yearMonth: string): Promise<void> {
    try {
      // 首先尝试从本地存储获取
      const localData = await this.dataManager.getMonthData(yearMonth);
      
      if (localData && localData.length > 0) {
        // 本地有数据，直接使用
        this.monthsData.set(yearMonth, localData);
        console.log(`从本地加载${yearMonth}数据成功`);
      } else {
        // 本地没有数据，从服务端获取
        console.log(`本地无${yearMonth}数据，从服务端获取`);
        const serverData = await this.apiService.getMonthRecords(yearMonth);
        
        // 保存到本地存储
        await this.dataManager.saveMonthData(yearMonth, serverData);
        
        // 更新状态
        this.monthsData.set(yearMonth, serverData);
        console.log(`从服务端加载${yearMonth}数据成功`);
      }
    } catch (error) {
      console.error(`加载${yearMonth}数据失败:`, error);
      // 设置空数据避免组件报错
      this.monthsData.set(yearMonth, []);
    }
  }

  // 处理滑动变化
  onSwiperChange(index: number) {
    if (index === this.currentIndex) return;
    
    const oldIndex = this.currentIndex;
    this.currentIndex = index;
    
    // 根据滑动方向更新月份列表
    if (index === 2 && oldIndex === 1) {
      // 向左滑动，显示下个月
      this.handleSwipeToNext();
    } else if (index === 0 && oldIndex === 1) {
      // 向右滑动，显示上个月
      this.handleSwipeToPrev();
    }
  }

  // 处理向左滑动到下个月
  async handleSwipeToNext() {
    const currentYearMonth = this.monthsList[1];
    const nextYearMonth = DateUtils.getNextMonth(currentYearMonth);
    
    // 更新月份列表：向左移动一位
    this.monthsList = [this.monthsList[1], this.monthsList[2], nextYearMonth];
    
    // 加载新月份数据
    await this.loadMonthData(nextYearMonth);
    
    // 重置到中间页
    setTimeout(() => {
      this.currentIndex = 1;
      this.swiperController.changeIndex(1, false);
    }, AppConfig.LOADING_DELAY);
  }

  // 处理向右滑动到上个月
  async handleSwipeToPrev() {
    const currentYearMonth = this.monthsList[1];
    const prevYearMonth = DateUtils.getPrevMonth(currentYearMonth);
    
    // 更新月份列表：向右移动一位
    this.monthsList = [prevYearMonth, this.monthsList[0], this.monthsList[1]];
    
    // 加载新月份数据
    await this.loadMonthData(prevYearMonth);
    
    // 重置到中间页
    setTimeout(() => {
      this.currentIndex = 1;
      this.swiperController.changeIndex(1, false);
    }, AppConfig.LOADING_DELAY);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text(this.monthsList.length > 1 ? DateUtils.getMonthTitle(this.monthsList[1]) : '')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 2, color: '#00000010', offsetY: 2 })

      // 加载指示器
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
            .color('#2196F3')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.Center)
      }

      // Swiper组件
      Swiper(this.swiperController) {
        // 三个月份页面
        ForEach([0, 1, 2], (pageIndex: number) => {
          if (pageIndex < this.monthsList.length) {
            MonthCalendar({
              yearMonth: this.monthsList[pageIndex],
              records: this.monthsData.get(this.monthsList[pageIndex]) || []
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .loop(false) // 禁用循环，我们手动处理
      .indicator(false) // 不显示指示器
      .duration(AppConfig.SWIPER_DURATION) // 动画时长
      .curve(Curve.Ease) // 动画曲线
      .onChange((index: number) => {
        this.onSwiperChange(index);
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}