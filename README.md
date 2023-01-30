除非另外约定或另有授权，使用本仓库下的资源（包括但不限于代码，图形资源）构建的软件，必须在明显位置（如主界面页脚，关于页面）标明该软件基于本仓库的资源开发，并标注上游链接


Software built using resources (including but not limited to code and graphics resources) under this repository unless otherwise agreed or authorized, the software development based on the resources of the repository must be clearly identified (e. g. , main page footer, about page) and linked upstream

# Dock

YoyoOS application dock.

## Dependencies

```shell
sudo pacman -S gcc cmake qt5-base qt5-quickcontrols2 kwindowsystem
```

You also need [`fishui`](https://github.com/yoyoos/fishui) and [`libyoyo`](https://github.com/yoyoos/libyoyo).

## Build and Install

```
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make
sudo make install
```

## License

This project has been licensed by GPLv3.
