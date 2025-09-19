///|
/// 创建一个空四叉树
pub fn[T] new(boundary : Rect) -> QuadtreeNode[T] {
  QuadtreeNode::Leaf(points=Array::new(), boundary~)
}

///|
/// 判断点是否在矩形范围内
pub fn point_in_rect(p : Point, rect : Rect) -> Bool {
  p.x >= rect.x &&
  p.x <= rect.x + rect.width &&
  p.y >= rect.y &&
  p.y <= rect.y + rect.height
}

///|
/// 将矩形分为四个子区域
pub fn subdivide(rect : Rect) -> Array[Rect] {
  let hw = rect.width / 2.0
  let hh = rect.height / 2.0
  let arr = Array::new()
  arr.push(Rect::{ x: rect.x, y: rect.y, width: hw, height: hh }) // 左上
  arr.push(Rect::{ x: rect.x + hw, y: rect.y, width: hw, height: hh }) // 右上
  arr.push(Rect::{ x: rect.x, y: rect.y + hh, width: hw, height: hh }) // 左下
  arr.push(Rect::{ x: rect.x + hw, y: rect.y + hh, width: hw, height: hh }) // 右下
  arr
}

///|
pub fn[T] insert(
  node : QuadtreeNode[T],
  point : Point,
  value : T,
  capacity : Int,
) -> QuadtreeNode[T] {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let points = leaf.points
      let boundary = leaf.boundary
      if !point_in_rect(point, boundary) {
        return node
      }
      if points.length() < capacity {
        points.push((point, value))
        return node
      }
      // 超过容量，分裂为 Internal
      let subrects = subdivide(boundary)
      let children = Array::makei(4, i => new(subrects[i]))
      for i in 0..<points.length() {
        let (pt, val) = points[i]
        for j in 0..<4 {
          if point_in_rect(pt, subrects[j]) {
            children[j] = insert(children[j], pt, val, capacity)
            break
          }
        }
      }
      for j in 0..<4 {
        if point_in_rect(point, subrects[j]) {
          children[j] = insert(children[j], point, value, capacity)
          break
        }
      }
      return QuadtreeNode::Internal(children~, boundary~)
    }
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      for i in 0..<children.length() {
        let child = children[i]
        match child {
          QuadtreeNode::Leaf(..) as leaf => {
            let b = leaf.boundary
            if point_in_rect(point, b) {
              children[i] = insert(child, point, value, capacity)
              return node
            }
          }
          QuadtreeNode::Internal(..) as sub_internal => {
            let b = sub_internal.boundary
            if point_in_rect(point, b) {
              children[i] = insert(child, point, value, capacity)
              return node
            }
          }
        }
      }
      return node
    }
  }
}

///|
/// 判断两个矩形是否相交
pub fn rect_intersect(a : Rect, b : Rect) -> Bool {
  !(a.x + a.width < b.x ||
  b.x + b.width < a.x ||
  a.y + a.height < b.y ||
  b.y + b.height < a.y)
}

///|
pub fn[T] query(
  node : QuadtreeNode[T],
  range : Rect,
  result : Array[(Point, T)],
) -> Unit {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let points = leaf.points
      let boundary = leaf.boundary
      if !rect_intersect(boundary, range) {
        return
      }
      for i in 0..<points.length() {
        let (pt, val) = points[i]
        if point_in_rect(pt, range) {
          result.push((pt, val))
        }
      }
    }
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let boundary = internal.boundary
      if !rect_intersect(boundary, range) {
        return
      }
      for i in 0..<children.length() {
        query(children[i], range, result)
      }
    }
  }
}

///|
/// 清空四叉树，返回空树
pub fn[T] clear(boundary : Rect) -> QuadtreeNode[T] {
  new(boundary)
}

///|
/// 统计四叉树中所有点的数量
pub fn[T] count(node : QuadtreeNode[T]) -> Int {
  match node {
    QuadtreeNode::Leaf(..) as leaf => leaf.points.length()
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let mut total = 0
      for i in 0..<children.length() {
        total += count(children[i])
      }
      total
    }
  }
}

///|
/// 批量插入多个点及内容
pub fn[T] insert_many(
  node : QuadtreeNode[T],
  points : Array[Point],
  values : Array[T],
  capacity : Int,
) -> QuadtreeNode[T] {
  let len = @cmp.minimum(points.length(), values.length())
  let mut result = node
  for i in 0..<len {
    result = insert(result, points[i], values[i], capacity)
  }
  result
}

///|
/// 删除四叉树中的指定点
pub fn[T] remove(
  node : QuadtreeNode[T],
  point : Point,
  capacity : Int,
) -> QuadtreeNode[T] {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let points = leaf.points
      let boundary = leaf.boundary
      let new_points = Array::new()
      for i in 0..<points.length() {
        let (pt, val) = points[i]
        if pt != point {
          new_points.push((pt, val))
        }
      }
      QuadtreeNode::Leaf(points=new_points, boundary~)
    }
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let boundary = internal.boundary
      let new_children = Array::makei(children.length(), i => remove(
        children[i],
        point,
        capacity,
      ))
      // 应用压缩
      compress_node(QuadtreeNode::Internal(children=new_children, boundary~))
    }
  }
}

///|
/// 更新四叉树中指定点的内容
pub fn[T] update(
  node : QuadtreeNode[T],
  point : Point,
  new_value : T,
  capacity : Int,
) -> QuadtreeNode[T] {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let points = leaf.points
      let boundary = leaf.boundary
      let new_points = Array::new()
      for i in 0..<points.length() {
        let (pt, val) = points[i]
        if pt == point {
          new_points.push((pt, new_value))
        } else {
          new_points.push((pt, val))
        }
      }
      QuadtreeNode::Leaf(points=new_points, boundary~)
    }
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let boundary = internal.boundary
      let new_children = Array::makei(children.length(), i => update(
        children[i],
        point,
        new_value,
        capacity,
      ))
      QuadtreeNode::Internal(children=new_children, boundary~)
    }
  }
}

///|
/// 遍历四叉树所有点及内容，收集到数组
pub fn[T] to_array(node : QuadtreeNode[T], result : Array[(Point, T)]) -> Unit {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let points = leaf.points
      for i in 0..<points.length() {
        result.push(points[i])
      }
    }
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      for i in 0..<children.length() {
        to_array(children[i], result)
      }
    }
  }
}

///|
/// 删除某一区域内的所有点
pub fn[T] remove_range(
  node : QuadtreeNode[T],
  range : Rect,
  capacity : Int,
) -> QuadtreeNode[T] {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let points = leaf.points
      let boundary = leaf.boundary
      let new_points = Array::new()
      for i in 0..<points.length() {
        let (pt, val) = points[i]
        if !point_in_rect(pt, range) {
          new_points.push((pt, val))
        }
      }
      QuadtreeNode::Leaf(points=new_points, boundary~)
    }
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let boundary = internal.boundary
      let new_children = Array::makei(children.length(), i => remove_range(
        children[i],
        range,
        capacity,
      ))
      compress_node(QuadtreeNode::Internal(children=new_children, boundary~))
    }
  }
}

///|
/// 节点合并与压缩：如果所有子节点都是空Leaf，则合并为一个空Leaf

///|
/// 节点合并与压缩：如果所有子节点都是空Leaf，则合并为一个空Leaf
pub fn[T] compress_node(node : QuadtreeNode[T]) -> QuadtreeNode[T] {
  match node {
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let boundary = internal.boundary

      // 首先递归压缩所有子节点
      let new_children = Array::makei(children.length(), i => compress_node(
        children[i],
      ))

      // 然后检查压缩后的子节点是否都是空的叶节点
      let mut all_empty = true
      for i in 0..<new_children.length() {
        match new_children[i] {
          QuadtreeNode::Leaf(..) as leaf =>
            if leaf.points.length() != 0 {
              all_empty = false
            }
          QuadtreeNode::Internal(..) => all_empty = false
        }
      }
      if all_empty {
        QuadtreeNode::Leaf(points=Array::new(), boundary~)
      } else {
        QuadtreeNode::Internal(children=new_children, boundary~)
      }
    }
    _ => node
  }
}

///|
/// 查找某个点的内容
pub fn[T : Eq] find(node : QuadtreeNode[T], point : Point) -> T? {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let points = leaf.points
      for i in 0..<points.length() {
        let (pt, val) = points[i]
        if pt == point {
          return Some(val)
        }
      }
      None
    }
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      for i in 0..<children.length() {
        let result = find(children[i], point)
        if result != None {
          return result
        }
      }
      None
    }
  }
}

///|
/// 统计四叉树的最大深度
pub fn[T] depth(node : QuadtreeNode[T]) -> Int {
  match node {
    QuadtreeNode::Leaf(..) => 1
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let mut max_depth = 0
      for i in 0..<children.length() {
        let d = depth(children[i])
        if d > max_depth {
          max_depth = d
        }
      }
      max_depth + 1
    }
  }
}

///|
/// 批量查询多个区域
pub fn[T] query_many(
  node : QuadtreeNode[T],
  ranges : Array[Rect],
) -> Array[(Point, T)] {
  let result = Array::new()
  for i in 0..<ranges.length() {
    query(node, ranges[i], result)
  }
  result
}

///|
/// 统计 Leaf 和 Internal 节点数量
pub fn[T] count_nodes(node : QuadtreeNode[T]) -> (Int, Int) {
  match node {
    QuadtreeNode::Leaf(..) => (1, 0)
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let mut leaf_count = 0
      let mut internal_count = 1
      for i in 0..<children.length() {
        let (l, inl) = count_nodes(children[i])
        leaf_count += l
        internal_count += inl
      }
      (leaf_count, internal_count)
    }
  }
}

///|
/// 找出最近的 K 个点 (K-Nearest Neighbors)
pub fn[T] find_nearest(
  node : QuadtreeNode[T],
  target : Point,
  k : Int,
) -> Array[(Point, T, Float)] {
  // 收集所有点
  let all_points = Array::new()
  to_array(node, all_points)

  // 计算距离并排序
  let distances = Array::new()
  for i in 0..<all_points.length() {
    let (pt, val) = all_points[i]
    let dist = distance(pt, target)
    distances.push((pt, val, dist))
  }

  // 根据距离排序
  distances.sort_by(distance_cmp)

  // 返回前 k 个点
  let result = Array::new()
  for i in 0..<@cmp.minimum(k, distances.length()) {
    result.push(distances[i])
  }
  result
}

///|
/// 距离比较函数用于排序
fn[T] distance_cmp(a : (Point, T, Float), b : (Point, T, Float)) -> Int {
  if a.2 < b.2 {
    -1
  } else if a.2 > b.2 {
    1
  } else {
    0
  }
}

///|
/// 计算两点间欧几里得距离
fn distance(a : Point, b : Point) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  @math.powf(dx * dx + dy * dy, 0.5)
}

///|
/// 查找密度最高的区域
pub fn[T] find_hotspot(node : QuadtreeNode[T], grid_size : Int) -> (Rect, Int) {
  let all_points = Array::new()
  to_array(node, all_points)

  // 如果点太少，返回整个区域
  if all_points.length() < 3 {
    match node {
      QuadtreeNode::Leaf(..) as leaf =>
        return (leaf.boundary, all_points.length())
      QuadtreeNode::Internal(..) as internal =>
        return (internal.boundary, all_points.length())
    }
  }

  // 计算整体边界
  let (min_x, min_y, max_x, max_y) = get_points_boundary(all_points)

  // 划分网格
  let cell_width = (max_x - min_x) / grid_size.to_float()
  let cell_height = (max_y - min_y) / grid_size.to_float()

  // 统计每个网格中的点数
  let mut max_count = 0
  let mut max_cell = Rect::{
    x: min_x,
    y: min_y,
    width: cell_width,
    height: cell_height,
  }
  for i in 0..<grid_size {
    for j in 0..<grid_size {
      let cell = Rect::{
        x: min_x + i.to_float() * cell_width,
        y: min_y + j.to_float() * cell_height,
        width: cell_width,
        height: cell_height,
      }
      let count = count_points_in_rect(all_points, cell)
      if count > max_count {
        max_count = count
        max_cell = cell
      }
    }
  }
  (max_cell, max_count)
}

///|
/// 获取点集的边界
fn[T] get_points_boundary(
  points : Array[(Point, T)],
) -> (Float, Float, Float, Float) {
  if points.length() == 0 {
    return (0.0, 0.0, 0.0, 0.0)
  }
  let mut min_x = points[0].0.x
  let mut min_y = points[0].0.y
  let mut max_x = points[0].0.x
  let mut max_y = points[0].0.y
  for i in 1..<points.length() {
    let pt = points[i].0
    min_x = @cmp.minimum(min_x, pt.x)
    min_y = @cmp.minimum(min_y, pt.y)
    max_x = @cmp.maximum(max_x, pt.x)
    max_y = @cmp.maximum(max_y, pt.y)
  }
  (min_x, min_y, max_x, max_y)
}

///|
/// 计算矩形内点的数量
fn[T] count_points_in_rect(points : Array[(Point, T)], rect : Rect) -> Int {
  let mut count = 0
  for i in 0..<points.length() {
    if point_in_rect(points[i].0, rect) {
      count += 1
    }
  }
  count
}

///|
/// 定义一个 ToFloat trait，用于将类型转换为 Float
pub trait ToFloat {
  to_float(Self) -> Float
}

///|
/// 计算空间自相关性（类似Moran's I）
pub fn[T : ToFloat] spatial_autocorrelation(node : QuadtreeNode[T]) -> Float {
  let points = Array::new()
  to_array(node, points)
  if points.length() < 2 {
    return 0.0
  }

  // 提取值并计算平均值
  let values = Array::new()
  for i in 0..<points.length() {
    values.push(points[i].1.to_float())
  }
  let mean = calculate_mean(values)

  // 计算空间权重和协方差
  let mut sum_weights : Float = 0.0
  let mut sum_products : Float = 0.0
  let mut sum_squared_diff : Float = 0.0
  for i in 0..<points.length() {
    let diff_i : Float = values[i] - mean
    sum_squared_diff += diff_i * diff_i
    for j in 0..<points.length() {
      if i != j {
        let weight : Float = 1.0 / distance(points[i].0, points[j].0)
        sum_weights += weight
        sum_products += weight * diff_i * (values[j] - mean)
      }
    }
  }

  // 计算Moran's I
  let n = points.length().to_float()
  n / sum_weights * (sum_products / sum_squared_diff)
}

///|
/// 计算数组平均值
fn calculate_mean(values : Array[Float]) -> Float {
  if values.length() == 0 {
    return 0.0
  }
  let mut sum : Float = 0.0
  for i in 0..<values.length() {
    sum += values[i]
  }
  sum / values.length().to_float()
}

///|
/// 合并两个四叉树
pub fn[T] merge(
  tree1 : QuadtreeNode[T],
  tree2 : QuadtreeNode[T],
  capacity : Int,
) -> QuadtreeNode[T] {
  // 获取两棵树的点
  let points1 = Array::new()
  let points2 = Array::new()
  to_array(tree1, points1)
  to_array(tree2, points2)

  // 确定合并后的边界
  let boundary = match tree1 {
    QuadtreeNode::Leaf(..) as leaf => leaf.boundary
    QuadtreeNode::Internal(..) as internal => internal.boundary
  }

  // 创建新树
  let mut merged = new(boundary)

  // 插入第一棵树的所有点
  for i in 0..<points1.length() {
    let (pt, val) = points1[i]
    merged = insert(merged, pt, val, capacity)
  }

  // 插入第二棵树的所有点
  for i in 0..<points2.length() {
    let (pt, val) = points2[i]
    merged = insert(merged, pt, val, capacity)
  }
  merged
}

///|
/// 差集操作 - 从tree1中移除tree2中存在的点
pub fn[T] difference(
  tree1 : QuadtreeNode[T],
  tree2 : QuadtreeNode[T],
  capacity : Int,
) -> QuadtreeNode[T] {
  // 获取两棵树的点
  let points1 = Array::new()
  let points2 = Array::new()
  to_array(tree1, points1)
  to_array(tree2, points2)

  // 获取tree1的边界
  let boundary = match tree1 {
    QuadtreeNode::Leaf(..) as leaf => leaf.boundary
    QuadtreeNode::Internal(..) as internal => internal.boundary
  }

  // 创建新树
  let mut result = new(boundary)

  // 仅添加tree1中不在tree2中的点
  for i in 0..<points1.length() {
    let (pt1, val1) = points1[i]
    let mut exists = false
    for j in 0..<points2.length() {
      let (pt2, _) = points2[j]
      if pt1 == pt2 {
        exists = true
        break
      }
    }
    if !exists {
      result = insert(result, pt1, val1, capacity)
    }
  }
  result
}

///|
/// 根据条件筛选点
pub fn[T] filter(
  node : QuadtreeNode[T],
  predicate : (Point, T) -> Bool,
  capacity : Int,
) -> QuadtreeNode[T] {
  // 获取所有点
  let points = Array::new()
  to_array(node, points)

  // 获取边界
  let boundary = match node {
    QuadtreeNode::Leaf(..) as leaf => leaf.boundary
    QuadtreeNode::Internal(..) as internal => internal.boundary
  }

  // 创建新树
  let mut filtered = new(boundary)

  // 仅添加满足条件的点
  for i in 0..<points.length() {
    let (pt, val) = points[i]
    if predicate(pt, val) {
      filtered = insert(filtered, pt, val, capacity)
    }
  }
  filtered
}

///|
/// 序列化四叉树为JSON格式字符串
pub fn[T : Show] serialize(node : QuadtreeNode[T]) -> String {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let mut json = "{"
      json += "\"type\":\"leaf\","
      json += "\"boundary\":{\\"
      json += "\"x\":\{leaf.boundary.x},"
      json += "\"y\":\{leaf.boundary.y},"
      json += "\"width\":\{leaf.boundary.width},"
      json += "\"height\":\{leaf.boundary.height}"
      json += "},"
      json += "\"points\":["
      for i in 0..<leaf.points.length() {
        if i > 0 {
          json += ","
        }
        let (pt, val) = leaf.points[i]
        json += "{"
        json += "\"x\":\{pt.x},"
        json += "\"y\":\{pt.y},"
        json += "\"value\":\"\{val}\""
        json += "}"
      }
      json += "]"
      json += "}"
      json
    }
    QuadtreeNode::Internal(..) as internal => {
      let mut json = "{"
      json += "\"type\":\"internal\","
      json += "\"boundary\":{\\"
      json += "\"x\":\{internal.boundary.x},"
      json += "\"y\":\{internal.boundary.y},"
      json += "\"width\":\{internal.boundary.width},"
      json += "\"height\":\{internal.boundary.height}"
      json += "},"
      json += "\"children\":["
      for i in 0..<internal.children.length() {
        if i > 0 {
          json += ","
        }
        json += serialize(internal.children[i])
      }
      json += "]"
      json += "}"
      json
    }
  }
}

///|
/// 相交操作 - 找出两个四叉树共有的点
pub fn[T] intersection(
  tree1 : QuadtreeNode[T],
  tree2 : QuadtreeNode[T],
  capacity : Int,
) -> QuadtreeNode[T] {
  // 获取两棵树的点
  let points1 = Array::new()
  let points2 = Array::new()
  to_array(tree1, points1)
  to_array(tree2, points2)

  // 获取tree1的边界
  let boundary = match tree1 {
    QuadtreeNode::Leaf(..) as leaf => leaf.boundary
    QuadtreeNode::Internal(..) as internal => internal.boundary
  }

  // 创建新树
  let mut result = new(boundary)

  // 添加两棵树都有的点
  for i in 0..<points1.length() {
    let (pt1, val1) = points1[i]
    for j in 0..<points2.length() {
      let (pt2, _) = points2[j]
      if pt1 == pt2 {
        result = insert(result, pt1, val1, capacity)
        break
      }
    }
  }
  result
}

///|
/// 使用DBSCAN算法进行点云聚类
pub fn[T] dbscan_cluster(
  node : QuadtreeNode[T],
  eps : Float,
  min_points : Int,
) -> Array[Array[Point]] {
  // 获取所有点
  let points_with_vals = Array::new()
  to_array(node, points_with_vals)

  // 提取点坐标
  let points = Array::new()
  for i in 0..<points_with_vals.length() {
    points.push(points_with_vals[i].0)
  }

  // 初始化
  let visited = Array::makei(points.length(), fn(_) -> Bool { false })
  let cluster_id = Array::makei(points.length(), fn(_) -> Int { -1 }) // -1表示噪声点
  let clusters = Array::new()
  let mut current_cluster = 0

  // 对每个点执行DBSCAN
  for i in 0..<points.length() {
    if visited[i] {
      continue
    }
    visited[i] = true
    let neighbors = region_query(points, i, eps)

    // 如果不满足密度要求，标记为噪声点
    if neighbors.length() < min_points {
      cluster_id[i] = -1
    } else {
      // 创建新簇
      let new_cluster = Array::new()
      new_cluster.push(points[i])
      cluster_id[i] = current_cluster

      // 扩展簇
      let mut j = 0
      while j < neighbors.length() {
        let neighbor_index = neighbors[j]
        if !visited[neighbor_index] {
          visited[neighbor_index] = true
          let more_neighbors = region_query(points, neighbor_index, eps)
          if more_neighbors.length() >= min_points {
            // 合并邻居
            for k in 0..<more_neighbors.length() {
              if !neighbors.contains(more_neighbors[k]) {
                neighbors.push(more_neighbors[k])
              }
            }
          }
        }

        // 如果邻居还没被分配到簇
        if cluster_id[neighbor_index] == -1 {
          cluster_id[neighbor_index] = current_cluster
          new_cluster.push(points[neighbor_index])
        }
        j += 1
      }

      // 添加簇
      clusters.push(new_cluster)
      current_cluster += 1
    }
  }
  clusters
}

///|
/// 查找半径eps内的所有点索引
fn region_query(
  points : Array[Point],
  point_idx : Int,
  eps : Float,
) -> Array[Int] {
  let result = Array::new()
  for i in 0..<points.length() {
    if distance(points[point_idx], points[i]) <= eps {
      result.push(i)
    }
  }
  result
}

///|
/// 基于点的分布密度自适应划分
pub fn[T] insert_adaptive(
  node : QuadtreeNode[T],
  point : Point,
  value : T,
  min_capacity : Int,
  max_capacity : Int,
  density_threshold : Float,
) -> QuadtreeNode[T] {
  match node {
    QuadtreeNode::Leaf(..) as leaf => {
      let points = leaf.points
      let boundary = leaf.boundary
      if !point_in_rect(point, boundary) {
        return node
      }

      // 计算当前区域密度
      let area = boundary.width * boundary.height
      let current_density = points.length().to_float() / area

      // 根据密度决定容量
      let adaptive_capacity = if current_density > density_threshold {
        min_capacity // 高密度区域使用较小容量，更频繁分裂
      } else {
        max_capacity // 低密度区域使用较大容量，减少分裂
      }

      // 使用计算出的容量决定是否分裂
      if points.length() < adaptive_capacity {
        points.push((point, value))
        return node
      }

      // 超过容量，分裂为 Internal
      let subrects = subdivide(boundary)
      let children = Array::makei(4, i => new(subrects[i]))

      // 将现有点分配到子节点
      for i in 0..<points.length() {
        let (pt, val) = points[i]
        for j in 0..<4 {
          if point_in_rect(pt, subrects[j]) {
            children[j] = insert_adaptive(
              children[j],
              pt,
              val,
              min_capacity,
              max_capacity,
              density_threshold,
            )
            break
          }
        }
      }

      // 将新点分配到子节点
      for j in 0..<4 {
        if point_in_rect(point, subrects[j]) {
          children[j] = insert_adaptive(
            children[j],
            point,
            value,
            min_capacity,
            max_capacity,
            density_threshold,
          )
          break
        }
      }
      return QuadtreeNode::Internal(children~, boundary~)
    }
    QuadtreeNode::Internal(..) as internal => {
      let children = internal.children
      let boundary = internal.boundary
      if !point_in_rect(point, boundary) {
        return node
      }

      // 确定点应该插入哪个子节点
      for i in 0..<children.length() {
        let child = children[i]
        let child_boundary = match child {
          QuadtreeNode::Leaf(..) as leaf => leaf.boundary
          QuadtreeNode::Internal(..) as sub_internal => sub_internal.boundary
        }
        if point_in_rect(point, child_boundary) {
          children[i] = insert_adaptive(
            child, point, value, min_capacity, max_capacity, density_threshold,
          )
          return node
        }
      }

      // 如果点不在任何子节点中（理论上不应该发生）
      return node
    }
  }
}

///|
/// 圆形范围查询（迭代版本）
pub fn[T] query_circle(
  node : QuadtreeNode[T],
  center : Point,
  radius : Float,
  result : Array[(Point, T)],
) -> Unit {
  let stack = Array::new()
  stack.push(node)
  while stack.length() > 0 {
    let current = stack.pop()
    match current {
      Some(node) =>
        match node {
          QuadtreeNode::Leaf(..) as leaf => {
            let points = leaf.points
            let boundary = leaf.boundary
            if !circle_rect_intersect(center, radius, boundary) {
              continue
            }
            for i in 0..<points.length() {
              let (pt, val) = points[i]
              if distance(pt, center) <= radius {
                result.push((pt, val))
              }
            }
          }
          QuadtreeNode::Internal(..) as internal => {
            let children = internal.children
            let boundary = internal.boundary
            if !circle_rect_intersect(center, radius, boundary) {
              continue
            }
            for i in 0..<children.length() {
              stack.push(children[i])
            }
          }
        }
      None => break
    }
  }
}

///|
/// 多边形范围查询（迭代版本）
pub fn[T] query_polygon(
  node : QuadtreeNode[T],
  polygon : Array[Point],
  result : Array[(Point, T)],
) -> Unit {
  let stack = Array::new()
  stack.push(node)
  while stack.length() > 0 {
    let current = stack.pop()
    match current {
      Some(node) =>
        match node {
          QuadtreeNode::Leaf(..) as leaf => {
            let points = leaf.points
            let boundary = leaf.boundary
            if !polygon_rect_intersect(polygon, boundary) {
              continue
            }
            for i in 0..<points.length() {
              let (pt, val) = points[i]
              if point_in_polygon(pt, polygon) {
                result.push((pt, val))
              }
            }
          }
          QuadtreeNode::Internal(..) as internal => {
            let children = internal.children
            let boundary = internal.boundary
            if !polygon_rect_intersect(polygon, boundary) {
              continue
            }
            for i in 0..<children.length() {
              stack.push(children[i])
            }
          }
        }
      None => break
    }
  }
}

///|
/// 射线查询（迭代版本）
pub fn[T] query_ray(
  node : QuadtreeNode[T],
  origin : Point,
  direction : Point,
  max_distance : Float,
  result : Array[(Point, T)],
) -> Unit {
  let stack = Array::new()
  stack.push(node)
  while stack.length() > 0 {
    let current = stack.pop()
    match current {
      Some(node) =>
        match node {
          QuadtreeNode::Leaf(..) as leaf => {
            let points = leaf.points
            let boundary = leaf.boundary
            if !ray_rect_intersect(origin, direction, max_distance, boundary) {
              continue
            }
            for i in 0..<points.length() {
              let (pt, val) = points[i]
              if point_on_ray(pt, origin, direction, max_distance) {
                result.push((pt, val))
              }
            }
          }
          QuadtreeNode::Internal(..) as internal => {
            let children = internal.children
            let boundary = internal.boundary
            if !ray_rect_intersect(origin, direction, max_distance, boundary) {
              continue
            }
            for i in 0..<children.length() {
              stack.push(children[i])
            }
          }
        }
      None => break
    }
  }
}

///|
/// 扇形范围查询（迭代版本）
pub fn[T] query_sector(
  node : QuadtreeNode[T],
  center : Point,
  start_angle : Float,
  end_angle : Float,
  radius : Float,
  result : Array[(Point, T)],
) -> Unit {
  let stack = Array::new()
  stack.push(node)
  while stack.length() > 0 {
    let current = stack.pop()
    match current {
      Some(node) =>
        match node {
          QuadtreeNode::Leaf(..) as leaf => {
            let points = leaf.points
            let boundary = leaf.boundary
            if !sector_rect_intersect(
                center, start_angle, end_angle, radius, boundary,
              ) {
              continue
            }
            for i in 0..<points.length() {
              let (pt, val) = points[i]
              if point_in_sector(pt, center, start_angle, end_angle, radius) {
                result.push((pt, val))
              }
            }
          }
          QuadtreeNode::Internal(..) as internal => {
            let children = internal.children
            let boundary = internal.boundary
            if !sector_rect_intersect(
                center, start_angle, end_angle, radius, boundary,
              ) {
              continue
            }
            for i in 0..<children.length() {
              stack.push(children[i])
            }
          }
        }
      None => break
    }
  }
}

///|
/// 检查圆形与矩形是否相交
fn circle_rect_intersect(center : Point, radius : Float, rect : Rect) -> Bool {
  // 找到矩形上离圆心最近的点
  let closest_x = @cmp.maximum(
    rect.x,
    @cmp.minimum(center.x, rect.x + rect.width),
  )
  let closest_y = @cmp.maximum(
    rect.y,
    @cmp.minimum(center.y, rect.y + rect.height),
  )
  let closest_point = Point::{ x: closest_x, y: closest_y }

  // 检查最近点到圆心的距离是否小于等于半径
  distance(center, closest_point) <= radius
}

///|
/// 检查多边形与矩形是否相交
fn polygon_rect_intersect(polygon : Array[Point], rect : Rect) -> Bool {
  if polygon.length() < 3 {
    return false
  }

  // 检查多边形的任何顶点是否在矩形内
  for i in 0..<polygon.length() {
    if point_in_rect(polygon[i], rect) {
      return true
    }
  }

  // 检查矩形的任何顶点是否在多边形内
  let rect_corners = [
    Point::{ x: rect.x, y: rect.y },
    Point::{ x: rect.x + rect.width, y: rect.y },
    Point::{ x: rect.x + rect.width, y: rect.y + rect.height },
    Point::{ x: rect.x, y: rect.y + rect.height },
  ]
  for i in 0..<4 {
    if point_in_polygon(rect_corners[i], polygon) {
      return true
    }
  }

  // 检查多边形边与矩形边是否相交
  for i in 0..<polygon.length() {
    let p1 = polygon[i]
    let p2 = polygon[(i + 1) % polygon.length()]
    if line_rect_intersect(p1, p2, rect) {
      return true
    }
  }
  false
}

///|
/// 检查射线与矩形是否相交
fn ray_rect_intersect(
  origin : Point,
  direction : Point,
  max_distance : Float,
  rect : Rect,
) -> Bool {
  // 标准化方向向量
  let dir_length = distance(origin, Point::{
    x: origin.x + direction.x,
    y: origin.y + direction.y,
  })
  if dir_length == 0.0 {
    return point_in_rect(origin, rect)
  }
  let normalized_dir = Point::{
    x: direction.x / dir_length,
    y: direction.y / dir_length,
  }

  // 计算射线与矩形边界的交点
  let t_min : Float = 0.0
  let t_max = max_distance

  // 检查与左右边界的交点
  if normalized_dir.x != 0.0 {
    let t1 = (rect.x - origin.x) / normalized_dir.x
    let t2 = (rect.x + rect.width - origin.x) / normalized_dir.x
    let t_left = @cmp.minimum(t1, t2)
    let t_right = @cmp.maximum(t1, t2)
    if t_left > t_max || t_right < t_min {
      return false
    }
    // 射线平行于y轴
  } else if origin.x < rect.x || origin.x > rect.x + rect.width {
    return false
  }

  // 检查与上下边界的交点
  if normalized_dir.y != 0.0 {
    let t1 = (rect.y - origin.y) / normalized_dir.y
    let t2 = (rect.y + rect.height - origin.y) / normalized_dir.y
    let t_bottom = @cmp.minimum(t1, t2)
    let t_top = @cmp.maximum(t1, t2)
    if t_bottom > t_max || t_top < t_min {
      return false
    }
    // 射线平行于x轴
  } else if origin.y < rect.y || origin.y > rect.y + rect.height {
    return false
  }
  true
}

///|
/// 检查扇形与矩形是否相交
fn sector_rect_intersect(
  center : Point,
  start_angle : Float,
  end_angle : Float,
  radius : Float,
  rect : Rect,
) -> Bool {
  // 首先检查圆形边界是否与矩形相交
  if !circle_rect_intersect(center, radius, rect) {
    return false
  }

  // 检查矩形的任何顶点是否在扇形内
  let rect_corners = [
    Point::{ x: rect.x, y: rect.y },
    Point::{ x: rect.x + rect.width, y: rect.y },
    Point::{ x: rect.x + rect.width, y: rect.y + rect.height },
    Point::{ x: rect.x, y: rect.y + rect.height },
  ]
  for i in 0..<4 {
    if point_in_sector(rect_corners[i], center, start_angle, end_angle, radius) {
      return true
    }
  }

  // 检查扇形边界与矩形边是否相交
  // 这里简化处理，实际实现可能需要更复杂的几何计算
  true
}

///|
/// 判断点是否在多边形内（射线法）
fn point_in_polygon(point : Point, polygon : Array[Point]) -> Bool {
  if polygon.length() < 3 {
    return false
  }

  // 首先检查点是否就是多边形顶点，如果是则返回false
  for i in 0..<polygon.length() {
    if point == polygon[i] {
      return false
    }
  }

  // 检查点是否在多边形的任何边上
  for i in 0..<polygon.length() {
    let p1 = polygon[i]
    let p2 = polygon[(i + 1) % polygon.length()]

    // 检查点是否在线段上
    if point_on_line_segment(point, p1, p2) {
      return true
    }
  }

  // 然后使用射线法检查点是否在多边形内部
  let mut inside = false
  let mut j = polygon.length() - 1
  for i in 0..<polygon.length() {
    let pi = polygon[i]
    let pj = polygon[j]
    if (pi.y > point.y) != (pj.y > point.y) &&
      point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x {
      inside = !inside
    }
    j = i
  }
  inside
}

///|
/// 判断点是否在线段上
fn point_on_line_segment(point : Point, p1 : Point, p2 : Point) -> Bool {
  // 允许的浮点数误差
  let epsilon : Float = 0.0001

  // 计算线段的长度的平方
  let line_length_squared = (p2.x - p1.x) * (p2.x - p1.x) +
    (p2.y - p1.y) * (p2.y - p1.y)

  // 如果线段长度为0，则检查点是否与端点重合
  if line_length_squared < epsilon {
    return distance(point, p1) < epsilon
  }

  // 计算点到线段的投影比例 t
  let t = ((point.x - p1.x) * (p2.x - p1.x) + (point.y - p1.y) * (p2.y - p1.y)) /
    line_length_squared

  // 如果 t 在 [0,1] 范围外，则点不在线段上
  if t < 0.0 || t > 1.0 {
    return false
  }

  // 计算投影点
  let proj_x = p1.x + t * (p2.x - p1.x)
  let proj_y = p1.y + t * (p2.y - p1.y)

  // 检查点到投影点的距离是否足够小
  let dist_squared = (point.x - proj_x) * (point.x - proj_x) +
    (point.y - proj_y) * (point.y - proj_y)
  dist_squared < epsilon
}

///|
/// 判断点是否在射线上
fn point_on_ray(
  point : Point,
  origin : Point,
  direction : Point,
  max_distance : Float,
) -> Bool {
  // 计算点到射线起点的距离
  let dist_to_origin = distance(point, origin)
  if dist_to_origin > max_distance {
    return false
  }

  // 如果点就是起点
  if dist_to_origin == 0.0 {
    return true
  }

  // 计算方向向量
  let dir_length = distance(origin, Point::{
    x: origin.x + direction.x,
    y: origin.y + direction.y,
  })
  if dir_length == 0.0 {
    return point == origin
  }
  let normalized_dir = Point::{
    x: direction.x / dir_length,
    y: direction.y / dir_length,
  }

  // 计算从原点到目标点的向量
  let to_point = Point::{ x: point.x - origin.x, y: point.y - origin.y }

  // 检查点是否在射线方向上（使用点积）
  let dot_product = to_point.x * normalized_dir.x +
    to_point.y * normalized_dir.y
  let projected_length = dot_product

  // 检查投影长度是否为正（在射线方向上）且不超过最大距离
  if projected_length < 0.0 || projected_length > max_distance {
    return false
  }

  // 计算投影点
  let projected_point = Point::{
    x: origin.x + projected_length * normalized_dir.x,
    y: origin.y + projected_length * normalized_dir.y,
  }

  // 检查实际点与投影点的距离是否在容差范围内
  let tolerance : Float = 0.001 // 容差
  distance(point, projected_point) <= tolerance
}

///|
/// 判断点是否在扇形内
fn point_in_sector(
  point : Point,
  center : Point,
  start_angle : Float,
  end_angle : Float,
  radius : Float,
) -> Bool {
  // 计算点到圆心的距离
  let dist = distance(point, center)
  if dist > radius {
    return false
  }

  // 计算点的角度
  let dx = point.x - center.x
  let dy = point.y - center.y
  // 转换为一致的Float类型
  let angle = @math.atan2(dy.to_double(), dx.to_double()).to_float()

  // 标准化角度到 [0, 2π] 范围
  let normalized_angle = if angle < 0.0 {
    angle + 2.0 * @math.PI.to_float()
  } else {
    angle
  }

  // 标准化起始和结束角度
  let normalized_start = if start_angle < 0.0 {
    start_angle + 2.0 * @math.PI.to_float()
  } else {
    start_angle
  }
  let normalized_end = if end_angle < 0.0 {
    end_angle + 2.0 * @math.PI.to_float()
  } else {
    end_angle
  }

  // 处理跨越0度的情况
  if normalized_start <= normalized_end {
    normalized_angle >= normalized_start && normalized_angle <= normalized_end
  } else {
    normalized_angle >= normalized_start || normalized_angle <= normalized_end
  }
}

///|
/// 检查线段与矩形是否相交
fn line_rect_intersect(p1 : Point, p2 : Point, rect : Rect) -> Bool {
  // 检查线段端点是否在矩形内
  if point_in_rect(p1, rect) || point_in_rect(p2, rect) {
    return true
  }

  // 检查线段是否与矩形的任何边相交
  let rect_edges = [
    (
      Point::{ x: rect.x, y: rect.y },
      Point::{ x: rect.x + rect.width, y: rect.y },
    ), // 上边
    (
      Point::{ x: rect.x + rect.width, y: rect.y },
      Point::{ x: rect.x + rect.width, y: rect.y + rect.height },
    ), // 右边
    (
      Point::{ x: rect.x + rect.width, y: rect.y + rect.height },
      Point::{ x: rect.x, y: rect.y + rect.height },
    ), // 下边
    (
      Point::{ x: rect.x, y: rect.y + rect.height },
      Point::{ x: rect.x, y: rect.y },
    ), // 左边
  ]
  for i in 0..<4 {
    let (edge_p1, edge_p2) = rect_edges[i]
    if line_line_intersect(p1, p2, edge_p1, edge_p2) {
      return true
    }
  }
  false
}

///|
/// 检查两条线段是否相交
fn line_line_intersect(p1 : Point, p2 : Point, p3 : Point, p4 : Point) -> Bool {
  let denom = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
  if denom == 0.0 {
    return false // 平行线
  }
  let t = ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) /
    denom
  let u = -((p1.x - p2.x) * (p1.y - p3.y) - (p1.y - p2.y) * (p1.x - p3.x)) /
    denom
  t >= 0.0 && t <= 1.0 && u >= 0.0 && u <= 1.0
}

///|
pub fn[T] update_incremental(
  node : QuadtreeNode[T],
  old_point : Point,
  new_point : Point,
  value : T,
  capacity : Int,
) -> QuadtreeNode[T] {
  // 先删除旧点
  let without_old = remove(node, old_point, capacity)

  // 再插入新点
  insert(without_old, new_point, value, capacity)
}

///|
/// 批量更新
pub fn[T] batch_update(
  node : QuadtreeNode[T],
  updates : Array[(Point, T)],
  capacity : Int,
) -> QuadtreeNode[T] {
  let mut result = node
  for i in 0..<updates.length() {
    let (point, value) = updates[i]
    result = insert(result, point, value, capacity)
  }
  result
}

///|
/// 移动点（保持引用）
pub fn[T : Eq] move_point(
  node : QuadtreeNode[T],
  old_point : Point,
  new_point : Point,
  capacity : Int,
) -> QuadtreeNode[T] {
  // 查找旧点的值
  let old_value = find(node, old_point)
  match old_value {
    Some(value) => {
      // 先删除旧点
      let without_old = remove(node, old_point, capacity)
      // 再插入新点
      insert(without_old, new_point, value, capacity)
    }
    None => node // 如果找不到旧点，返回原树
  }
}

///|
pub impl ToFloat for Float with to_float(self) {
  self
}

///|
pub impl ToFloat for Int with to_float(self) {
  self.to_float()
}

///|
pub impl ToFloat for Double with to_float(self) {
  self.to_float()
}
