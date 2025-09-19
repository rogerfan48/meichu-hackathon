# App Spec

## App Description

那個Flutter APP是要幫助失讀症患者與閱讀障礙群體增加生活中的便利性，設計失讀症患者友善使用者介面(以圖像為主)並串接強大的Gemini Pro，在上傳文章段落不易閱讀的pdf檔案或是含有較多複雜資訊的海報、圖片後，能夠產生出一張或多張清解說晰圖搭配語音說明。另外，還有設計記憶遊戲，根據使用者的問題內容，截取出部分內容作為記憶翻卡題目，正面為文字、背面為圖片或語音，讓使用者複習。
the user mention below is a Dyslexia

### Upload Page
- a big button with uplaod icon
- user can uplaod multiple files, including PDF and images, then it will be stored in the firebase storage
- after storing in firebase, get the corresponding url, and analyze and extract the content using google gemini pro
- when the content is get, make one or several images to the user with an audio, so that the user can understand the details more easier by the provided(returned) content
- files upload + image generation is called a session
 
### Card Page
* Upon entering, there should be a button that can enter another page, which show all the cards the user has, and in the page user can modify/create/delete cards
* Upon entering, there should be another button that can enter the game

### History Page
* Contain all the sessions the user issued

### Setting Page
* Control user login/logout
* Contain default speech rate setting

---

## App Structure

在這個Flutter APP中會使用 Firestore database, firebase storage, firebase cloud function, Vertex AI
軟體架構請使用 MVVM

### File Structure

檔案的規劃請盡量符合以下的規定，但如果你認為我們的規劃不合理，你也可以自行調整

* functions/
	* package.json
	* src/
		* config.ts
		* index.ts
		* type.ts
		* flow/

* lib/
	* main.dart
	* models/
	* pages/
	* repositories/
	* services/
	* theme/
	* view_models/
	* widgets/
	* enums/

### Database Structure

Following is the structure of the whole firestore database
* apps (collection)
	* hackathon (document)
		* users (collection)
			* `userDocID` (document)
				* userName: string
				* uid: string
				* defaultSpeechRate: number
				* cards: [card]
				* sessions: [session]

Following is the definition of `card`
* card (document)
	* sessionID: string
	* tags: [string]
	* imgURL: string
	* text: string

Following is the definition of `session`
* session (document)
	* sessionName: string
	* fileResources: [fileResource]
	* summary: string
	* imgExplanations: [imgExplanation]
	* cardIDs: [string]

Following is the definition of `fileResource`
* fileResource (document)
	* fileURL: string
	* fileSummary: string

Following is the definition of `imgExplanation`
* imgExplanation
	* imgURL: string
	* explanation: string

### Cloud Storage Structure
* `userDocID`
	* `sessionID`
		* Uploaded files

## General User Flow

* 先登入
	> Google Auth

* Hover 可以唸出這個按鈕的功能

* 上傳多個不限類型的檔案或文字
	> 1. 多個相關的檔案統整為一個 session 
	> 2. 使用者直接上傳文字的話就存成文字檔
	> 3. 要有相機功能
	
* 等待 app 生出語音總結、解釋圖片+圖片的語音解釋
	> 1. PDF: AI 直接總結，找出適合放到字卡的單字 (沒圖片的字卡)
	> 2. 具體物件的圖片: AI 辨識物件並放到字卡 (有圖片的字卡)
	> 3. 文字為主的圖片: OCR 辨識出文字再給 AI 總結，找出適合放到字卡的單字 (沒圖片的字卡)
	> 4. 從全部的附件生出文字總結，然後語音念出 (跟第5點平行處理)
	> 5. 透過文字總結產出數張解釋圖片，再藉由圖片+總結生成圖片的解釋，然後語音唸出
	> 6. 要怎麼把所有檔案做連結並給出合理的解讀?
		>> e.g. 使用者上傳了博物館中展品的照片、展品的敘述(圖片)、從博物館網站上複製下來關於這個展覽的文字
		>> Prompt engineering, RAG
	> 7. 所有總結的 API call 應該可以平行
	> 8. 可以看到這個 session 生成的字卡，也可以跳轉到對應的字卡頁面
	
* 不喜歡生成的解釋可以刪掉或叫 app 重新生成。也可以補上傳檔案並重新生成

* 歷史紀錄頁面可以查看上傳的檔案&圖片、語音解釋。也可以補上傳檔案並重新生成

* 字卡頁面可以瀏覽所有字卡、手動新增/刪除/修改字卡、挑選標籤並開始複習。由 session 產出的字卡要可以連結回歷史紀錄
	
* 設定頁面可以調整語速