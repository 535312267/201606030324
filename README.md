# 卫生巾使用时间监控应用

这是一个基于鸿蒙系统开发的卫生巾使用时间监控应用，使用ArkTS语言和Canvas绘制技术实现。

## 功能特性

### 🎨 精美的卫生巾轮廓绘制
- 使用Path2D和Canvas绘制精确的卫生巾轮廓
- 包含主体、翅膀、吸收层等详细结构
- 采用椭圆形设计，符合实际产品外观

### ⏰ 智能时间监控
- 实时记录更换时间和当前时间
- 自动计算使用时长与建议更换时间（3小时）的比例
- 动态显示使用百分比

### 🌊 动态波浪动画
- 根据使用时间比例动态调整波浪高度
- 多层波浪效果，营造真实的液体流动感
- 颜色随时间变化：蓝色（安全）→ 桃色（注意）→ 橙色（警告）→ 红色（危险）
- 波浪严格限制在卫生巾轮廓内，不会超出边界

### ✨ 视觉效果
- 气泡效果模拟液体状态
- 闪光效果增强视觉吸引力
- 平滑的动画过渡
- 响应式设计适配不同屏幕尺寸

## 技术实现

### 核心技术栈
- **开发语言**: ArkTS (TypeScript for HarmonyOS)
- **UI框架**: ArkUI
- **绘图技术**: Canvas 2D API + Path2D
- **动画系统**: 基于定时器的帧动画

### 关键实现细节

#### 1. 卫生巾轮廓绘制
```typescript
// 使用Path2D绘制精确轮廓
const mainPath = new Path2D()
mainPath.ellipse(centerX, centerY, 65, 80, 0, 0, 2 * Math.PI)

// 绘制翅膀部分
const leftWing = new Path2D()
leftWing.moveTo(centerX - 65, centerY - 30)
leftWing.quadraticCurveTo(centerX - 95, centerY - 15, centerX - 90, centerY)
```

#### 2. 时间比例计算
```typescript
private getTimeRatio(): number {
  const timeDiff = this.currentTime.getTime() - this.changeTime.getTime()
  const ratio = Math.min(timeDiff / this.CHANGE_INTERVAL, 1.0)
  return Math.max(ratio, 0)
}
```

#### 3. 波浪动画实现
```typescript
// 多层波浪效果
for (let layer = 0; layer < waveCount; layer++) {
  const layerHeight = maxHeight * (1 - layer * 0.15)
  const amplitude = 6 - layer * 1.5
  const frequency = 0.03 + layer * 0.005
  const phaseOffset = (this.waveOffset + layer * 45) * Math.PI / 180
  
  // 绘制正弦波曲线
  const angle = (x - centerX) * frequency + phaseOffset
  const y = waveBottom + Math.sin(angle) * amplitude
}
```

#### 4. 边界裁剪
```typescript
// 使用clip()确保波浪不超出轮廓
this.context.save()
this.context.beginPath()
this.context.ellipse(centerX, centerY, 53, 68, 0, 0, 2 * Math.PI)
this.context.clip()
// 绘制波浪...
this.context.restore()
```

## 项目结构

```
/workspace/
├── ets/
│   ├── pages/
│   │   └── Index.ets              # 主页面组件
│   └── entryability/
│       └── EntryAbility.ets       # 应用入口能力
├── resources/
│   └── base/
│       ├── profile/
│       │   └── main_pages.json    # 页面配置
│       └── element/
│           ├── string.json        # 字符串资源
│           └── color.json         # 颜色资源
├── app.json5                      # 应用配置
├── module.json5                   # 模块配置
└── README.md                      # 项目说明
```

## 使用说明

### 基本操作
1. **启动应用**: 应用启动后自动开始监控
2. **重置时间**: 点击"重置更换时间"按钮重新开始计时
3. **控制动画**: 点击"暂停动画"/"开始动画"按钮控制波浪动画

### 状态指示
- **蓝色波浪**: 使用时间 < 30%，状态安全
- **桃色波浪**: 使用时间 30%-60%，需要注意
- **橙色波浪**: 使用时间 60%-80%，建议准备更换
- **红色波浪**: 使用时间 > 80%，需要立即更换

### 动画效果
- 波浪高度随使用时间比例增长
- 多层波浪营造立体效果
- 气泡和闪光增强视觉体验
- 所有动画效果严格限制在轮廓内

## 开发环境要求

- **HarmonyOS SDK**: API Level 9+
- **DevEco Studio**: 4.0+
- **Target API**: 12
- **设备类型**: 手机、平板

## 编译和运行

1. 使用DevEco Studio打开项目
2. 连接HarmonyOS设备或启动模拟器
3. 点击运行按钮编译并安装应用

## 技术亮点

1. **精确的路径绘制**: 使用Path2D API绘制复杂的卫生巾轮廓
2. **智能边界检测**: 确保所有动画效果都在指定区域内
3. **多层动画系统**: 实现丰富的视觉效果
4. **响应式时间计算**: 实时更新显示状态
5. **用户友好界面**: 直观的颜色编码和控制按钮

## 扩展功能建议

- [ ] 添加提醒通知功能
- [ ] 支持自定义更换时间间隔
- [ ] 记录使用历史数据
- [ ] 添加健康建议和小贴士
- [ ] 支持多种卫生用品类型

---

**注意**: 这是一个演示应用，实际使用时请结合个人情况和医生建议。