# 鸿蒙月历应用

基于鸿蒙ArkTS开发的月历应用，支持循环滑动查看月份信息，具有本地存储和服务端数据同步功能。

## 功能特性

- ✅ **循环滑动**: 利用Swiper组件实现三页循环滑动，无缝切换月份
- ✅ **月历显示**: 标准月历布局，显示日期与周标签对齐
- ✅ **生理状态**: 支持多种生理状态标记（月经期、排卵期、易孕期等）
- ✅ **本地存储**: 数据本地缓存，支持离线查看
- ✅ **服务端同步**: 自动从服务端获取数据并同步本地
- ✅ **智能加载**: 优先使用本地数据，缺失时自动请求服务端

## 项目结构

```
src/main/ets/
├── components/          # 组件
│   └── MonthCalendar.ets   # 月历组件
├── pages/               # 页面
│   └── CalendarPage.ets    # 主页面
├── models/              # 数据模型
│   └── RecordModels.ets    # 记录数据模型
├── services/            # 服务层
│   └── ApiService.ets      # API服务
├── utils/               # 工具类
│   ├── DataManager.ets     # 数据管理器
│   └── DateUtils.ets       # 日期工具类
└── config/              # 配置
    └── AppConfig.ets       # 应用配置
```

## 核心组件

### 1. CalendarPage (主页面)
- 管理Swiper的三页循环逻辑
- 处理月份切换和数据加载
- 控制滑动方向和页面状态

### 2. MonthCalendar (月历组件)
- 渲染月历视图
- 显示生理状态标记
- 支持今日高亮显示

### 3. DataManager (数据管理器)
- 本地数据存储和读取
- 数据缓存管理
- 过期数据清理

### 4. ApiService (API服务)
- 服务端数据请求
- 批量数据获取
- 错误处理和重试

## 数据格式

### 服务端数据格式
```typescript
export class recordViewData {
  dateInfo: number = 0;        // 日期时间戳毫秒
  todayFlag: boolean = false;  // 是否是今日
  predictFlag: boolean = false; // 是否是预测周期
  physiologyStatus: number = 0; // 生理状态枚举
}
```

### 生理状态枚举
```typescript
export enum PhysiologyStatus {
  NORMAL = 0,        // 正常
  MENSTRUATION = 1,  // 月经期
  OVULATION = 2,     // 排卵期
  FERTILE = 3,       // 易孕期
  PREDICTED = 4      // 预测期
}
```

## 使用方法

### 1. 配置API地址
修改 `src/main/ets/config/AppConfig.ets` 中的API地址：
```typescript
static readonly API_BASE_URL = 'https://your-api-domain.com';
```

### 2. 服务端接口
需要提供以下API接口：

**获取月份数据**
- 接口: `GET /api/records/month`
- 参数: `yearMonth` (格式: YYYYMM)
- 返回: `{ success: true, data: recordViewData[] }`

**更新记录数据** (可选)
- 接口: `PUT /api/records/update`
- 参数: `recordViewData` 对象
- 返回: `{ success: boolean }`

### 3. 运行应用
1. 在鸿蒙开发环境中导入项目
2. 配置好API地址
3. 编译运行到设备或模拟器

## 滑动逻辑

### 无限循环原理
- 维护三个页面的数组 `[prevMonth, currentMonth, nextMonth]`
- 用户始终在中间页面(index=1)操作
- 滑动到边界时，重新排列数组并重置到中间页面
- 确保左滑显示下月，右滑显示上月

### 数据加载策略
1. **初始加载**: 启动时加载当前月及前后月数据
2. **本地优先**: 优先使用本地缓存数据
3. **按需请求**: 滑动到新月份时，检查本地是否有数据
4. **后台加载**: 数据请求不阻塞UI显示

## 自定义配置

### 颜色主题
在 `AppConfig.ets` 中修改生理状态对应的颜色：
```typescript
static readonly STATUS_COLORS = {
  NORMAL: '#E0E0E0',      // 正常 - 灰色
  MENSTRUATION: '#FF4444', // 月经期 - 红色
  OVULATION: '#4CAF50',    // 排卵期 - 绿色
  FERTILE: '#FFC107',      // 易孕期 - 黄色
  PREDICTED: '#FF9800'     // 预测期 - 橙色
};
```

### 缓存配置
```typescript
static readonly CACHE_EXPIRE_MONTHS = 12; // 缓存过期月数
static readonly API_TIMEOUT = 10000;      // 请求超时时间
```

## 注意事项

1. **月份格式**: 所有月份参数使用YYYYMM格式（如：202309）
2. **时区处理**: 确保客户端和服务端时区一致
3. **数据同步**: 本地修改的数据需要同步到服务端
4. **错误处理**: 网络异常时会显示空白月历，不影响基本使用
5. **性能优化**: 大量数据时建议实现数据分页加载

## 扩展功能

可以基于当前架构扩展以下功能：
- 日期点击事件处理
- 数据编辑功能
- 多用户数据隔离
- 数据导出功能
- 提醒和通知
- 统计分析功能

## 技术栈

- **框架**: 鸿蒙ArkTS
- **UI组件**: ArkUI (Swiper, Column, Row, Text等)
- **数据存储**: @ohos.data.preferences
- **网络请求**: @ohos.net.http
- **开发工具**: DevEco Studio