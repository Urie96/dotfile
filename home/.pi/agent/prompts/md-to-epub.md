# Markdown项目转EPUB转换指南

## 常见项目结构

### 结构A：按章节分目录
```
project/
├── ch01_章节名/
│   ├── 第一章_章节名.md
│   └── img/
│       └── ch1/
│           ├── image1.jpg
│           └── image2.png
├── ch02_章节名/
└── ...
```

### 结构B：GitBook风格（SUMMARY.md）
```
project/
├── SUMMARY.md
├── book.json
├── README.md
├── chapter1/
│   ├── README.md
│   └── image/
│       └── logo.png
└── foreword/
    └── thanks.md
```

**关键点：**
- 结构A：章节文件名通常为 `chXX_章节名/第X章_章节名.md`
- 结构B：按SUMMARY.md顺序合并，图片在各章节的 `image/` 子目录
- 支持格式：JPG、JPEG、PNG、GIF、WEBP、**SVG**

## 转换步骤

### 1. 准备元数据（metadata.yaml）
```yaml
---
title: "书籍标题"
author: "作者"
language: zh-CN
description: "书籍描述"
identifier: "https://github.com/username/project"
source: "https://github.com/username/project"
publisher: "https://github.com/username/project"
rights: "https://github.com/username/project"
---
```

### 2. 合并章节文件
```bash
cat \
"./chapter1/file1.md" \
"./chapter2/file2.md" \
"./chapter3/file3.md" \
> /tmp/merged.md
```

### 3. 收集图片
```bash
rm -rf /tmp/flat_images
mkdir -p /tmp/flat_images

find . -type f \
  \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.svg" \) \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -exec cp {} /tmp/flat_images/ \;
```

### 4. 修复图片路径
```python
import re, os

with open('/tmp/merged.md', 'r', encoding='utf-8') as f:
    content = f.read()

def replace_img_path(match):
    full_match = match.group(0)
    alt_text = match.group(1)
    old_path = match.group(2)
    filename = os.path.basename(old_path)
    return f'![{alt_text}](images/{filename})'

new_content = re.sub(r'!\[([^\]]*)\]\(([^)]+\.(jpg|jpeg|png|gif|webp|svg))\)',
                     replace_img_path, content, flags=re.IGNORECASE)

with open('/tmp/merged_with_images.md', 'w', encoding='utf-8') as f:
    f.write(new_content)
```

### 5. 生成EPUB
```bash
pandoc /tmp/metadata.yaml /tmp/merged_with_images.md \
  -o /tmp/book.epub \
  --toc \
  --toc-depth=3 \
  --split-level=2 \
  --metadata title="书籍标题" \
  --resource-path=:./images \
  --epub-cover-image=./cover.jpg \
  --mathml
```

**参数说明：**
- `--toc`: 生成目录
- `--toc-depth=3`: 目录深度3级
- `--split-level=2`: 按二级标题分章节
- `--resource-path`: 图片资源路径
- `--epub-cover-image`: 封面图片
- `--mathml`: LaTeX转MathML

### 6. 验证
```bash
ls -lh /tmp/book.epub
unzip -l /tmp/book.epub | grep -iE "\.(jpg|png|jpeg|svg)$" | wc -l
unzip -p /tmp/book.epub EPUB/content.opf | head -40
```

## 完整脚本模板

```bash
#!/bin/bash

set -e

PROJECT_DIR="/path/to/project"
BOOK_TITLE="书籍标题"
AUTHOR="作者"
GITHUB_URL="https://github.com/user/project"
COVER_IMAGE="cover.jpg"
TEMP_DIR="/tmp/${BOOK_TITLE}"

rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 1. 元数据
cat > "$TEMP_DIR/metadata.yaml" << EOF
---
title: "$BOOK_TITLE"
author: "$AUTHOR"
language: zh-CN
description: "书籍描述"
identifier: "$GITHUB_URL"
source: "$GITHUB_URL"
publisher: "$GITHUB_URL"
rights: "$GITHUB_URL"
---
EOF

# 2. 合并章节
cat \
"$PROJECT_DIR/file1.md" \
"$PROJECT_DIR/file2.md" \
> "$TEMP_DIR/${BOOK_TITLE}_merged.md"

# 3. 收集图片
mkdir -p "$TEMP_DIR/images"
find "$PROJECT_DIR" -type f \
  \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.svg" \) \
  -not -path "*/.git/*" \
  -not -path "*/$TEMP_DIR/*" \
  -exec cp {} "$TEMP_DIR/images/" \;

# 4. 修复图片路径
python3 << PYTHON_SCRIPT
import re, os

with open('$TEMP_DIR/${BOOK_TITLE}_merged.md', 'r', encoding='utf-8') as f:
    content = f.read()

def replace_img_path(match):
    full_match = match.group(0)
    alt_text = match.group(1)
    old_path = match.group(2)
    filename = os.path.basename(old_path)
    return f'![{alt_text}](images/{filename})'

new_content = re.sub(r'!\[([^\]]*)\]\(([^)]+\.(jpg|jpeg|png|gif|webp|svg))\)',
                     replace_img_path, content, flags=re.IGNORECASE)

with open('$TEMP_DIR/${BOOK_TITLE}_with_images.md', 'w', encoding='utf-8') as f:
    f.write(new_content)
PYTHON_SCRIPT

# 5. 复制图片
rm -rf "$PROJECT_DIR/images"
cp -r "$TEMP_DIR/images" "$PROJECT_DIR/"

# 6. 生成EPUB
cd "$PROJECT_DIR"
pandoc "$TEMP_DIR/metadata.yaml" "$TEMP_DIR/${BOOK_TITLE}_with_images.md" \
  -o "$TEMP_DIR/${BOOK_TITLE}.epub" \
  --toc --toc-depth=3 --split-level=2 \
  --metadata title="$BOOK_TITLE" \
  --resource-path=:./images \
  --epub-cover-image="./$COVER_IMAGE" \
  --mathml

# 7. 复制到项目目录
cp "$TEMP_DIR/${BOOK_TITLE}.epub" "$PROJECT_DIR/"
echo "完成: $PROJECT_DIR/${BOOK_TITLE}.epub"
```

## 常见问题

### 图片不显示
- 检查图片路径是否统一为 `images/文件名`
- 确认所有图片已复制到项目 `images/` 目录
- SVG需使用现代阅读器支持

### LaTeX公式不渲染
- 使用 `--mathml` 参数
- 确保阅读器支持MathML
- 检查公式语法，避免中文在公式块内

### 章节顺序错乱
- 检查合并时文件顺序
- 特殊章节需手动处理（如子文件插入）

### SVG不显示
- 考虑转换为PNG：`rsvg-convert -f png input.svg -o output.png`
- 使用支持SVG的阅读器（iBooks、Calibre）

## 检查清单
- [ ] 所有章节已包含
- [ ] 章节顺序正确
- [ ] 图片全部显示（含SVG）
- [ ] 数学公式渲染正常
- [ ] 封面图片已添加
- [ ] GitHub地址在元数据中

## 工具
```bash
pandoc --version
```

## 接下来你的任务

将当前项目转换为EPUB。
$@
