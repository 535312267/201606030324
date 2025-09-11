# 鸿蒙生理周期日历组件

这是一个基于鸿蒙ArkTS开发的生理周期日历组件，使用Swiper实现三页循环滑动显示月份信息。

## 功能特性

- ✅ **三页循环滑动**：使用Swiper组件实现无限循环滑动
- ✅ **月历样式**：标准月历布局，周标签对齐，只显示当月日期
- ✅ **数据缓存**：本地存储月份数据，支持离线查看
- ✅ **智能加载**：优先读取本地数据，无数据时自动请求服务端
- ✅ **生理状态显示**：不同颜色标识不同生理状态
- ✅ **今日标记**：突出显示当前日期
- ✅ **预测标记**：显示预测周期信息

## 项目结构

```
src/main/ets/
├── model/
│   └── RecordModel.ets          # 数据模型定义
├── service/
│   └── DataService.ets          # 数据服务层
├── utils/
│   └── CalendarUtils.ets        # 日历工具类
├── view/
│   └── CalendarComponent.ets    # 日历组件
└── pages/
    └── CalendarPage.ets         # 日历页面
```

## 核心实现

### 1. 数据模型

```typescript
export class RecordViewData {
  dateInfo: number = 0;           // 日期时间戳毫秒
  todayFlag: boolean = false;     // 是否是今日
  predictFlag: boolean = false;   // 是否是预测周期
  physiologyStatus: number = 0;   // 生理状态枚举
}
```

### 2. Swiper三页循环逻辑

组件维护三个月份的数据：
- 索引0：上个月
- 索引1：当前月（默认显示）
- 索引2：下个月

滑动时动态更新数据：
- 左滑（显示下月）：数据重新排列为 [当前, 下月, 新下月]
- 右滑（显示上月）：数据重新排列为 [新上月, 上月, 当前]

### 3. 数据缓存策略

```typescript
async getMonthData(year: number, month: number): Promise<RecordViewData[]> {
  // 1. 优先从本地存储获取
  const localData = await this.getMonthDataFromLocal(year, month);
  if (localData && localData.length > 0) {
    return localData;
  }
  
  // 2. 本地无数据时请求服务端
  return await this.fetchMonthDataFromServer(year, month);
}
```

### 4. 月历布局

- 使用Grid组件实现7列布局（对应一周7天）
- 自动补齐上月末尾和下月开头的日期以对齐周
- 非当月日期显示为灰色，不可点击

## 使用方法

1. 在页面中引入CalendarComponent：

```typescript
import { CalendarComponent } from '../view/CalendarComponent';

@Entry
@Component
struct CalendarPage {
  build() {
    Column() {
      CalendarComponent()
    }
  }
}
```

2. 配置页面路由（main_pages.json）：

```json
{
  "src": [
    "pages/CalendarPage"
  ]
}
```

## 生理状态说明

- 状态0：默认（白色）
- 状态1：经期（红色）
- 状态2：安全期（青色）
- 状态3：排卵期（蓝色）
- 状态4：预测期（橙色）

## 注意事项

1. 需要在module.json5中添加网络权限
2. 首次进入会并行请求三个月的数据
3. 滑动切换月份时确保数据正确性，避免显示错误月份
4. 本地存储使用preferences，数据持久化保存
5. 支持数据修改，修改后自动保存到本地

## 扩展功能

可以基于此组件扩展以下功能：
- 日期点击事件处理
- 数据编辑功能
- 更多生理状态类型
- 自定义主题颜色
- 数据统计分析