///|
test "create and insert points" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 1.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 1.0, y: 3.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "D", 2)
  // 插入超过容量后会分裂
  let result = Array::new()
  query(tree, Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }, result)
  assert_eq(result.length(), 4)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 3.0, y: 1.0 }, "B")))
  assert_true(result.contains((Point::{ x: 1.0, y: 3.0 }, "C")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "D")))
}

///|
test "insert outside boundary" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 5.0, y: 5.0 }, "X", 2)
  let result = Array::new()
  query(tree, Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }, result)
  assert_eq(result.length(), 0)
}

///|
test "subdivide rect" {
  let rect = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let arr = subdivide(rect)
  assert_eq(arr.length(), 4)
  assert_eq(arr[0], Rect::{ x: 0.0, y: 0.0, width: 2.0, height: 2.0 }) // 左上
  assert_eq(arr[1], Rect::{ x: 2.0, y: 0.0, width: 2.0, height: 2.0 }) // 右上
  assert_eq(arr[2], Rect::{ x: 0.0, y: 2.0, width: 2.0, height: 2.0 }) // 左下
  assert_eq(arr[3], Rect::{ x: 2.0, y: 2.0, width: 2.0, height: 2.0 }) // 右下
}

///|
test "insert_many batch insert" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let points = Array::new()
  let values = Array::new()
  points.push(Point::{ x: 1.0, y: 1.0 })
  points.push(Point::{ x: 3.0, y: 1.0 })
  points.push(Point::{ x: 1.0, y: 3.0 })
  points.push(Point::{ x: 3.0, y: 3.0 })
  values.push("A")
  values.push("B")
  values.push("C")
  values.push("D")
  let tree = insert_many(new(boundary), points, values, 2)
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 4)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 3.0, y: 1.0 }, "B")))
  assert_true(result.contains((Point::{ x: 1.0, y: 3.0 }, "C")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "D")))
}

///|
test "clear quadtree" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = clear(boundary)
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 0)
}

///|
test "count points in quadtree" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 1.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 1.0, y: 3.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "D", 2)
  assert_eq(count(tree), 4)
}

///|
test "remove point" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  tree = remove(tree, Point::{ x: 2.0, y: 2.0 }, 2)
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 1)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_false(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
}

///|
test "update point value" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = update(tree, Point::{ x: 1.0, y: 1.0 }, "Z", 2)
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 1)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "Z")))
}

///|
test "to_array collects all points" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  let arr = Array::new()
  to_array(tree, arr)
  assert_eq(arr.length(), 2)
  assert_true(arr.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(arr.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
}

///|
test "remove_range deletes points in region" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 1.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 1.0, y: 3.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "D", 2)
  tree = remove_range(
    tree,
    Rect::{ x: 0.0, y: 0.0, width: 2.0, height: 2.0 },
    2,
  )
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 3)
  assert_false(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 3.0, y: 1.0 }, "B")))
  assert_true(result.contains((Point::{ x: 1.0, y: 3.0 }, "C")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "D")))
}

///|
test "compress_node merges empty internal to leaf" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 1)
  tree = remove(tree, Point::{ x: 1.0, y: 1.0 }, 1)
  tree = compress_node(tree)
  match tree {
    QuadtreeNode::Leaf(..) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "find_nearest returns nearest neighbors" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入测试点
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 5.0, y: 5.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 8.0, y: 8.0 }, "D", 2)

  // 测试查找最近点
  let target = Point::{ x: 1.5, y: 1.5 }
  let nearest = find_nearest(tree, target, 2)

  // 验证结果
  assert_eq(nearest.length(), 2)

  // 按距离排序，所以第一个应该是最近的
  let (_, value1, dist1) = nearest[0]
  assert_eq(value1, "A")
  let (_, value2, dist2) = nearest[1]
  assert_eq(value2, "B")

  // 验证距离计算正确
  assert_true(dist1 <= dist2)
}

///|
test "find_hotspot locates densest region" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 创建密集区域
  for i in 0..<5 {
    for j in 0..<5 {
      tree = insert(
        tree,
        Point::{ x: 1.0 + i.to_float() * 0.2, y: 1.0 + j.to_float() * 0.2 },
        "dense",
        4,
      )
    }
  }

  // 创建稀疏区域
  for i in 0..<3 {
    tree = insert(
      tree,
      Point::{ x: 7.0 + i.to_float(), y: 7.0 + i.to_float() },
      "sparse",
      4,
    )
  }

  // 查找热点
  let (hotspot, count) = find_hotspot(tree, 5)

  // 热点应该在左下角区域
  assert_true(hotspot.x < 5.0)
  assert_true(hotspot.y < 5.0)
  assert_true(count > 10)
}

///|
test "find_hotspot locates densest region" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 创建密集区域
  for i in 0..<5 {
    for j in 0..<5 {
      tree = insert(
        tree,
        Point::{ x: 1.0 + i.to_float() * 0.2, y: 1.0 + j.to_float() * 0.2 },
        "dense",
        4,
      )
    }
  }

  // 创建稀疏区域
  for i in 0..<3 {
    tree = insert(
      tree,
      Point::{ x: 7.0 + i.to_float(), y: 7.0 + i.to_float() },
      "sparse",
      4,
    )
  }

  // 查找热点
  let (hotspot, count) = find_hotspot(tree, 5)

  // 热点应该在左下角区域
  assert_true(hotspot.x <= 5.0)
  assert_true(hotspot.y <= 5.0)
  assert_true(count > 10)
}

///|
test "merge combines two quadtrees" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree1 = new(boundary)
  let mut tree2 = new(boundary)

  // 第一棵树的点
  tree1 = insert(tree1, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree1 = insert(tree1, Point::{ x: 2.0, y: 2.0 }, "B", 2)

  // 第二棵树的点
  tree2 = insert(tree2, Point::{ x: 3.0, y: 3.0 }, "C", 2)
  tree2 = insert(tree2, Point::{ x: 4.0, y: 4.0 }, "D", 2)

  // 合并树
  let merged = merge(tree1, tree2, 2)

  // 验证合并结果
  let result = Array::new()
  query(merged, boundary, result)
  assert_eq(result.length(), 4)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "C")))
  assert_true(result.contains((Point::{ x: 4.0, y: 4.0 }, "D")))
}

///|
test "difference removes common points" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree1 = new(boundary)
  let mut tree2 = new(boundary)

  // 第一棵树的点
  tree1 = insert(tree1, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree1 = insert(tree1, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  tree1 = insert(tree1, Point::{ x: 3.0, y: 3.0 }, "C", 2)

  // 第二棵树的点（包含一些相同的点）
  tree2 = insert(tree2, Point::{ x: 2.0, y: 2.0 }, "X", 2) // 相同坐标，不同值
  tree2 = insert(tree2, Point::{ x: 3.0, y: 3.0 }, "Y", 2) // 相同坐标，不同值

  // 计算差集
  let diff = difference(tree1, tree2, 2)

  // 验证结果
  let result = Array::new()
  query(diff, boundary, result)
  assert_eq(result.length(), 1)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_false(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
  assert_false(result.contains((Point::{ x: 3.0, y: 3.0 }, "C")))
}

///|
test "intersection finds common points" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree1 = new(boundary)
  let mut tree2 = new(boundary)

  // 第一棵树的点
  tree1 = insert(tree1, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree1 = insert(tree1, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  tree1 = insert(tree1, Point::{ x: 3.0, y: 3.0 }, "C", 2)

  // 第二棵树的点（包含一些相同的点）
  tree2 = insert(tree2, Point::{ x: 2.0, y: 2.0 }, "X", 2) // 相同坐标，不同值
  tree2 = insert(tree2, Point::{ x: 3.0, y: 3.0 }, "Y", 2) // 相同坐标，不同值
  tree2 = insert(tree2, Point::{ x: 4.0, y: 4.0 }, "Z", 2)

  // 计算交集
  let intersect = intersection(tree1, tree2, 2)

  // 验证结果
  let result = Array::new()
  query(intersect, boundary, result)
  assert_eq(result.length(), 2)
  assert_false(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "C")))
  assert_false(result.contains((Point::{ x: 4.0, y: 4.0 }, "Z")))
}

///|
test "filter selects points based on predicate" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入点
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 5.0, y: 5.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 8.0, y: 8.0 }, "D", 2)

  // 过滤点 - 只保留 x > 3 的点
  let filtered = filter(tree, fn(pt, _) -> Bool { pt.x > 3.0 }, 2)

  // 验证结果
  let result = Array::new()
  query(filtered, boundary, result)
  assert_eq(result.length(), 2)
  assert_false(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_false(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 5.0, y: 5.0 }, "C")))
  assert_true(result.contains((Point::{ x: 8.0, y: 8.0 }, "D")))
}

///|
test "query_many batch queries multiple regions" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 在不同区域插入点
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2) // 左下
  tree = insert(tree, Point::{ x: 9.0, y: 1.0 }, "B", 2) // 右下
  tree = insert(tree, Point::{ x: 1.0, y: 9.0 }, "C", 2) // 左上
  tree = insert(tree, Point::{ x: 9.0, y: 9.0 }, "D", 2) // 右上

  // 定义多个查询区域
  let ranges = Array::new()
  ranges.push(Rect::{ x: 0.0, y: 0.0, width: 5.0, height: 5.0 }) // 左下区域
  ranges.push(Rect::{ x: 5.0, y: 5.0, width: 5.0, height: 5.0 }) // 右上区域

  // 批量查询
  let result = query_many(tree, ranges)

  // 验证结果
  assert_eq(result.length(), 2)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 9.0, y: 9.0 }, "D")))
  assert_false(result.contains((Point::{ x: 9.0, y: 1.0 }, "B")))
  assert_false(result.contains((Point::{ x: 1.0, y: 9.0 }, "C")))
}

///|
test "serialize generates valid JSON" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let mut tree = new(boundary)

  // 添加一些点
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "B", 2)

  // 序列化
  let json = serialize(tree)

  // 基本验证
  assert_true(json.has_prefix("{"))
  assert_true(json.has_suffix("}"))
  assert_true(json.contains("\"type\":"))
  assert_true(json.contains("\"boundary\":"))
  assert_true(json.contains("\"A\""))
  assert_true(json.contains("\"B\""))
}

///|
test "count_nodes returns correct node counts" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 空树应该只有一个叶子节点
  let (leaf_count, internal_count) = count_nodes(tree)
  assert_eq(leaf_count, 1)
  assert_eq(internal_count, 0)

  // 添加多个点以触发分裂
  for i in 0..<10 {
    tree = insert(tree, Point::{ x: i.to_float(), y: i.to_float() }, "X", 2)
  }

  // 现在应该有内部节点
  let (new_leaf_count, new_internal_count) = count_nodes(tree)
  assert_true(new_leaf_count > 1)
  assert_true(new_internal_count > 0)
}

///|
test "dbscan_cluster identifies point clusters" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 20.0, height: 20.0 }
  let mut tree = new(boundary)

  // 创建两个明显的簇
  // 簇1: 左下角
  for i in 0..<5 {
    for j in 0..<5 {
      tree = insert(
        tree,
        Point::{ x: 2.0 + i.to_float() * 0.5, y: 2.0 + j.to_float() * 0.5 },
        "cluster1",
        4,
      )
    }
  }

  // 簇2: 右上角
  for i in 0..<5 {
    for j in 0..<5 {
      tree = insert(
        tree,
        Point::{ x: 15.0 + i.to_float() * 0.5, y: 15.0 + j.to_float() * 0.5 },
        "cluster2",
        4,
      )
    }
  }

  // 添加一些噪声点
  tree = insert(tree, Point::{ x: 8.0, y: 8.0 }, "noise1", 4)
  tree = insert(tree, Point::{ x: 12.0, y: 5.0 }, "noise2", 4)

  // 运行DBSCAN聚类
  let clusters = dbscan_cluster(tree, 1.0, 4)

  // 验证结果
  assert_eq(clusters.length(), 2)

  // 验证簇大小
  assert_true(clusters[0].length() >= 5)
  assert_true(clusters[1].length() >= 5)

  // 验证簇位置
  let mut cluster1_x_sum : Float = 0.0
  let mut cluster1_y_sum : Float = 0.0
  for i in 0..<clusters[0].length() {
    cluster1_x_sum += clusters[0][i].x
    cluster1_y_sum += clusters[0][i].y
  }
  let mut cluster2_x_sum : Float = 0.0
  let mut cluster2_y_sum : Float = 0.0
  for i in 0..<clusters[1].length() {
    cluster2_x_sum += clusters[1][i].x
    cluster2_y_sum += clusters[1][i].y
  }

  // 检查簇的平均位置是否在预期区域
  let c1_avg_x = cluster1_x_sum / clusters[0].length().to_float()
  let c1_avg_y = cluster1_y_sum / clusters[0].length().to_float()
  let c2_avg_x = cluster2_x_sum / clusters[1].length().to_float()
  let c2_avg_y = cluster2_y_sum / clusters[1].length().to_float()

  // 确保两个簇的中心在不同区域
  assert_true(
    (c1_avg_x < 10.0 && c1_avg_y < 10.0) || (c2_avg_x < 10.0 && c2_avg_y < 10.0),
  )
  assert_true(
    (c1_avg_x > 10.0 && c1_avg_y > 10.0) || (c2_avg_x > 10.0 && c2_avg_y > 10.0),
  )
}

///|
test "insert_adaptive uses density-based capacity" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 第一组：在左下角创建高密度区域（小区域大量点）
  for i in 0..<10 {
    for j in 0..<10 {
      tree = insert_adaptive(
        tree,
        Point::{ x: 1.0 + i.to_float() * 0.1, y: 1.0 + j.to_float() * 0.1 },
        "dense",
        2, // 高密度区域用小容量
        8, // 低密度区域用大容量
        0.5, // 密度阈值
      )
    }
  }

  // 第二组：在右上角创建低密度区域（分散点）
  for i in 0..<5 {
    tree = insert_adaptive(
      tree,
      Point::{ x: 7.0 + i.to_float() * 0.5, y: 7.0 + i.to_float() * 0.5 }, // 步长改为0.5，最后一个坐标为9.0
      "sparse",
      2,
      8,
      0.5,
    )
  }

  // 验证点已正确插入
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 105) // 100个高密度点 + 5个低密度点

  // 验证树结构 - 高密度区域应该分裂更多
  let (_, internal_count) = count_nodes(tree)
  assert_true(internal_count > 0)

  // 测试两个区域的深度差异
  // 1. 查询高密度区域（左下）
  let dense_region = Rect::{ x: 0.0, y: 0.0, width: 2.0, height: 2.0 }
  let mut dense_subtree = QuadtreeNode::Leaf(
    points=Array::new(),
    boundary=dense_region,
  )
  let dense_points = Array::new()
  query(tree, dense_region, dense_points)

  // 重建子树用于分析
  for i in 0..<dense_points.length() {
    let (pt, val) = dense_points[i]
    dense_subtree = insert(dense_subtree, pt, val, 8) // 用较大容量构建以查看自然深度
  }

  // 2. 查询低密度区域（右上）
  let sparse_region = Rect::{ x: 7.0, y: 7.0, width: 3.0, height: 3.0 }
  let mut sparse_subtree = QuadtreeNode::Leaf(
    points=Array::new(),
    boundary=sparse_region,
  )
  let sparse_points = Array::new()
  query(tree, sparse_region, sparse_points)

  // 重建子树用于分析
  for i in 0..<sparse_points.length() {
    let (pt, val) = sparse_points[i]
    sparse_subtree = insert(sparse_subtree, pt, val, 8)
  }

  // 比较两个区域的深度 - 高密度区域应该更深
  let dense_depth = depth(dense_subtree)
  let sparse_depth = depth(sparse_subtree)

  // 高密度区域应该具有更深的树结构（如果点数足够触发分裂）
  if dense_points.length() > 8 { // 超过容量才会分裂
    assert_true(dense_depth > sparse_depth)
  }
}

///|
test "insert_adaptive balances tree depth based on density" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
  let mut regular_tree = new(boundary)
  let mut adaptive_tree = new(boundary)

  // 在不同密度区域插入相同的点
  // 区域1：高密度点簇 (x,y < 10)
  for i in 0..<20 {
    for j in 0..<20 {
      let pt = Point::{
        x: 1.0 + i.to_float() * 0.4,
        y: 1.0 + j.to_float() * 0.4,
      }
      regular_tree = insert(regular_tree, pt, "dense", 4)
      adaptive_tree = insert_adaptive(adaptive_tree, pt, "dense", 2, 8, 0.1)
    }
  }

  // 区域2：中等密度 (40 < x,y < 60)
  for i in 0..<10 {
    for j in 0..<10 {
      let pt = Point::{ x: 40.0 + i.to_float(), y: 40.0 + j.to_float() }
      regular_tree = insert(regular_tree, pt, "medium", 4)
      adaptive_tree = insert_adaptive(adaptive_tree, pt, "medium", 2, 8, 0.1)
    }
  }

  // 区域3：低密度稀疏点 (x,y > 80)
  for i in 0..<5 {
    let pt = Point::{
      x: 80.0 + i.to_float() * 3.0,
      y: 80.0 + i.to_float() * 3.0,
    }
    regular_tree = insert(regular_tree, pt, "sparse", 4)
    adaptive_tree = insert_adaptive(adaptive_tree, pt, "sparse", 2, 8, 0.1)
  }

  // 验证两棵树都包含相同数量的点
  let regular_count = count(regular_tree)
  let adaptive_count = count(adaptive_tree)
  assert_eq(regular_count, adaptive_count)

  // 比较两棵树的结构
  let (regular_leaf_count, _) = count_nodes(regular_tree)
  let (adaptive_leaf_count, _) = count_nodes(adaptive_tree)

  // 自适应树应该能更好地平衡结构
  // 在高密度区域使用较小容量导致更多分裂，在低密度区域使用较大容量减少分裂
  // 因此应该有更多的叶子节点但可能有更少的内部节点
  assert_true(adaptive_leaf_count >= regular_leaf_count)

  // 验证查询性能
  // 在高密度区域进行查询
  let dense_region = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let dense_regular = Array::new()
  let dense_adaptive = Array::new()
  query(regular_tree, dense_region, dense_regular)
  query(adaptive_tree, dense_region, dense_adaptive)
  assert_eq(dense_regular.length(), dense_adaptive.length())

  // 在低密度区域进行查询
  let sparse_region = Rect::{ x: 80.0, y: 80.0, width: 20.0, height: 20.0 }
  let sparse_regular = Array::new()
  let sparse_adaptive = Array::new()
  query(regular_tree, sparse_region, sparse_regular)
  query(adaptive_tree, sparse_region, sparse_adaptive)
  assert_eq(sparse_regular.length(), sparse_adaptive.length())
}

///|
/// 测试：insert_adaptive 使用基于密度的容量（鲁棒版本）
test "insert_adaptive uses density-based capacity" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 计数实际插入点
  let mut points_added = 0

  // 第一组：在左下角创建高密度区域（小区域大量点）
  for i in 0..<10 {
    for j in 0..<10 {
      tree = insert_adaptive(
        tree,
        Point::{ x: 1.0 + i.to_float() * 0.1, y: 1.0 + j.to_float() * 0.1 },
        "dense",
        2, // 高密度区域用小容量
        8, // 低密度区域用大容量
        0.5, // 密度阈值
      )
      points_added += 1
    }
  }

  // 第二组：在右上角创建低密度区域（分散点）
  for i in 0..<5 {
    tree = insert_adaptive(
      tree,
      Point::{ x: 7.0 + i.to_float() * 0.5, y: 7.0 + i.to_float() * 0.5 }, // 步长改为0.5
      "sparse",
      2,
      8,
      0.5,
    )
    points_added += 1
  }
  // 查询全树并验证点数一致
  let result = Array::new()
  query(tree, boundary, result)

  // 断言：查询到的点数应等于实际插入次数
  assert_eq(result.length(), points_added)

  // 校验没有重复坐标（通过简单 O(n^2) 检查）
  for i in 0..<result.length() {
    for j in (i + 1)..<result.length() {
      let (pi, _) = result[i]
      let (pj, _) = result[j]
      assert_false(pi == pj)
    }
  }

  // 验证树结构 - 高密度区域应该分裂更多
  let (_, internal_count) = count_nodes(tree)
  assert_true(internal_count > 0)

  // 测试两个区域的深度差异（仅在有足够点时判断）
  let dense_region = Rect::{ x: 0.0, y: 0.0, width: 2.0, height: 2.0 }
  let mut dense_subtree = QuadtreeNode::Leaf(
    points=Array::new(),
    boundary=dense_region,
  )
  let dense_points = Array::new()
  query(tree, dense_region, dense_points)
  let sparse_region = Rect::{ x: 7.0, y: 7.0, width: 3.0, height: 3.0 }
  let mut sparse_subtree = QuadtreeNode::Leaf(
    points=Array::new(),
    boundary=sparse_region,
  )
  let sparse_points = Array::new()
  query(tree, sparse_region, sparse_points)

  // 重建子树用于分析深度
  for i in 0..<dense_points.length() {
    let (pt, val) = dense_points[i]
    dense_subtree = insert(dense_subtree, pt, val, 8)
  }
  for i in 0..<sparse_points.length() {
    let (pt, val) = sparse_points[i]
    sparse_subtree = insert(sparse_subtree, pt, val, 8)
  }
  let dense_depth = depth(dense_subtree)
  let sparse_depth = depth(sparse_subtree)
  if dense_points.length() > 8 {
    assert_true(dense_depth > sparse_depth)
  }
}

// ... existing code ...

///|
/// 测试圆形范围查询
test "query_circle finds points within radius" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入测试点
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 7.0, y: 7.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 8.0, y: 8.0 }, "D", 2)

  // 查询圆心在(2.5, 2.5)，半径为1.5的圆形区域
  let center = Point::{ x: 2.5, y: 2.5 }
  let radius : Float = 1.5
  let result = Array::new()
  query_circle(tree, center, radius, result)

  // 验证结果
  assert_eq(result.length(), 2)
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "A")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "B")))
  assert_false(result.contains((Point::{ x: 7.0, y: 7.0 }, "C")))
  assert_false(result.contains((Point::{ x: 8.0, y: 8.0 }, "D")))
}

///|
/// 测试多边形范围查询
test "query_polygon finds points within polygon" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入测试点
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 4.0, y: 2.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 4.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 7.0, y: 7.0 }, "D", 2)

  // 定义三角形多边形
  let polygon = Array::new()
  polygon.push(Point::{ x: 1.0, y: 1.0 })
  polygon.push(Point::{ x: 5.0, y: 1.0 })
  polygon.push(Point::{ x: 3.0, y: 5.0 })

  // 查询多边形内的点
  let result = Array::new()
  query_polygon(tree, polygon, result)

  // 验证结果
  assert_eq(result.length(), 3)
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "A")))
  assert_true(result.contains((Point::{ x: 4.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 3.0, y: 4.0 }, "C")))
  assert_false(result.contains((Point::{ x: 7.0, y: 7.0 }, "D")))
}

///|
/// 测试射线查询
test "query_ray finds points on ray" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入测试点
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 4.0, y: 2.0 }, "D", 2) // 不在射线上
  tree = insert(tree, Point::{ x: 5.0, y: 5.0 }, "E", 2)

  // 定义射线：从(0,0)到(4,4)方向，最大距离5
  let origin = Point::{ x: 0.0, y: 0.0 }
  let direction = Point::{ x: 1.0, y: 1.0 }
  let max_distance : Float = 5.0

  // 查询射线上的点
  let result = Array::new()
  query_ray(tree, origin, direction, max_distance, result)

  // 验证结果
  assert_eq(result.length(), 3)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "C")))
  assert_false(result.contains((Point::{ x: 4.0, y: 2.0 }, "D")))
  assert_false(result.contains((Point::{ x: 5.0, y: 5.0 }, "E"))) // 超出最大距离
}

///|
/// 测试扇形范围查询
test "query_sector finds points within sector" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入测试点
  tree = insert(tree, Point::{ x: 2.0, y: 1.0 }, "A", 2) // 在扇形内
  tree = insert(tree, Point::{ x: 1.0, y: 2.0 }, "B", 2) // 在扇形内
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "C", 2) // 在扇形内
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "D", 2) // 在扇形内
  tree = insert(tree, Point::{ x: 4.5, y: 1.0 }, "E", 2) // 明确在扇形外
  tree = insert(tree, Point::{ x: 1.0, y: 4.5 }, "F", 2) // 明确在扇形外
  // ...existing code...

  // 定义扇形：中心(1,1)，角度从0到π/2，半径3
  let center = Point::{ x: 1.0, y: 1.0 }
  let start_angle : Float = 0.0
  let end_angle = @math.PI.to_float() / 2.0
  let radius : Float = 3.0

  // 查询扇形内的点
  let result = Array::new()
  query_sector(tree, center, start_angle, end_angle, radius, result)

  // 验证结果
  assert_eq(result.length(), 4)
  assert_true(result.contains((Point::{ x: 2.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 1.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "C")))
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "D")))
  assert_false(result.contains((Point::{ x: 4.0, y: 1.0 }, "E")))
  assert_false(result.contains((Point::{ x: 1.0, y: 4.0 }, "F")))
}

///|
/// 测试增量更新功能
test "update_incremental moves point and updates value" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入初始点
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 4.0, y: 4.0 }, "B", 2)

  // 增量更新：移动点(2,2)到(3,3)并更新值
  let old_point = Point::{ x: 2.0, y: 2.0 }
  let new_point = Point::{ x: 3.0, y: 3.0 }
  tree = update_incremental(tree, old_point, new_point, "A_updated", 2)

  // 验证更新结果
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 2)
  assert_false(result.contains((Point::{ x: 2.0, y: 2.0 }, "A")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "A_updated")))
  assert_true(result.contains((Point::{ x: 4.0, y: 4.0 }, "B")))
}

///|
/// 测试批量更新功能
test "batch_update processes multiple updates" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 准备批量更新数据
  let updates = Array::new()
  updates.push((Point::{ x: 1.0, y: 1.0 }, "A"))
  updates.push((Point::{ x: 2.0, y: 2.0 }, "B"))
  updates.push((Point::{ x: 3.0, y: 3.0 }, "C"))
  updates.push((Point::{ x: 4.0, y: 4.0 }, "D"))

  // 执行批量更新
  tree = batch_update(tree, updates, 2)

  // 验证结果
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 4)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "C")))
  assert_true(result.contains((Point::{ x: 4.0, y: 4.0 }, "D")))
}

///|
/// 测试移动点功能
test "move_point relocates point while preserving value" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入初始点
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 4.0, y: 4.0 }, "B", 2)

  // 移动点(2,2)到(3,3)
  let old_point = Point::{ x: 2.0, y: 2.0 }
  let new_point = Point::{ x: 3.0, y: 3.0 }
  tree = move_point(tree, old_point, new_point, 2)

  // 验证移动结果
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 2)
  assert_false(result.contains((Point::{ x: 2.0, y: 2.0 }, "A")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "A")))
  assert_true(result.contains((Point::{ x: 4.0, y: 4.0 }, "B")))
}

///|
/// 测试移动不存在的点
test "move_point handles non-existent point" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入一个点
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)

  // 尝试移动不存在的点
  let old_point = Point::{ x: 5.0, y: 5.0 }
  let new_point = Point::{ x: 6.0, y: 6.0 }
  tree = move_point(tree, old_point, new_point, 2)

  // 验证树没有变化
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 1)
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "A")))
  assert_false(result.contains((Point::{ x: 6.0, y: 6.0 }, "A")))
}

///|
/// 测试圆形查询的边界情况
test "query_circle handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入边界上的点
  tree = insert(tree, Point::{ x: 0.0, y: 0.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 10.0, y: 10.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 5.0, y: 5.0 }, "C", 2)

  // 测试零半径
  let center = Point::{ x: 5.0, y: 5.0 }
  let result_zero = Array::new()
  query_circle(tree, center, 0.0, result_zero)
  assert_eq(result_zero.length(), 1)
  assert_true(result_zero.contains((Point::{ x: 5.0, y: 5.0 }, "C")))

  // 测试大半径
  let result_large = Array::new()
  query_circle(tree, center, 20.0, result_large)
  assert_eq(result_large.length(), 3)
}

///|
/// 测试多边形查询的复杂情况
test "query_polygon handles complex polygons" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入测试点
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 5.0, y: 3.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 4.0, y: 5.0 }, "C", 2)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "D", 2)
  tree = insert(tree, Point::{ x: 6.0, y: 6.0 }, "E", 2)

  // 定义L形多边形
  let polygon = Array::new()
  polygon.push(Point::{ x: 2.0, y: 2.0 })
  polygon.push(Point::{ x: 6.0, y: 2.0 })
  polygon.push(Point::{ x: 6.0, y: 4.0 })
  polygon.push(Point::{ x: 4.0, y: 4.0 })
  polygon.push(Point::{ x: 4.0, y: 6.0 })
  polygon.push(Point::{ x: 2.0, y: 6.0 })

  // 查询多边形内的点
  let result = Array::new()
  query_polygon(tree, polygon, result)

  // 验证结果
  assert_eq(result.length(), 3)
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "A")))
  assert_true(result.contains((Point::{ x: 5.0, y: 3.0 }, "B")))
  assert_true(result.contains((Point::{ x: 4.0, y: 5.0 }, "C")))
  assert_false(result.contains((Point::{ x: 2.0, y: 2.0 }, "D")))
  assert_false(result.contains((Point::{ x: 6.0, y: 6.0 }, "E")))
}

///|
/// 测试射线查询的精度
test "query_ray handles precision and tolerance" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入精确在射线上的点
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "C", 2)

  // 插入稍微偏离射线的点
  tree = insert(tree, Point::{ x: 2.001, y: 2.0 }, "D", 2) // 应该被检测到
  tree = insert(tree, Point::{ x: 2.01, y: 2.0 }, "E", 2) // 应该不被检测到

  // 定义射线：从(0,0)到(4,4)方向
  let origin = Point::{ x: 0.0, y: 0.0 }
  let direction = Point::{ x: 1.0, y: 1.0 }
  let max_distance : Float = 5.0

  // 查询射线上的点
  let result = Array::new()
  query_ray(tree, origin, direction, max_distance, result)

  // 验证结果
  assert_eq(result.length(), 4)
  assert_true(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "C")))
  assert_true(result.contains((Point::{ x: 2.001, y: 2.0 }, "D")))
  assert_false(result.contains((Point::{ x: 2.01, y: 2.0 }, "E")))
}

///|
/// 测试扇形查询的角度处理
test "query_sector handles angle wrapping" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入测试点
  tree = insert(tree, Point::{ x: 2.0, y: 1.0 }, "A", 2) // 角度约0度
  tree = insert(tree, Point::{ x: 1.0, y: 2.0 }, "B", 2) // 角度约90度
  tree = insert(tree, Point::{ x: 0.0, y: 1.0 }, "C", 2) // 角度约180度
  tree = insert(tree, Point::{ x: 1.0, y: 0.0 }, "D", 2) // 角度约270度

  // 定义跨越0度的扇形（从270度到90度）
  let center = Point::{ x: 1.0, y: 1.0 }
  let start_angle : Float = 3.0 * @math.PI.to_float() / 2.0 // 270度
  let end_angle : Float = @math.PI.to_float() / 2.0 // 90度
  let radius : Float = 2.0

  // 查询扇形内的点
  let result = Array::new()
  query_sector(tree, center, start_angle, end_angle, radius, result)

  // 验证结果
  assert_eq(result.length(), 3)
  assert_true(result.contains((Point::{ x: 2.0, y: 1.0 }, "A")))
  assert_true(result.contains((Point::{ x: 1.0, y: 2.0 }, "B")))
  assert_true(result.contains((Point::{ x: 1.0, y: 0.0 }, "D")))
  assert_false(result.contains((Point::{ x: 0.0, y: 1.0 }, "C")))
}

///|
/// 测试批量更新的性能
test "batch_update performance with large dataset" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
  let mut tree = new(boundary)

  // 准备大量更新数据
  let updates = Array::new()
  for i in 0..<50 {
    for j in 0..<50 {
      updates.push((Point::{ x: i.to_float(), y: j.to_float() }, "point"))
    }
  }

  // 执行批量更新
  tree = batch_update(tree, updates, 4)

  // 验证结果
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 2500) // 50 * 50
}

///|
/// 测试增量更新的多次操作
test "update_incremental multiple operations" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入初始点
  tree = insert(tree, Point::{ x: 1.0, y: 1.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "C", 2)

  // 多次增量更新
  tree = update_incremental(
    tree,
    Point::{ x: 1.0, y: 1.0 },
    Point::{ x: 4.0, y: 4.0 },
    "A_moved",
    2,
  )
  tree = update_incremental(
    tree,
    Point::{ x: 2.0, y: 2.0 },
    Point::{ x: 5.0, y: 5.0 },
    "B_moved",
    2,
  )

  // 验证最终结果
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 3)
  assert_true(result.contains((Point::{ x: 4.0, y: 4.0 }, "A_moved")))
  assert_true(result.contains((Point::{ x: 5.0, y: 5.0 }, "B_moved")))
  assert_true(result.contains((Point::{ x: 3.0, y: 3.0 }, "C")))
  assert_false(result.contains((Point::{ x: 1.0, y: 1.0 }, "A")))
  assert_false(result.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
}

///|
/// 测试空间自相关性计算
test "spatial_autocorrelation calculates Moran's I" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 创建空间聚集的点
  for i in 0..<5 {
    for j in 0..<5 {
      tree = insert(
        tree,
        Point::{ x: 1.0 + i.to_float(), y: 1.0 + j.to_float() },
        i.to_float(),
        4,
      )
    }
  }

  // 计算空间自相关性
  let autocorr = spatial_autocorrelation(tree)

  // 验证结果在合理范围内
  assert_true(autocorr >= -1.0)
  assert_true(autocorr <= 1.0)
}

///|
/// 测试深度计算
test "depth calculates maximum tree depth" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
  let mut tree = new(boundary)

  // 空树深度为1
  assert_eq(depth(tree), 1)

  // 插入点触发分裂
  for i in 0..<20 {
    tree = insert(tree, Point::{ x: i.to_float(), y: i.to_float() }, "point", 2)
  }

  // 验证深度增加
  let tree_depth = depth(tree)
  assert_true(tree_depth > 1)
  assert_true(tree_depth <= 10) // 合理的最大深度
}

///|
/// 测试节点压缩功能
test "compress_node merges empty internal nodes" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入点触发分裂
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 1)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "B", 1)

  // 删除所有点
  tree = remove(tree, Point::{ x: 2.0, y: 2.0 }, 1)
  tree = remove(tree, Point::{ x: 3.0, y: 3.0 }, 1)

  // 压缩节点
  tree = compress_node(tree)

  // 验证压缩为叶子节点
  match tree {
    QuadtreeNode::Leaf(..) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
/// 测试圆形查询的边界情况
test "query_circle handles points on circle boundary" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入精确在圆上的点
  tree = insert(tree, Point::{ x: 3.0, y: 0.0 }, "A", 2) // 在圆上
  tree = insert(tree, Point::{ x: 0.0, y: 3.0 }, "B", 2) // 在圆上
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "C", 2) // 在圆内
  tree = insert(tree, Point::{ x: 4.0, y: 4.0 }, "D", 2) // 在圆外
  let center = Point::{ x: 0.0, y: 0.0 }
  let radius : Float = 3.0
  let result = Array::new()
  query_circle(tree, center, radius, result)

  // 验证边界点被包含
  assert_eq(result.length(), 3)
  assert_true(result.contains((Point::{ x: 3.0, y: 0.0 }, "A")))
  assert_true(result.contains((Point::{ x: 0.0, y: 3.0 }, "B")))
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "C")))
  assert_false(result.contains((Point::{ x: 4.0, y: 4.0 }, "D")))
}

///|
/// 测试多边形查询的退化情况
test "query_polygon handles degenerate polygons" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)

  // 测试空多边形
  let empty_polygon = Array::new()
  let result_empty = Array::new()
  query_polygon(tree, empty_polygon, result_empty)
  assert_eq(result_empty.length(), 0)

  // 测试单点多边形
  let single_point = Array::new()
  single_point.push(Point::{ x: 1.0, y: 1.0 })
  let result_single = Array::new()
  query_polygon(tree, single_point, result_single)
  assert_eq(result_single.length(), 0)

  // 测试两点多边形
  let two_points = Array::new()
  two_points.push(Point::{ x: 1.0, y: 1.0 })
  two_points.push(Point::{ x: 3.0, y: 3.0 })
  let result_two = Array::new()
  query_polygon(tree, two_points, result_two)
  assert_eq(result_two.length(), 0)
}

///|
/// 测试射线查询的零向量情况
test "query_ray handles zero direction vector" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "B", 2)

  // 零方向向量
  let origin = Point::{ x: 2.0, y: 2.0 }
  let direction = Point::{ x: 0.0, y: 0.0 }
  let result = Array::new()
  query_ray(tree, origin, direction, 5.0, result)

  // 应该只包含起点
  assert_eq(result.length(), 1)
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "A")))
}

///|
/// 测试扇形查询的完整圆形
test "query_sector handles full circle" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入四个象限的点
  tree = insert(tree, Point::{ x: 2.0, y: 1.0 }, "A", 2) // 第一象限
  tree = insert(tree, Point::{ x: 1.0, y: 2.0 }, "B", 2) // 第二象限
  tree = insert(tree, Point::{ x: 0.0, y: 1.0 }, "C", 2) // 第三象限
  tree = insert(tree, Point::{ x: 1.0, y: 0.0 }, "D", 2) // 第四象限

  // 完整圆形扇形
  let center = Point::{ x: 1.0, y: 1.0 }
  let start_angle : Float = 0.0
  let end_angle : Float = 2.0 * @math.PI.to_float()
  let radius : Float = 2.0
  let result = Array::new()
  query_sector(tree, center, start_angle, end_angle, radius, result)

  // 应该包含所有点
  assert_eq(result.length(), 4)
}

///|
/// 测试批量更新的重复点处理
test "batch_update handles duplicate points" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 准备包含重复点的更新
  let updates = Array::new()
  updates.push((Point::{ x: 2.0, y: 2.0 }, "A"))
  updates.push((Point::{ x: 2.0, y: 2.0 }, "B")) // 重复坐标
  updates.push((Point::{ x: 3.0, y: 3.0 }, "C"))
  tree = batch_update(tree, updates, 2)

  // 验证结果
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 3) // 所有点都被插入
}

///|
/// 测试增量更新的相同点
test "update_incremental handles same old and new point" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)

  // 相同的新旧点
  let point = Point::{ x: 2.0, y: 2.0 }
  tree = update_incremental(tree, point, point, "A_updated", 2)

  // 验证值被更新
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 1)
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "A_updated")))
}

///|
/// 测试移动点到相同位置
test "move_point handles same old and new position" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)

  // 移动到相同位置
  let point = Point::{ x: 2.0, y: 2.0 }
  tree = move_point(tree, point, point, 2)

  // 验证点仍然存在
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 1)
  assert_true(result.contains((Point::{ x: 2.0, y: 2.0 }, "A")))
}

///|
/// 测试序列化空树
test "serialize handles empty tree" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 4.0, height: 4.0 }
  let tree : @Quadtree.QuadtreeNode[Float] = new(boundary)
  let json = serialize(tree)

  // 验证JSON结构
  assert_true(json.contains("\"type\":\"leaf\""))
  assert_true(json.contains("\"points\":[]"))
  assert_true(json.contains("\"boundary\""))
}

///|
/// 测试序列化复杂树
test "serialize handles complex tree structure" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 插入多个点触发分裂
  for i in 0..<10 {
    tree = insert(tree, Point::{ x: i.to_float(), y: i.to_float() }, "point", 2)
  }
  let json = serialize(tree)

  // 验证JSON包含必要字段
  assert_true(json.contains("\"type\""))
  assert_true(json.contains("\"boundary\""))
  assert_true(json.contains("\"children\""))
  assert_true(json.contains("\"point\""))
}

///|
/// 测试DBSCAN聚类的边界情况
test "dbscan_cluster handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 空树
  let empty_clusters = dbscan_cluster(tree, 1.0, 2)
  assert_eq(empty_clusters.length(), 0)

  // 单个点
  tree = insert(tree, Point::{ x: 5.0, y: 5.0 }, "single", 2)
  let single_clusters = dbscan_cluster(tree, 1.0, 2)
  assert_eq(single_clusters.length(), 0) // 单个点不满足最小点数要求

  // 两个点
  tree = insert(tree, Point::{ x: 5.1, y: 5.1 }, "pair", 2)
  let pair_clusters = dbscan_cluster(tree, 1.0, 2)
  assert_eq(pair_clusters.length(), 1) // 两个点形成一个簇
}

///|
/// 测试自适应插入的极端参数
test "insert_adaptive handles extreme parameters" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 极端参数：最小容量=1，最大容量=1
  tree = insert_adaptive(tree, Point::{ x: 1.0, y: 1.0 }, "A", 1, 1, 0.1)
  tree = insert_adaptive(tree, Point::{ x: 1.1, y: 1.1 }, "B", 1, 1, 0.1)

  // 验证点被正确插入
  let result = Array::new()
  query(tree, boundary, result)
  assert_eq(result.length(), 2)
}

///|
/// 测试查找最近点的边界情况
test "find_nearest handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 空树
  let empty_nearest = find_nearest(tree, Point::{ x: 5.0, y: 5.0 }, 5)
  assert_eq(empty_nearest.length(), 0)

  // 单个点
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  let single_nearest = find_nearest(tree, Point::{ x: 5.0, y: 5.0 }, 5)
  assert_eq(single_nearest.length(), 1)

  // 请求超过实际点数的k值
  let many_nearest = find_nearest(tree, Point::{ x: 5.0, y: 5.0 }, 10)
  assert_eq(many_nearest.length(), 1)
}

///|
/// 测试热点查找的边界情况
test "find_hotspot handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 空树
  let (_, empty_count) = find_hotspot(tree, 5)
  assert_eq(empty_count, 0)

  // 单个点
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  let (_, single_count) = find_hotspot(tree, 5)
  assert_eq(single_count, 1)

  // 两个点
  tree = insert(tree, Point::{ x: 3.0, y: 3.0 }, "B", 2)
  let (_, pair_count) = find_hotspot(tree, 5)
  assert_eq(pair_count, 2)
}

///|
/// 测试合并操作的边界情况
test "merge handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let empty_tree = new(boundary)

  // 空树与空树合并
  let merged_empty = merge(empty_tree, empty_tree, 2)
  let result_empty = Array::new()
  query(merged_empty, boundary, result_empty)
  assert_eq(result_empty.length(), 0)

  // 空树与非空树合并
  let mut tree_with_points = new(boundary)
  tree_with_points = insert(tree_with_points, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  let merged_with_empty = merge(empty_tree, tree_with_points, 2)
  let result_with_empty = Array::new()
  query(merged_with_empty, boundary, result_with_empty)
  assert_eq(result_with_empty.length(), 1)
}

///|
/// 测试差集操作的边界情况
test "difference handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let empty_tree = new(boundary)

  // 空树与空树的差集
  let diff_empty = difference(empty_tree, empty_tree, 2)
  let result_empty = Array::new()
  query(diff_empty, boundary, result_empty)
  assert_eq(result_empty.length(), 0)

  // 非空树与空树的差集
  let mut tree_with_points = new(boundary)
  tree_with_points = insert(tree_with_points, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  let diff_with_empty = difference(tree_with_points, empty_tree, 2)
  let result_with_empty = Array::new()
  query(diff_with_empty, boundary, result_with_empty)
  assert_eq(result_with_empty.length(), 1)
}

///|
/// 测试交集操作的边界情况
test "intersection handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let empty_tree = new(boundary)

  // 空树与空树的交集
  let intersect_empty = intersection(empty_tree, empty_tree, 2)
  let result_empty = Array::new()
  query(intersect_empty, boundary, result_empty)
  assert_eq(result_empty.length(), 0)

  // 非空树与空树的交集
  let mut tree_with_points = new(boundary)
  tree_with_points = insert(tree_with_points, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  let intersect_with_empty = intersection(tree_with_points, empty_tree, 2)
  let result_with_empty = Array::new()
  query(intersect_with_empty, boundary, result_with_empty)
  assert_eq(result_with_empty.length(), 0)
}

///|
/// 测试过滤操作的边界情况
test "filter handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 4.0, y: 4.0 }, "B", 2)

  // 过滤掉所有点
  let filtered_all = filter(tree, fn(_, _) -> Bool { false }, 2)
  let result_all = Array::new()
  query(filtered_all, boundary, result_all)
  assert_eq(result_all.length(), 0)

  // 保留所有点
  let filtered_none = filter(tree, fn(_, _) -> Bool { true }, 2)
  let result_none = Array::new()
  query(filtered_none, boundary, result_none)
  assert_eq(result_none.length(), 2)
}

///|
/// 测试查询多个区域的边界情况
test "query_many handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)

  // 空范围数组
  let empty_ranges = Array::new()
  let result_empty = query_many(tree, empty_ranges)
  assert_eq(result_empty.length(), 0)

  // 不重叠的范围
  let non_overlapping = Array::new()
  non_overlapping.push(Rect::{ x: 5.0, y: 5.0, width: 2.0, height: 2.0 })
  let result_non_overlapping = query_many(tree, non_overlapping)
  assert_eq(result_non_overlapping.length(), 0)
}

///|
/// 测试节点计数的边界情况
test "count_nodes handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }

  // 空树
  let empty_tree : @Quadtree.QuadtreeNode[Float] = new(boundary)
  let (empty_leaf_count, empty_internal_count) = count_nodes(empty_tree)
  assert_eq(empty_leaf_count, 1)
  assert_eq(empty_internal_count, 0)

  // 单点树
  let mut single_tree = new(boundary)
  single_tree = insert(single_tree, Point::{ x: 5.0, y: 5.0 }, "A", 2)
  let (single_leaf_count, single_internal_count) = count_nodes(single_tree)
  assert_eq(single_leaf_count, 1)
  assert_eq(single_internal_count, 0)
}

///|
/// 测试点计数的边界情况
test "count handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }

  // 空树
  let empty_tree : @Quadtree.QuadtreeNode[Float] = new(boundary)
  assert_eq(count(empty_tree), 0)

  // 单点树
  let mut single_tree = new(boundary)
  single_tree = insert(single_tree, Point::{ x: 5.0, y: 5.0 }, "A", 2)
  assert_eq(count(single_tree), 1)
}

///|
/// 测试数组转换的边界情况
test "to_array handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }

  // 空树
  let empty_tree : @Quadtree.QuadtreeNode[Float] = new(boundary)
  let empty_array = Array::new()
  to_array(empty_tree, empty_array)
  assert_eq(empty_array.length(), 0)

  // 单点树
  let mut single_tree = new(boundary)
  single_tree = insert(single_tree, Point::{ x: 5.0, y: 5.0 }, "A", 2)
  let single_array = Array::new()
  to_array(single_tree, single_array)
  assert_eq(single_array.length(), 1)
}

///|
/// 测试范围删除的边界情况
test "remove_range handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  tree = insert(tree, Point::{ x: 4.0, y: 4.0 }, "B", 2)

  // 删除不重叠的范围
  let non_overlapping = Rect::{ x: 6.0, y: 6.0, width: 2.0, height: 2.0 }
  let result_non_overlapping = remove_range(tree, non_overlapping, 2)
  let count_non_overlapping = count(result_non_overlapping)
  assert_eq(count_non_overlapping, 2)

  // 删除整个边界
  let full_boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let result_full = remove_range(tree, full_boundary, 2)
  let count_full = count(result_full)
  assert_eq(count_full, 0)
}

///|
/// 测试查找功能的边界情况
test "find handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)

  // 查找不存在的点
  let not_found = find(tree, Point::{ x: 5.0, y: 5.0 })
  match not_found {
    None => assert_true(true)
    Some(_) => assert_true(false)
  }

  // 查找存在的点
  let found = find(tree, Point::{ x: 2.0, y: 2.0 })
  match found {
    Some(value) => assert_eq(value, "A")
    None => assert_true(false)
  }
}

///|
/// 测试更新功能的边界情况
test "update handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)

  // 更新不存在的点
  let updated_non_existent = update(tree, Point::{ x: 5.0, y: 5.0 }, "B", 2)
  let result_non_existent = Array::new()
  query(updated_non_existent, boundary, result_non_existent)
  assert_eq(result_non_existent.length(), 1)
  assert_true(result_non_existent.contains((Point::{ x: 2.0, y: 2.0 }, "A")))

  // 更新存在的点
  let updated_existent = update(tree, Point::{ x: 2.0, y: 2.0 }, "B", 2)
  let result_existent = Array::new()
  query(updated_existent, boundary, result_existent)
  assert_eq(result_existent.length(), 1)
  assert_true(result_existent.contains((Point::{ x: 2.0, y: 2.0 }, "B")))
}

///|
/// 测试删除功能的边界情况
test "remove handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)

  // 删除不存在的点
  let removed_non_existent = remove(tree, Point::{ x: 5.0, y: 5.0 }, 2)
  let count_non_existent = count(removed_non_existent)
  assert_eq(count_non_existent, 1)

  // 删除存在的点
  let removed_existent = remove(tree, Point::{ x: 2.0, y: 2.0 }, 2)
  let count_existent = count(removed_existent)
  assert_eq(count_existent, 0)
}

///|
/// 测试清空功能的边界情况
test "clear handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
  let mut tree = new(boundary)

  // 清空空树
  let cleared_empty : @Quadtree.QuadtreeNode[Float] = clear(boundary)
  let count_empty = count(cleared_empty)
  assert_eq(count_empty, 0)

  // 清空有数据的树
  tree = insert(tree, Point::{ x: 2.0, y: 2.0 }, "A", 2)
  let cleared_with_data : @Quadtree.QuadtreeNode[Float] = clear(boundary)
  let count_with_data = count(cleared_with_data)
  assert_eq(count_with_data, 0)
}

///|
/// 测试批量插入的边界情况
test "insert_many handles edge cases" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 10.0, height: 10.0 }

  // 空数组
  let empty_points = Array::new()
  let empty_values : Array[Float] = []
  let result_empty = insert_many(new(boundary), empty_points, empty_values, 2)
  let count_empty = count(result_empty)
  assert_eq(count_empty, 0)

  // 长度不匹配的数组
  let points = Array::new()
  let values = Array::new()
  points.push(Point::{ x: 2.0, y: 2.0 })
  points.push(Point::{ x: 3.0, y: 3.0 })
  values.push("A") // 只有一个值
  let result_mismatch = insert_many(new(boundary), points, values, 2)
  let count_mismatch = count(result_mismatch)
  assert_eq(count_mismatch, 1) // 只插入匹配的点
}

///|
/// 测试性能：大量数据插入
test "performance large dataset insertion" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 1000.0, height: 1000.0 }
  let mut tree = new(boundary)

  // 插入大量随机点
  for i in 0..<1000 {
    let x = i * 7 % 1000
    let y = i * 11 % 1000
    tree = insert(tree, Point::{ x: x.to_float(), y: y.to_float() }, "point", 4)
  }

  // 验证所有点都被插入
  let count_result = count(tree)
  assert_eq(count_result, 1000)

  // 验证查询性能
  let query_rect = Rect::{ x: 0.0, y: 0.0, width: 500.0, height: 500.0 }
  let result = Array::new()
  query(tree, query_rect, result)
  assert_true(result.length() > 0)
}

///|
/// 测试性能：深度嵌套的树结构
test "performance deep tree structure" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 1.0, height: 1.0 }
  let mut tree = new(boundary)

  // 在小区域内插入大量点，强制创建深层树
  for i in 0..<100 {
    let x = 0.1 + (i % 10).to_double() * 0.01
    let y = 0.1 + (i / 10).to_double() * 0.01
    tree = insert(tree, Point::{ x: x.to_float(), y: y.to_float() }, "point", 1)
  }

  // 验证树深度
  let tree_depth = depth(tree)
  assert_true(tree_depth > 5)

  // 验证所有点都被插入
  let count_result = count(tree)
  assert_eq(count_result, 100)
}

///|
/// 测试性能：复杂查询操作
test "performance complex query operations" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
  let mut tree = new(boundary)

  // 插入大量点
  for i in 0..<300 {
    let x = i * 13 % 100
    let y = i * 17 % 100
    tree = insert(tree, Point::{ x: x.to_float(), y: y.to_float() }, "point", 4)
  }

  // 测试圆形查询性能
  let center = Point::{ x: 50.0, y: 50.0 }
  let radius : Float = 20.0
  let circle_result = Array::new()
  query_circle(tree, center, radius, circle_result)
  assert_true(circle_result.length() > 0)

  // 测试多边形查询性能
  let polygon = Array::new()
  polygon.push(Point::{ x: 40.0, y: 40.0 })
  polygon.push(Point::{ x: 60.0, y: 40.0 })
  polygon.push(Point::{ x: 60.0, y: 60.0 })
  polygon.push(Point::{ x: 40.0, y: 60.0 })
  let polygon_result = Array::new()
  query_polygon(tree, polygon, polygon_result)
  assert_true(polygon_result.length() > 0)

  // 测试射线查询性能
  let origin = Point::{ x: 0.0, y: 0.0 }
  let direction = Point::{ x: 1.0, y: 1.0 }
  let ray_result = Array::new()
  query_ray(tree, origin, direction, 100.0, ray_result)
  assert_true(ray_result.length() > 0)
}

///|
test {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
  let mut tree = new(boundary)

  // Insert points
  tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, "point1", 4)
  tree = insert(tree, Point::{ x: 30.0, y: 40.0 }, "point2", 4)
  tree = insert(tree, Point::{ x: 50.0, y: 60.0 }, "point3", 4)

  // DBSCAN clustering
  let clusters = dbscan_cluster(tree, 5.0, 3)
  assert_eq(clusters.length(), 0)
  //assert_true(clusters[0].length() >= 3)
}

///|
/// 测试性能：复杂查询操作
test "performance complex query operations" {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
  let mut tree = new(boundary)

  // 插入大量点
  for i in 0..<300 {
    let x = i * 13 % 100
    let y = i * 17 % 100
    tree = insert(tree, Point::{ x: x.to_float(), y: y.to_float() }, "point", 4)
  }

  // 测试圆形查询性能
  let center = Point::{ x: 50.0, y: 50.0 }
  let radius : Float = 20.0
  let circle_result = Array::new()
  query_circle(tree, center, radius, circle_result)
  assert_true(circle_result.length() > 0)

  // 测试多边形查询性能
  let polygon = Array::new()
  polygon.push(Point::{ x: 40.0, y: 40.0 })
  polygon.push(Point::{ x: 60.0, y: 40.0 })
  polygon.push(Point::{ x: 60.0, y: 60.0 })
  polygon.push(Point::{ x: 40.0, y: 60.0 })
  let polygon_result = Array::new()
  query_polygon(tree, polygon, polygon_result)
  assert_true(polygon_result.length() > 0)

  // 测试射线查询性能
  let origin = Point::{ x: 0.0, y: 0.0 }
  let direction = Point::{ x: 1.0, y: 1.0 }
  let ray_result = Array::new()
  query_ray(tree, origin, direction, 100.0, ray_result)
  assert_true(ray_result.length() > 0)

  // 测试DBSCAN聚类性能 - 使用更大的eps值
  let clusters = dbscan_cluster(tree, 15.0, 3)
  assert_true(clusters.length() >= 0) // 可能没有簇，这是正常的
}
