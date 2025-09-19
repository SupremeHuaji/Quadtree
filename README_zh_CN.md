# 四叉树 (Quadtree)

[English](https://github.com/moonbit-community/Quadtree/blob/main/README.md) | [简体中文](https://github.com/moonbit-community/Quadtree/blob/main/README_zh_CN.md)

一个高性能的空间数据结构实现，基于 MoonBit 提供高效的点存储和复杂几何查询功能，适用于 2D 空间数据。

---

## 🚀 主要功能

- 🌳 **四叉树创建** – 使用自定义边界和容量设置创建四叉树。  
- ➕ **点管理** – 插入、更新、删除和查找带有关联值的点。  
- 🔍 **高级查询** – 支持矩形、圆形、多边形、射线和扇形查询。  
- 📊 **空间分析** – 最近邻、密度热点和空间自相关分析。  
- 🔄 **树操作** – 合并、交集、差集和点过滤操作。  
- 🧹 **内存管理** – 自动节点压缩和内存优化。  
- 📈 **性能优化** – 使用迭代算法防止大数据集导致栈溢出。  
- 🎯 **聚类分析** – 使用 DBSCAN 算法进行点云聚类分析。  
- 🔧 **自适应插入** – 基于密度的容量调整以优化树结构。  
- 💾 **序列化** – 支持 JSON 序列化以实现数据持久化。

---

## 📥 安装

```bash
moon add moonbit-community/Quadtree
```

---

## 🚀 使用指南

### 🔨 创建

你可以通过指定边界矩形来创建一个四叉树。

```moonbit
fn example_create_quadtree() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let tree = new(boundary)
}
```

---

### ➕ 插入 & 🔍 查询

插入带有关联值的点，并高效地查询它们。

```moonbit
fn example_insert_and_query() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // 插入点
    tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, "point1", 4)
    tree = insert(tree, Point::{ x: 30.0, y: 40.0 }, "point2", 4)

    // 矩形查询
    let result = Array::new()
    query(tree, Rect::{ x: 0.0, y: 0.0, width: 50.0, height: 50.0 }, result)
    assert_eq(result.length(), 2)
}
```

---

### 🔍 高级几何查询

执行复杂的几何查询，性能优越。

```moonbit
fn example_advanced_queries() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // 插入点
    tree = insert(tree, Point::{ x: 15.0, y: 25.0 }, "point1", 4)
    tree = insert(tree, Point::{ x: 50.0, y: 50.0 }, "point2", 4)

    // 圆形查询
    let center = Point::{ x: 15.0, y: 25.0 }
    let radius : Float = 10.0
    let circle_result = Array::new()
    query_circle(tree, center, radius, circle_result)

    // 多边形查询
    let polygon = Array::new()
    polygon.push(Point::{ x: 0.0, y: 0.0 })
    polygon.push(Point::{ x: 50.0, y: 0.0 })
    polygon.push(Point::{ x: 25.0, y: 50.0 })
    let polygon_result = Array::new()
    query_polygon(tree, polygon, polygon_result)

    // 射线查询
    let origin = Point::{ x: 0.0, y: 0.0 }
    let direction = Point::{ x: 1.0, y: 1.0 }
    let ray_result = Array::new()
    query_ray(tree, origin, direction, 100.0, ray_result)

    // 扇形查询
    let sector_center = Point::{ x: 0.0, y: 0.0 }
    let start_angle : Float = 0.0
    let end_angle = @math.PI.to_float() / 2.0
    let sector_radius : Float = 50.0
    let sector_result = Array::new()
    query_sector(tree, sector_center, start_angle, end_angle, sector_radius, sector_result)
}
```

---

### 📊 空间分析

执行高级空间分析操作。

```moonbit
fn example_spatial_analysis() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // 插入测试点
    tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, 5.0, 4)
    tree = insert(tree, Point::{ x: 15.0, y: 25.0 }, 7.0, 4)
    tree = insert(tree, Point::{ x: 20.0, y: 30.0 }, 6.0, 4)
    tree = insert(tree, Point::{ x: 80.0, y: 80.0 }, 8.0, 4)
    tree = insert(tree, Point::{ x: 85.0, y: 85.0 }, 9.0, 4)

    // 最近邻查询
    let target = Point::{ x: 12.0, y: 22.0 }
    let nearest = find_nearest(tree, target, 3)
    assert_eq(nearest.length(), 3)

    // 查找密度热点
    let (hotspot_rect, count) = find_hotspot(tree, 10)
    assert_true(count > 0)

    // 空间自相关（Moran's I）
    let autocorr = spatial_autocorrelation(tree)
    assert_true(autocorr >= -1.0 && autocorr <= 1.0)
}
```

---

### 🔄 树操作

对四叉树执行集合操作。

```moonbit
fn example_tree_operations() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let tree1 = new(boundary)
    let tree2 = new(boundary)

    // 合并两棵树
    let merged = merge(tree1, tree2, 4)

    // 求交集
    let intersect = intersection(tree1, tree2, 4)

    // 求差集
    let diff = difference(tree1, tree2, 4)

    // 筛选点
    let filtered = filter(tree1, fn(pt, val) -> Bool { pt.x > 10.0 }, 4)
}
```

---

### 🎯 聚类

使用 DBSCAN 算法进行点云聚类。

```moonbit
fn example_clustering() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // 插入点
    tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, "point1", 4)
    tree = insert(tree, Point::{ x: 30.0, y: 40.0 }, "point2", 4)
    tree = insert(tree, Point::{ x: 50.0, y: 60.0 }, "point3", 4)

    // DBSCAN 聚类
    let clusters = dbscan_cluster(tree, 5.0, 3)
    assert_eq(clusters.length(), 0)
}
```

---

### 💾 序列化

将四叉树序列化为 JSON 格式以实现数据持久化。

```moonbit
fn example_serialization() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // 插入点
    tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, "point1", 4)

    // 序列化为 JSON
    let json = serialize(tree)
    assert_true(json.contains("\"type\""))
    assert_true(json.contains("\"boundary\""))
}
```

---

### 🧹 内存管理

自动内存优化和清理。

```moonbit
fn example_memory_management() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // 删除点
    tree = remove(tree, Point::{ x: 10.0, y: 20.0 }, 4)

    // 删除范围
    tree = remove_range(tree, Rect::{ x: 0.0, y: 0.0, width: 25.0, height: 25.0 }, 4)

    // 压缩空节点
    tree = compress_node(tree)

    // 清空所有点
    tree = clear(boundary)
}
```

---

## 📜 许可证

本项目基于 Apache-2.0 许可证开源。详情请参阅 LICENSE。