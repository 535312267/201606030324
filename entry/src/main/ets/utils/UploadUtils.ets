import { fileIo } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit'
import { request } from '@kit.NetworkKit'
import { common } from '@kit.AbilityKit'

export interface FileInfo {
  name: string
  size: number
  mimeType: string
}

export class UploadUtils {
  
  /**
   * 从URI获取文件信息
   */
  static async getFileInfoFromUri(uri: string): Promise<FileInfo> {
    try {
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      const stat = fileIo.statSync(file.fd)
      
      // 从URI中提取文件名
      const fileName = uri.substring(uri.lastIndexOf('/') + 1) || `image_${Date.now()}.jpg`
      
      fileIo.closeSync(file)
      
      return {
        name: fileName,
        size: stat.size,
        mimeType: this.getMimeTypeFromExtension(fileName)
      }
    } catch (error) {
      console.error('获取文件信息失败:', error)
      return {
        name: `image_${Date.now()}.jpg`,
        size: 0,
        mimeType: 'image/jpeg'
      }
    }
  }

  /**
   * 获取文件大小
   */
  static async getFileSize(filePath: string): Promise<number> {
    try {
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY)
      const stat = fileIo.statSync(file.fd)
      fileIo.closeSync(file)
      return stat.size
    } catch (error) {
      console.error('获取文件大小失败:', error)
      return 0
    }
  }

  /**
   * 生成缩略图
   */
  static async generateThumbnail(imagePath: string, maxSize: number = 150): Promise<string> {
    try {
      // 创建图片源
      const imageSource = image.createImageSource(imagePath)
      
      // 获取图片信息
      const imageInfo = await imageSource.getImageInfo()
      
      // 计算缩略图尺寸
      const { width, height } = this.calculateThumbnailSize(
        imageInfo.size.width, 
        imageInfo.size.height, 
        maxSize
      )

      // 创建像素图
      const pixelMap = await imageSource.createPixelMap({
        desiredSize: { width, height },
        desiredRegion: { size: { width: imageInfo.size.width, height: imageInfo.size.height }, x: 0, y: 0 },
        desiredPixelFormat: image.PixelMapFormat.RGB_565,
        rotateDegrees: 0,
        editable: false
      })

      // 保存缩略图
      const context = getContext() as common.UIAbilityContext
      const thumbnailPath = `${context.cacheDir}/thumbnail_${Date.now()}.jpg`
      
      const imagePackerApi = image.createImagePacker()
      const packOpts: image.PackingOption = {
        format: "image/jpeg",
        quality: 80
      }

      const imageData = await imagePackerApi.packing(pixelMap, packOpts)
      await fileIo.write(fileIo.openSync(thumbnailPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE), imageData)

      return thumbnailPath
    } catch (error) {
      console.error('生成缩略图失败:', error)
      return imagePath // 失败时返回原图路径
    }
  }

  /**
   * 计算缩略图尺寸
   */
  private static calculateThumbnailSize(originalWidth: number, originalHeight: number, maxSize: number): { width: number, height: number } {
    let width = originalWidth
    let height = originalHeight

    if (width > height) {
      if (width > maxSize) {
        height = (height * maxSize) / width
        width = maxSize
      }
    } else {
      if (height > maxSize) {
        width = (width * maxSize) / height
        height = maxSize
      }
    }

    return { width: Math.round(width), height: Math.round(height) }
  }

  /**
   * 上传文件到服务器
   */
  static async uploadFile(filePath: string, onProgress?: (progress: number) => void): Promise<string> {
    return new Promise((resolve, reject) => {
      try {
        // 模拟上传过程
        let progress = 0
        const interval = setInterval(() => {
          progress += Math.random() * 15
          if (progress >= 100) {
            progress = 100
            clearInterval(interval)
            
            // 模拟服务器返回的文件URL
            const fileUrl = `https://example.com/uploads/${Date.now()}_${Math.random().toString(36).substr(2, 9)}.jpg`
            resolve(fileUrl)
          }
          
          onProgress?.(progress)
        }, 100)

        // 实际项目中，这里应该是真实的网络上传逻辑
        // 例如使用 request.uploadFile 或其他网络库
        /*
        const uploadTask = request.uploadFile(getContext(), {
          url: 'https://your-server.com/upload',
          header: { 'Content-Type': 'multipart/form-data' },
          method: 'POST',
          files: [{
            filename: filePath.substring(filePath.lastIndexOf('/') + 1),
            name: 'file',
            uri: filePath,
            type: this.getMimeTypeFromPath(filePath)
          }],
          data: []
        })

        uploadTask.on('progress', (uploadedSize: number, totalSize: number) => {
          const progress = (uploadedSize / totalSize) * 100
          onProgress?.(progress)
        })

        uploadTask.on('complete', (result) => {
          resolve(result.body)
        })

        uploadTask.on('fail', (error) => {
          reject(error)
        })
        */

      } catch (error) {
        reject(error)
      }
    })
  }

  /**
   * 批量上传文件
   */
  static async uploadMultipleFiles(
    filePaths: string[], 
    onProgress?: (fileIndex: number, progress: number) => void,
    onComplete?: (fileIndex: number, url: string) => void
  ): Promise<string[]> {
    const uploadPromises = filePaths.map((filePath, index) => {
      return this.uploadFile(filePath, (progress) => {
        onProgress?.(index, progress)
      }).then((url) => {
        onComplete?.(index, url)
        return url
      })
    })

    return Promise.all(uploadPromises)
  }

  /**
   * 压缩图片
   */
  static async compressImage(imagePath: string, quality: number = 80): Promise<string> {
    try {
      const imageSource = image.createImageSource(imagePath)
      const pixelMap = await imageSource.createPixelMap()

      const context = getContext() as common.UIAbilityContext
      const compressedPath = `${context.cacheDir}/compressed_${Date.now()}.jpg`

      const imagePackerApi = image.createImagePacker()
      const packOpts: image.PackingOption = {
        format: "image/jpeg",
        quality: quality
      }

      const imageData = await imagePackerApi.packing(pixelMap, packOpts)
      await fileIo.write(fileIo.openSync(compressedPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE), imageData)

      return compressedPath
    } catch (error) {
      console.error('压缩图片失败:', error)
      return imagePath
    }
  }

  /**
   * 根据文件扩展名获取MIME类型
   */
  private static getMimeTypeFromExtension(fileName: string): string {
    const extension = fileName.toLowerCase().split('.').pop()
    
    const mimeTypes: Record<string, string> = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'bmp': 'image/bmp',
      'webp': 'image/webp'
    }

    return mimeTypes[extension || ''] || 'image/jpeg'
  }

  /**
   * 验证文件类型
   */
  static isValidImageFile(fileName: string): boolean {
    const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
    const extension = fileName.toLowerCase().split('.').pop()
    return validExtensions.includes(extension || '')
  }

  /**
   * 验证文件大小
   */
  static isValidFileSize(fileSize: number, maxSizeMB: number = 10): boolean {
    const maxSizeBytes = maxSizeMB * 1024 * 1024
    return fileSize <= maxSizeBytes
  }

  /**
   * 格式化文件大小
   */
  static formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B'
    
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  /**
   * 生成唯一文件名
   */
  static generateUniqueFileName(originalName: string): string {
    const timestamp = Date.now()
    const random = Math.random().toString(36).substr(2, 9)
    const extension = originalName.split('.').pop()
    
    return `${timestamp}_${random}.${extension}`
  }
}