///|
/// 二维点结构
pub(all) struct Point {
  mut x : Float
  mut y : Float
} derive(Show)

///|
/// 区域边界
pub(all) struct Rect {
  mut x : Float // 左上角 x
  mut y : Float // 左上角 y
  mut width : Float
  mut height : Float
} derive(Show)

///|
/// 四叉树节点
pub(all) enum QuadtreeNode[T] {
  Leaf(
    mut points~ : Array[(Point, T)], // 存储点和内容
    mut boundary~ : Rect
  )
  Internal(
    mut children~ : Array[QuadtreeNode[T]], // 四个子节点
    mut boundary~ : Rect
  )
}

///|
pub impl Eq for Point with equal(self : Point, other : Point) -> Bool {
  self.x == other.x && self.y == other.y
}

///|
/// Rect 的 Eq 实现
pub impl Eq for Rect with equal(self : Rect, other : Rect) -> Bool {
  self.x == other.x &&
  self.y == other.y &&
  self.width == other.width &&
  self.height == other.height
}
