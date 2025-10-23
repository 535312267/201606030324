import { picker } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { image } from '@kit.ImageKit'
import { request } from '@kit.NetworkKit'
import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { DrawingCanvas } from './DrawingCanvas'
import { UploadUtils } from '../utils/UploadUtils'

export interface UploadedImage {
  id: string
  name: string
  path: string
  size: number
  uploadTime: Date
  thumbnail?: string
}

@Component
export struct ImageUploader {
  @State private uploadedImages: UploadedImage[] = []
  @State private isUploading: boolean = false
  @State private uploadProgress: number = 0
  @State private selectedImagePath: string = ''
  @State private showImagePreview: boolean = false
  
  @Prop canvasRef: DrawingCanvas | null

  build() {
    Column() {
      // 上传操作区域
      Column() {
        Text('图片上传')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 15 })

        // 上传按钮组
        Row() {
          Button('选择图片')
            .fontSize(14)
            .backgroundColor('#007DFF')
            .fontColor('#ffffff')
            .borderRadius(20)
            .enabled(!this.isUploading)
            .onClick(() => {
              this.selectImage()
            })

          Button('上传绘图')
            .fontSize(14)
            .backgroundColor('#52c41a')
            .fontColor('#ffffff')
            .borderRadius(20)
            .enabled(!this.isUploading && this.canvasRef !== null)
            .onClick(() => {
              this.uploadDrawing()
            })

          Button('拍照上传')
            .fontSize(14)
            .backgroundColor('#fa8c16')
            .fontColor('#ffffff')
            .borderRadius(20)
            .enabled(!this.isUploading)
            .onClick(() => {
              this.takePhoto()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: 15 })

        // 上传进度
        if (this.isUploading) {
          Column() {
            Text(`上传中... ${Math.round(this.uploadProgress)}%`)
              .fontSize(12)
              .fontColor('#666666')
              .margin({ bottom: 5 })

            Progress({
              value: this.uploadProgress,
              total: 100,
              type: ProgressType.Linear
            })
              .width('80%')
              .color('#007DFF')
              .backgroundColor('#f0f0f0')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 15 })
        }
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#f8f9fa')
      .borderRadius(8)
      .margin({ horizontal: 15, top: 10 })

      // 已上传图片列表
      Column() {
        Row() {
          Text('已上传图片')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text(`(${this.uploadedImages.length})`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 5 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 10 })

        if (this.uploadedImages.length === 0) {
          Column() {
            Image($r('app.media.icon_empty'))
              .width(60)
              .height(60)
              .fillColor('#cccccc')
              .margin({ bottom: 10 })

            Text('暂无上传的图片')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          List() {
            ForEach(this.uploadedImages, (item: UploadedImage) => {
              ListItem() {
                this.ImageListItem(item)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 1, color: '#f0f0f0' })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding(15)
      .margin({ horizontal: 15, top: 10 })
      .backgroundColor('#ffffff')
      .borderRadius(8)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  ImageListItem(item: UploadedImage) {
    Row() {
      // 缩略图
      Image(item.thumbnail || item.path)
        .width(50)
        .height(50)
        .borderRadius(4)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#f0f0f0')
        .onClick(() => {
          this.selectedImagePath = item.path
          this.showImagePreview = true
        })

      // 图片信息
      Column() {
        Text(item.name)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`大小: ${this.formatFileSize(item.size)}`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 2 })

        Text(`上传时间: ${this.formatDate(item.uploadTime)}`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })

      // 操作按钮
      Row() {
        Button('分享')
          .fontSize(12)
          .backgroundColor('#52c41a')
          .fontColor('#ffffff')
          .borderRadius(15)
          .padding({ horizontal: 12, vertical: 4 })
          .onClick(() => {
            this.shareImage(item)
          })

        Button('删除')
          .fontSize(12)
          .backgroundColor('#ff4d4f')
          .fontColor('#ffffff')
          .borderRadius(15)
          .padding({ horizontal: 12, vertical: 4 })
          .margin({ left: 8 })
          .onClick(() => {
            this.deleteImage(item)
          })
      }
    }
    .width('100%')
    .padding({ vertical: 10, horizontal: 5 })
    .alignItems(VerticalAlign.Center)
  }

  private async selectImage() {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1

      const photoViewPicker = new photoAccessHelper.PhotoViewPicker()
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions)

      if (photoSelectResult.photoUris.length > 0) {
        const uri = photoSelectResult.photoUris[0]
        await this.uploadImageFromUri(uri)
      }
    } catch (error) {
      console.error('选择图片失败:', error)
      promptAction.showToast({
        message: '选择图片失败，请重试',
        duration: 2000
      })
    }
  }

  private async takePhoto() {
    try {
      const cameraPicker = new picker.PhotoViewPicker()
      const result = await cameraPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      })

      if (result.photoUris.length > 0) {
        const uri = result.photoUris[0]
        await this.uploadImageFromUri(uri)
      }
    } catch (error) {
      console.error('拍照失败:', error)
      promptAction.showToast({
        message: '拍照失败，请重试',
        duration: 2000
      })
    }
  }

  private async uploadDrawing() {
    if (!this.canvasRef) {
      promptAction.showToast({
        message: '绘图组件未准备就绪',
        duration: 2000
      })
      return
    }

    try {
      const savedPath = await this.canvasRef.saveDrawing()
      if (savedPath) {
        await this.uploadImageFromPath(savedPath, `绘图_${Date.now()}.png`)
      }
    } catch (error) {
      console.error('上传绘图失败:', error)
      promptAction.showToast({
        message: '上传绘图失败，请重试',
        duration: 2000
      })
    }
  }

  private async uploadImageFromUri(uri: string) {
    this.isUploading = true
    this.uploadProgress = 0

    try {
      // 模拟上传进度
      const progressInterval = setInterval(() => {
        if (this.uploadProgress < 90) {
          this.uploadProgress += Math.random() * 20
        }
      }, 200)

      // 获取文件信息
      const fileInfo = await UploadUtils.getFileInfoFromUri(uri)
      
      // 模拟网络上传
      await UploadUtils.uploadFile(uri, (progress: number) => {
        this.uploadProgress = progress
      })

      clearInterval(progressInterval)
      this.uploadProgress = 100

      // 添加到上传列表
      const uploadedImage: UploadedImage = {
        id: `img_${Date.now()}`,
        name: fileInfo.name,
        path: uri,
        size: fileInfo.size,
        uploadTime: new Date(),
        thumbnail: await UploadUtils.generateThumbnail(uri)
      }

      this.uploadedImages.unshift(uploadedImage)

      promptAction.showToast({
        message: '图片上传成功',
        duration: 2000
      })

    } catch (error) {
      console.error('上传失败:', error)
      promptAction.showToast({
        message: '上传失败，请重试',
        duration: 2000
      })
    } finally {
      this.isUploading = false
      this.uploadProgress = 0
    }
  }

  private async uploadImageFromPath(filePath: string, fileName: string) {
    this.isUploading = true
    this.uploadProgress = 0

    try {
      // 模拟上传进度
      const progressInterval = setInterval(() => {
        if (this.uploadProgress < 90) {
          this.uploadProgress += Math.random() * 20
        }
      }, 200)

      // 获取文件大小
      const fileSize = await UploadUtils.getFileSize(filePath)
      
      // 模拟网络上传
      await UploadUtils.uploadFile(filePath, (progress: number) => {
        this.uploadProgress = progress
      })

      clearInterval(progressInterval)
      this.uploadProgress = 100

      // 添加到上传列表
      const uploadedImage: UploadedImage = {
        id: `img_${Date.now()}`,
        name: fileName,
        path: filePath,
        size: fileSize,
        uploadTime: new Date(),
        thumbnail: await UploadUtils.generateThumbnail(filePath)
      }

      this.uploadedImages.unshift(uploadedImage)

      promptAction.showToast({
        message: '绘图上传成功',
        duration: 2000
      })

    } catch (error) {
      console.error('上传失败:', error)
      promptAction.showToast({
        message: '上传失败，请重试',
        duration: 2000
      })
    } finally {
      this.isUploading = false
      this.uploadProgress = 0
    }
  }

  private shareImage(item: UploadedImage) {
    // 实现图片分享功能
    promptAction.showToast({
      message: `分享图片: ${item.name}`,
      duration: 2000
    })
  }

  private deleteImage(item: UploadedImage) {
    const index = this.uploadedImages.findIndex(img => img.id === item.id)
    if (index > -1) {
      this.uploadedImages.splice(index, 1)
      promptAction.showToast({
        message: '图片已删除',
        duration: 1500
      })
    }
  }

  private formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B'
    
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    
    return `${year}-${month}-${day} ${hours}:${minutes}`
  }
}