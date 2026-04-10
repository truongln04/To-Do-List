# 📋 To-Do List App (Flutter)

Ứng dụng **To-Do List nâng cao** được phát triển bằng Flutter, giúp người dùng quản lý công việc hiệu quả với các tính năng như phân cấp công việc, deadline, nhắc việc và thống kê.

---

## 🚀 Tính năng chính

### ✅ Quản lý công việc

* Tạo, sửa, xóa công việc
* Đánh dấu hoàn thành / chưa hoàn thành
* Thiết lập mức độ ưu tiên (Thấp / Trung bình / Cao)

### 🗂️ Phân cấp công việc (2 cấp)

* Công việc chính (Task)
* Công việc con (Subtask)
* Tự động tính tiến độ (%) dựa trên subtask

### ⏰ Deadline & Nhắc việc

* Gán thời hạn cho công việc
* Cảnh báo công việc quá hạn
* Thiết lập nhắc việc cho task và subtask

### 📂 Phân loại công việc

* Tạo danh mục (Học tập, Công việc, Cá nhân...)
* Gắn công việc vào danh mục
* Hiển thị theo từng nhóm

### 🔍 Tìm kiếm & Lọc

* Tìm kiếm theo từ khóa
* Lọc theo:

  * Trạng thái
  * Deadline
  * Mức độ ưu tiên
  * Danh mục

### 📊 Thống kê & Báo cáo

* Tổng số công việc
* Số công việc đã hoàn thành / chưa hoàn thành
* Công việc quá hạn
* Tiến độ trung bình (%)

---

## 🏗️ Công nghệ sử dụng

* **Flutter** (UI framework)
* **Dart**
* **SQLite** (lưu trữ dữ liệu cục bộ)

---

## 📁 Cấu trúc thư mục

```
lib/
 ├── models/        # Data models (Task, Category, Subtask)
 ├── database/      # SQLite helper
 ├── screens/       # Giao diện màn hình
 ├── widgets/       # Components dùng lại
 └── main.dart
```

---

## ⚙️ Cài đặt & chạy project

### 1. Clone project

```bash
git clone https://github.com/truongln04/To-Do-List.git
```

### 2. Di chuyển vào thư mục

```bash
cd To-Do-List
```

### 3. Cài dependencies

```bash
flutter pub get
```

### 4. Chạy app

```bash
flutter run
```

---

## 📸 Demo (tuỳ chọn thêm ảnh)

> Bạn có thể thêm ảnh giao diện tại đây

---

## 🎯 Mục tiêu dự án

* Áp dụng kiến thức Flutter vào thực tế
* Xây dựng ứng dụng quản lý công việc hoàn chỉnh
* Rèn luyện kỹ năng thiết kế UI + xử lý logic + SQLite

---

## 👨‍💻 Tác giả

* **truongln04**

---

## 📄 License

Dự án phục vụ mục đích học tập.
