import UIKit

extension UIImage {
    // Метод для создания изображения в новом масштабе с возможностью сохранения пропорций изображения
    func scaleImage(targetWidth: Double? = nil, targetHeight: Double? = nil) -> UIImage {
        
        // Отношение сторон прямоугольника изображения
        let aspectRatio: Double = (self.size.width) / (self.size.height)
        
        // Перемнные, хранящие новые размеры для изображения
        var newWidth: Double!
        var newHeight: Double!
        
        // Оператор выбора, присваивающий новые размеры изображения переменным newWidth и newHeight
        switch (targetWidth, targetHeight) {
            
        case (targetWidth, nil):
            newWidth = targetWidth
            newHeight = newWidth / aspectRatio
            
        case (nil, targetHeight):
            newHeight = targetHeight
            newWidth = newHeight * aspectRatio
            
        case (targetWidth, targetHeight):
            newWidth = targetWidth
            newHeight = targetHeight
            
        default:
            return self
        }
        
        // Константа, хранящая новый размер изображения
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // Константа, хранящая визуализатор изображения, которому присвоен размер, соответствующий новому размеру изображения
        let render = UIGraphicsImageRenderer(size: newSize)
        
        // Константа newImage хранит изображение, которое возвращется методом "image(actions:)"
        let newImage = render.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        // Возврат изображения
        return newImage
    }
}


