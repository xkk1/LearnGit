# 常用 Git 命令

## 在本地初始化 Git 仓库

- 打开终端或命令行工具。
- 导航到你的项目目录：
    
    ```sh
    cd path/to/your/project
    ```
- 初始化一个新的 Git 仓库：
    
    ```sh
    git init
    ```
    
- 添加项目文件到 Git(将所有文件添加到 Git 仓库)
    
    ```sh
    git add .
    ```

- 提交文件到仓库：
    
    ```sh
    git commit -m "Initial commit"
    ```

## git status

git status 命令显示工作目录和暂存区域的状态。  它可以让您查看哪些更改已暂存，哪些尚未暂存，以及哪些文件未被 Git 跟踪。  状态输出不会向您显示有关已提交项目历史记录的任何信息。

## 添加 GitHub 远程仓库

新建仓库

```
echo "# test" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/xkk1/test.git
git push -u origin main
```

用已有的 Git 仓库

```
git remote add origin https://github.com/xkk1/test.git
git branch -M main
git push -u origin main
```
