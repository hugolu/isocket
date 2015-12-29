# isocket

## 簡介
使用 inotifywait + luasocket + luaevent 完成異地備份的工具

想法
- 為每個待同步的目錄配置一個inotifywait監控目錄變化 (是否產生新檔案)

角色
- parser - 檔案產生者
- scaner - 所有目錄的管理程式
- watcher - 單一目錄的監控程式
- sender - 負責同步檔案的程式
- ```finished.parse``` - parser 所產生，表示目錄容量已滿，不再產生檔案
- ```finished.watch``` - watcher 所產生，表示目錄檔案已傳，不需要再檢查

流程
- scaner 掃描 /datas 裡面所有目錄，檢查目錄裡面的特殊檔案
  -如果有 watcher 產生的 finished.watch 檔案
  - 不管有/無 parser 產生的 finished.parse 檔案，都不再檢查同步[註4]
- 如果無 watcher 產生的 finished.watch 檔案
  - 如果有 parser 產生的 finished.parse 檔案
    - 目錄不再產生檔案，但未完成檔案同步
    - 掃描所有檔案，產生未傳輸的檔案清單[註1]交給 sender 傳送檔案[註2]
  - 如果無 watcher 產生的 finished.watch 檔案
    - 如果這不是最新的目錄
      - 目錄不再產生檔案，但未完成檔案同步
      - 掃描所有檔案，產生未傳輸的檔案清單[註1]交給 sender 傳送檔案[註2]
    - 如果這是最新的目錄
      - 目錄會持續產生檔案，需要進行檔案同步
      - 啟動 watcher 監控目錄，產生待傳輸的檔案清單[註3]交給 sender 傳送檔案
      - watcher啟動後，掃描所有檔案，產生watcher啟動前未傳輸的檔案清單[註1]交給 sender 傳送檔案[註2]

- 註1：使用檔案權限 group write mode 判斷是否已傳輸
- 註2：sender 傳送檔案後，將檔案權限 group write mode 設為 enable
- 註3：watcher 啟動 inotifywait 監控目錄動態產生的檔案，一旦看到finished.parse則停止監控目錄，並產生finished.watch標記任務完成
- 註4：有finished.watch，無finished.parse`，表示目錄沒有正常被關閉

____
## 目錄結構

| 檔名 | 說明 |
|------|------|
| install.sh | 安裝環境的 script |
| scan.conf | scan.sh or scan.daemon 的 config file |
| scan.sh | 負責掃描 /datas 的程式 |
| watch.conf | watch.sh 的 config file |
| watch.sh | the shell script monitoring events of creating files in a directory| fsync.conf | fsync.sh 的 config file |
| fsync.sh | the shell script to sync files to remote server |
| lsocket.conf | lsocket client/server 的 config file |
| lsocket.client    | lsocket client 檔案傳送端 |
| lsocket.server | lsocket server 檔案接收端 |
| utils.lua | lsocket client/server 公用程式 |
| test/ | 一堆測試 |

## 安裝環境

懶人安裝，執行 install.sh，或按照下面指示逐一安裝相關套件。

安裝 Lua
```
sudo apt-get install -y libreadline-dev
curl -R -O http://www.lua.org/ftp/lua-5.3.1.tar.gz
tar zxf lua-5.3.1.tar.gz
cd lua-5.3.1
make linux test
sudo make install
```

安裝 Luarocks
```
sudo apt-get install -y unzip
wget http://luarocks.org/releases/luarocks-2.2.2.tar.gz
tar zxpf luarocks-2.2.2.tar.gz
cd luarocks-2.2.2
./configure
sudo make bootstrap
```

安裝 LuaSocket
```
sudo luarocks install luasocket
```

安裝 LuaEvent
```
sudo apt-get install -y libevent-dev
sudo apt-get install -y git
git clone https://github.com/hugolu/luaevent
cd luaevent
make install
```

安裝 LuaFileSystem
```
sudo luarocks install luafilesystem
```

安裝 LuaPosix
```
sudo luarocks install luaposix
```

安裝 inotify-tools
```
sudo apt-get install -y inotify-tools
```

安裝 lsocket utils
```
sudo cp -f utils.lua /usr/local/share/lua/5.3/
```

## 測試

在 test/ 目錄中，

| 檔案 | 測試項目 | 註解 |
|------|----------|------|
| scan_p0w0.sh | 測試 dbtag裡面無 finished.parse、無 finished.watch 的狀況 | dbtag 沒被parser正常關閉，未完成同步傳輸 |
| scan_p0w1.sh | 測試 dbtag裡面無 finished.parse、有 finished.watch 的狀況 | dbtag 沒被parser正常關閉，已完成同步傳輸 |
| scan_p1w0.sh | 測試 dbtag裡面有 finished.parse、無 finished.watch 的狀況 | dbtag 有被parser正常關閉，未完成同步傳輸 |
| scan_p1w1.sh | 測試 dbtag裡面有 finished.parse、有 finished.watch 的狀況 | dbtag 有被parser正常關閉，已完成同步傳輸 |
| fsync_x0.sh | 測試 dbtag 裡面的檔案無設定 g+w | 檔案未被傳輸 |
| fsync_x1.sh | 測試 dbtag 裡面的檔案有設定 g+w | 檔案已被傳輸 |
| edx1.sh | 測試一台ED連接DRMS | |
| edx2.sh | 測試兩台ED連接DRMS | |

測試方式 (以 test/fsync_x0.sh 為例)，單步執行方式
```
$ test/fsync_x0.sh help
setup | execute | verify | cleanup
$ test/fsync_x0.sh setup
$ test/fsync_x0.sh execute
$ test/fsync_x0.sh verify
$ test/fsync_x0.sh cleanup
```

一次跑完所有步驟，執行方式
```
$ test/fsync_x0.sh
```
