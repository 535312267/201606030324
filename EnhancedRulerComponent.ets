// 刻度项数据类
class ScaleItem {
  index: number;
  value: number;
  isMajor: boolean;

  constructor(index: number, value: number, isMajor: boolean) {
    this.index = index;
    this.value = value;
    this.isMajor = isMajor;
  }
}

@Component
export struct EnhancedRulerComponent {
  @State currentValue: number = 3000; // 当前选中的值，设置为3000以匹配图片
  @State scrollOffset: number = 0; // 滚动偏移量
  @State isScrolling: boolean = false; // 是否正在滚动
  @State rulerWidth: number = 320; // 刻度尺容器宽度

  // 刻度尺配置 - 更新为粉色主题
  private minValue: number = 2000; // 最小值，调整范围以匹配图片
  private maxValue: number = 4000; // 最大值
  private step: number = 50; // 每个刻度代表的值，调整为50以匹配图片密度
  private scaleInterval: number = 12; // 刻度间隔（像素），调整间距
  private majorScaleHeight: number = 20; // 主刻度高度
  private minorScaleHeight: number = 12; // 次刻度高度
  private scaleWidth: number = 1.5; // 刻度宽度，更细
  private scaleColor: string = '#CCCCCC'; // 刻度颜色，浅灰色
  private selectedLineColor: string = '#FF69B4'; // 选中线颜色，粉色
  private selectedLineHeight: number = 45; // 选中线高度
  private selectedLineWidth: number = 2; // 选中线宽度

  // 数字显示配置
  private fontSize: number = 12; // 字号，稍小
  private fontWeight: number = 400; // 字重，正常
  private textColor: string = '#999999'; // 字体颜色，浅灰色
  private currentValueFontSize: number = 32; // 当前值字号，更大
  private currentValueColor: string = '#FF69B4'; // 当前值颜色，粉色

  // 滚动控制器
  private scroller: Scroller = new Scroller();

  // 计算总刻度数
  private getTotalScales(): number {
    return (this.maxValue - this.minValue) / this.step + 1;
  }

  // 计算总宽度
  private getTotalWidth(): number {
    return (this.getTotalScales() - 1) * this.scaleInterval;
  }

  // 根据值获取刻度索引
  private getScaleIndex(value: number): number {
    return (value - this.minValue) / this.step;
  }

  // 根据刻度索引获取值
  private getValueByIndex(index: number): number {
    return this.minValue + index * this.step;
  }

  // 根据值计算滚动偏移量
  private getScrollOffset(value: number): number {
    const index = this.getScaleIndex(value);
    return index * this.scaleInterval;
  }

  // 根据滚动偏移量计算值
  private getValueByOffset(offset: number): number {
    const index = Math.round(offset / this.scaleInterval);
    return this.getValueByIndex(index);
  }

  // 检查是否为主刻度（每4个刻度显示数字）
  private isMajorScale(index: number): boolean {
    return index % 4 === 0; // 每4个刻度显示数字
  }

  // 处理滚动事件
  private onScroll(xOffset: number, yOffset: number) {
    const offset = xOffset;

    // 计算当前指示器位置对应的刻度索引
    const centerOffset = this.rulerWidth / 2;
    const currentIndex = Math.round((offset + centerOffset) / this.scaleInterval);
    const clampedIndex = Math.max(0, Math.min(this.getTotalScales() - 1, currentIndex));

    const newValue = this.getValueByIndex(clampedIndex);

    // 边界检查
    if (newValue < this.minValue) {
      this.currentValue = this.minValue;
      this.scrollOffset = 0;
    } else if (newValue > this.maxValue) {
      this.currentValue = this.maxValue;
      this.scrollOffset = this.getScrollOffset(this.maxValue);
    } else {
      this.currentValue = newValue;
      this.scrollOffset = offset;
    }
  }

  // 处理滚动结束事件
  private onScrollEnd() {
    this.isScrolling = false;

    const targetIndex = this.getScaleIndex(this.currentValue);
    const centerOffset = this.rulerWidth / 2;
    const targetOffset = targetIndex * this.scaleInterval - centerOffset;

    this.scrollOffset = targetOffset;
  }

  // 处理滚动开始事件
  private onScrollStart() {
    this.isScrolling = true;
  }

  // 初始化滚动位置
  aboutToAppear() {
    const targetIndex = this.getScaleIndex(this.currentValue);
    const centerOffset = this.rulerWidth / 2;
    this.scrollOffset = targetIndex * this.scaleInterval - centerOffset;

    setTimeout(() => {
      this.scroller.scrollTo({ xOffset: this.scrollOffset, yOffset: 0, animation: false });
    }, 100);
  }

  build() {
    Column() {
      // 当前值显示区域 - 粉色主题
      Row() {
        Text(`${this.currentValue}`)
          .fontSize(this.currentValueFontSize)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentValueColor)
          .lineHeight(40)
        
        Text('ml')
          .fontSize(this.currentValueFontSize)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentValueColor)
          .lineHeight(40)
          .margin({ left: 2 })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 20 })

      // 刻度尺容器
      Stack() {
        // 背景
        Row()
          .width('100%')
          .height(60)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)

        // 滚动容器
        Scroll(this.scroller) {
          Row() {
            // 左侧填充，确保第一个刻度能居中
            Row()
              .width(this.rulerWidth / 2)
              .height(60)

            // 生成所有刻度
            ForEach(Array.from<number, ScaleItem>({ length: this.getTotalScales() }, (_, index: number) => {
              const value = this.getValueByIndex(index);
              const isMajor = this.isMajorScale(index);

              return new ScaleItem(index, value, isMajor);
            }), (item: ScaleItem) => {
              Column() {
                // 数字显示（仅主刻度）
                if (item.isMajor) {
                  Text(`${item.value}`)
                    .fontSize(this.fontSize)
                    .fontWeight(this.fontWeight)
                    .fontColor(this.textColor)
                    .margin({ bottom: 8 })
                    .textAlign(TextAlign.Center)
                } else {
                  // 占位空间
                  Text('')
                    .fontSize(this.fontSize)
                    .margin({ bottom: 8 })
                }

                // 刻度线
                Row()
                  .width(this.scaleWidth)
                  .height(item.isMajor ? this.majorScaleHeight : this.minorScaleHeight)
                  .backgroundColor(this.scaleColor)
                  .borderRadius(1)
              }
              .width(this.scaleInterval)
              .height(60)
              .justifyContent(FlexAlign.End)
              .alignItems(HorizontalAlign.Center)
            })

            // 右侧填充，确保最后一个刻度能居中
            Row()
              .width(this.rulerWidth / 2)
              .height(60)
          }
          .width(this.getTotalWidth() + this.rulerWidth)
          .height(60)
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .onScroll((xOffset: number, yOffset: number) => {
          this.onScroll(xOffset, yOffset);
        })
        .onScrollStart(() => {
          this.onScrollStart();
        })
        .onScrollEnd(() => {
          this.onScrollEnd();
        })
        .width('100%')
        .height(60)
        .onAreaChange((oldValue: Area, newValue: Area) => {
          if (newValue.width > 0 && newValue.width !== this.rulerWidth) {
            this.rulerWidth = Number(newValue.width.toString());
          }
        })

        // 居中指示器（固定）- 粉色竖线
        Column() {
          Row()
            .width(this.selectedLineWidth)
            .height(this.selectedLineHeight)
            .backgroundColor(this.selectedLineColor)
            .borderRadius(1)
            .shadow({
              radius: 2,
              color: '#FF69B4',
              offsetX: 0,
              offsetY: 0
            })
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height(60)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .backgroundColor('#FFFFFF')
  }

  // 设置刻度尺范围的方法
  setRange(min: number, max: number, step: number = 50) {
    this.minValue = min;
    this.maxValue = max;
    this.step = step;
    this.currentValue = Math.max(min, Math.min(max, this.currentValue));

    const targetIndex = this.getScaleIndex(this.currentValue);
    const centerOffset = this.rulerWidth / 2;
    this.scrollOffset = targetIndex * this.scaleInterval - centerOffset;
  }

  // 设置当前值的方法
  setValue(value: number) {
    this.currentValue = Math.max(this.minValue, Math.min(this.maxValue, value));
    
    const targetIndex = this.getScaleIndex(this.currentValue);
    const centerOffset = this.rulerWidth / 2;
    const targetOffset = targetIndex * this.scaleInterval - centerOffset;
    
    this.scrollOffset = targetOffset;
    this.scroller.scrollTo({ xOffset: targetOffset, yOffset: 0, animation: true });
  }
}