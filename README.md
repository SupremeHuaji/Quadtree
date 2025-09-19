# Quadtree

[English](https://github.com/moonbit-community/Quadtree/blob/main/README.md) | [简体中文](https://github.com/moonbit-community/Quadtree/blob/main/README_zh_CN.md)


A high-performance spatial data structure implementation in MoonBit, providing efficient point storage and complex geometric queries for 2D spatial data.

---

## 🚀 Key Features

- 🌳 **Quadtree Creation** – Create quadtrees with custom boundaries and capacity settings.  
- ➕ **Point Management** – Insert, update, remove, and find points with associated values.  
- 🔍 **Advanced Queries** – Support for rectangular, circular, polygonal, ray, and sector queries.  
- 📊 **Spatial Analysis** – K-nearest neighbors, density hotspots, and spatial autocorrelation.  
- 🔄 **Tree Operations** – Merge, intersection, difference, and filtering operations.  
- 🧹 **Memory Management** – Automatic node compression and memory optimization.  
- 📈 **Performance** – Iterative algorithms to prevent stack overflow with large datasets.  
- 🎯 **Clustering** – DBSCAN clustering algorithm for point cloud analysis.  
- 🔧 **Adaptive Insertion** – Density-based capacity adjustment for optimal tree structure.  
- 💾 **Serialization** – JSON serialization support for data persistence.

---

## 📥 Installation

```bash
moon add moonbit-community/Quadtree
```

---

## 🚀 Usage Guide

### 🔨 Create

You can create a quadtree with a specified boundary rectangle.

```moonbit
fn example_create_quadtree() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let tree = new(boundary)
}
```

---

### ➕ Insert & 🔍 Query

Insert points with associated values and query them efficiently.

```moonbit
fn example_insert_and_query() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // Insert points
    tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, "point1", 4)
    tree = insert(tree, Point::{ x: 30.0, y: 40.0 }, "point2", 4)

    // Rectangular query
    let result = Array::new()
    query(tree, Rect::{ x: 0.0, y: 0.0, width: 50.0, height: 50.0 }, result)
    assert_eq(result.length(), 2)
}
```

---

### 🔍 Advanced Geometric Queries

Perform complex geometric queries with high performance.

```moonbit
fn example_advanced_queries() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // Insert points
    tree = insert(tree, Point::{ x: 15.0, y: 25.0 }, "point1", 4)
    tree = insert(tree, Point::{ x: 50.0, y: 50.0 }, "point2", 4)

    // Circular query
    let center = Point::{ x: 15.0, y: 25.0 }
    let radius : Float = 10.0
    let circle_result = Array::new()
    query_circle(tree, center, radius, circle_result)

    // Polygonal query
    let polygon = Array::new()
    polygon.push(Point::{ x: 0.0, y: 0.0 })
    polygon.push(Point::{ x: 50.0, y: 0.0 })
    polygon.push(Point::{ x: 25.0, y: 50.0 })
    let polygon_result = Array::new()
    query_polygon(tree, polygon, polygon_result)

    // Ray query
    let origin = Point::{ x: 0.0, y: 0.0 }
    let direction = Point::{ x: 1.0, y: 1.0 }
    let ray_result = Array::new()
    query_ray(tree, origin, direction, 100.0, ray_result)

    // Sector query
    let sector_center = Point::{ x: 0.0, y: 0.0 }
    let start_angle : Float = 0.0
    let end_angle = @math.PI.to_float() / 2.0
    let sector_radius : Float = 50.0
    let sector_result = Array::new()
    query_sector(tree, sector_center, start_angle, end_angle, sector_radius, sector_result)
}
```

---

### 📊 Spatial Analysis

Perform advanced spatial analysis operations.

```moonbit
    fn example_spatial_analysis() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // Insert test points
    tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, 5.0, 4)
    tree = insert(tree, Point::{ x: 15.0, y: 25.0 }, 7.0, 4)
    tree = insert(tree, Point::{ x: 20.0, y: 30.0 }, 6.0, 4)
    tree = insert(tree, Point::{ x: 80.0, y: 80.0 }, 8.0, 4)
    tree = insert(tree, Point::{ x: 85.0, y: 85.0 }, 9.0, 4)

    // K-nearest neighbors
    let target = Point::{ x: 12.0, y: 22.0 }
    let nearest = find_nearest(tree, target, 3)
    assert_eq(nearest.length(), 3)
    // nearest contains the 3 closest points to target

    // Find density hotspot
    let (hotspot_rect, count) = find_hotspot(tree, 10)
    assert_true(count > 0)
    // hotspot_rect contains the area with highest point density

    // Spatial autocorrelation (Moran's I)
    let autocorr = spatial_autocorrelation(tree)
    assert_true(autocorr >= -1.0 && autocorr <= 1.0)
    // autocorr indicates spatial clustering: >0 = clustered, <0 = dispersed

    // Get tree statistics
    let point_count = count(tree)
    let tree_depth = depth(tree)
    let (leaf_count, internal_count) = count_nodes(tree)

    assert_eq(point_count, 5)
    assert_true(tree_depth > 0)
    assert_eq(leaf_count, 1)
    assert_eq(internal_count, 0)
}
```

---

### 🔄 Tree Operations

Perform set-like operations on quadtrees.

```moonbit
fn example_tree_operations() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let tree1 = new(boundary)
    let tree2 = new(boundary)

    // Merge two trees
    let merged = merge(tree1, tree2, 4)

    // Find intersection
    let intersect = intersection(tree1, tree2, 4)

    // Find difference
    let diff = difference(tree1, tree2, 4)

    // Filter points
    let filtered = filter(tree1, fn(pt, val) -> Bool { pt.x > 10.0 }, 4)
}
```

---

### 🎯 Clustering

Use DBSCAN algorithm for point cloud clustering.

```moonbit
fn example_clustering() {
  let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
  let mut tree = new(boundary)

  // Insert points
  tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, "point1", 4)
  tree = insert(tree, Point::{ x: 30.0, y: 40.0 }, "point2", 4)
  tree = insert(tree, Point::{ x: 50.0, y: 60.0 }, "point3", 4)

  // DBSCAN clustering
  let clusters = dbscan_cluster(tree, 5.0, 3)
  // Note: With these points, clusters.length() will be 0 because 
  // the points are too far apart (distance > 5.0)
  assert_eq(clusters.length(), 0)
}
```

---

### 💾 Serialization

Serialize and deserialize quadtrees for data persistence.

```moonbit
fn example_serialization() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // Insert points
    tree = insert(tree, Point::{ x: 10.0, y: 20.0 }, "point1", 4)

    // Serialize to JSON
    let json = serialize(tree)
    assert_true(json.contains("\"type\""))
    assert_true(json.contains("\"boundary\""))
}
```

---

### 🧹 Memory Management

Automatic memory optimization and cleanup.

```moonbit
fn example_memory_management() {
    let boundary = Rect::{ x: 0.0, y: 0.0, width: 100.0, height: 100.0 }
    let mut tree = new(boundary)

    // Remove points
    tree = remove(tree, Point::{ x: 10.0, y: 20.0 }, 4)

    // Remove range
    tree = remove_range(tree, Rect::{ x: 0.0, y: 0.0, width: 25.0, height: 25.0 }, 4)

    // Compress empty nodes
    tree = compress_node(tree)

    // Clear all points
    tree = clear(boundary)
}
```



## 📜 License

This project is licensed under the Apache-2.0 License. See LICENSE for details.
