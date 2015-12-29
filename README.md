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
