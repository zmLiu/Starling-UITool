package preview
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import lzm.starling.STLConstant;
	import lzm.starling.STLMainClass;
	import lzm.starling.gestures.Gestures;
	import lzm.starling.gestures.TapGestures;
	import lzm.starling.ui.layout.LayoutUitl;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.utils.AssetManager;

	public class UIPreviewMain extends STLMainClass
	{
		private var nativeStage:Stage;
		
		private var layoutFileName:String = "";//布局文件的名字
		private var filesPath:String = "";//文件地址
		
		private var layoutFileNameLabel:Label;//布局文件的名字
		private var layoutFileNameInput:InputText;
		
		private var filePathLabel:Label;//文件地址
		private var filePathInput:InputText;
		private var filePathBtn:PushButton;
		
		private var loadBtn:PushButton;
		private var saveBtn:PushButton;
		
		private var layoutComboBox:ComboBox;
		
		private var asset:AssetManager;
		private var layoutUtil:LayoutUitl;
		private var layoutObject:Object;
		
		private var previewSprite:Sprite;
		private var currentPreviewLayoutKey:String;//当前再预览的布局名称
		private var currentPreviewArray:Array;//当前再预览的布局类容
		private var currentSelectSymbol:DisplayObject;//当前选中的原件
		private var currentSelectSymbolIndex:int;//当前选中原件的索引
		private var currentSelectSymbolFilter:BlurFilter = BlurFilter.createGlow(0x00ffff,1,3);
		
		private var currentSelectSymbolNameLabel:Label;//为当前选择的原件
		private var currentSelectSymbolNameInput:InputText;
		private var currentSelectSymbolNameBtn:PushButton;
		private var currentSelectSymbolTypeLabel:Label;//为当前选择的原件的类型
		private var currentSelectSymbolClassNameLabel:Label;//为当前选择的原件的类名
		
		public function UIPreviewMain()
		{
			nativeStage = STLConstant.nativeStage;
			
			layoutFileNameLabel = new Label(nativeStage,12,12,"布局文件名：");
			layoutFileNameInput = new InputText(nativeStage,82,12,"layout.info");
			layoutFileNameInput.height = 18;
			
			filePathLabel = new Label(nativeStage,12,36,"资源地址：");
			filePathInput = new InputText(nativeStage,82,36);
			filePathInput.height = 18;
			filePathInput.enabled = false;
			filePathBtn = new PushButton(nativeStage,190,34,"选择资源地址",onSelectExportPathBtn);
			
			currentSelectSymbolTypeLabel = new Label(nativeStage,420,12,"原件类型:");
			currentSelectSymbolClassNameLabel = new Label(nativeStage,420,36,"原件Class:");
			currentSelectSymbolNameLabel = new Label(nativeStage,420,60,"为当前选择的原件命名：");
			currentSelectSymbolNameInput = new InputText(nativeStage,550,60);
			currentSelectSymbolNameInput.height = 18;
			currentSelectSymbolNameBtn = new PushButton(nativeStage,660,58,"确定",onCurrentSelectSymbolNameBtn);
			currentSelectSymbolTypeLabel.visible = currentSelectSymbolClassNameLabel.visible = currentSelectSymbolNameLabel.visible = currentSelectSymbolNameInput.visible = currentSelectSymbolNameBtn.visible = false;
			
			loadBtn = new PushButton(nativeStage,190,58,"开始加载",function(e:Event):void{
				if(layoutFileNameInput.text == null || layoutFileNameInput.text == "" || filesPath == ""){
					return;
				}
				
				var mashShape:Shape = new Shape();
				mashShape.graphics.beginFill(0x000000,0.5);
				mashShape.graphics.drawRect(0,0,nativeStage.stageWidth,nativeStage.stageHeight);
				mashShape.graphics.endFill();
				nativeStage.addChild(mashShape);
				
				var ratioLabel:Label = new Label(nativeStage);
				ratioLabel.textField.textColor = 0xffffff;
				
				loadBtn.enabled = false;
				
				layoutFileName = getName(layoutFileNameInput.text);
				
				asset = new AssetManager(STLConstant.scale);
				asset.enqueue(new File(filesPath));
				asset.loadQueue(function(ratio:Number):void{
					ratioLabel.text = int(ratio * 100) + "%";
					ratioLabel.x = (nativeStage.stageWidth - ratioLabel.width)/2;
					ratioLabel.y = (nativeStage.stageHeight - ratioLabel.height)/2;
					
					if(ratio == 1){
						layoutObject = asset.getOther(layoutFileName)["layout"];
						layoutUtil = new LayoutUitl(asset.getOther(layoutFileName),asset);
						
						
						var items:Array = [];
						for(var k:String in layoutObject){
							items.push(k);
						}
						items.sort();
						layoutComboBox = new ComboBox(nativeStage,12,58,"",items);
						layoutComboBox.width = 170;
						layoutComboBox.numVisibleItems = items.length > 20 ? 20 : items.length;
						layoutComboBox.addEventListener(Event.SELECT,onLayoutComboBoxSelect);
						
						saveBtn = new PushButton(nativeStage,300,58,"保存",onSaveBtn);
						
						nativeStage.removeChild(ratioLabel);
						nativeStage.removeChild(mashShape);
					}
				});
			});
			
			this.y = 52;
			previewSprite = new Sprite();
			addChild(previewSprite);
		}
		
		private function onSelectExportPathBtn(e:Event):void{
			var file:File = new File();
			file.browseForDirectory("文件路径");
			file.addEventListener(Event.SELECT,selectExportPathOK);
		}
		private function selectExportPathOK(e:Event):void{
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT,selectExportPathOK);
			filesPath = filePathInput.text = file.url + "/";
		}
		
		private function onLayoutComboBoxSelect(e:Event):void{
			if(currentSelectSymbol){
				currentSelectSymbol.filter = null;
			}
			currentSelectSymbol = null;
			currentSelectSymbolTypeLabel.visible = currentSelectSymbolClassNameLabel.visible = currentSelectSymbolNameLabel.visible = currentSelectSymbolNameInput.visible = currentSelectSymbolNameBtn.visible = false;
			
			while(previewSprite.numChildren > 0){
				previewSprite.getChildAt(0).removeFromParent(true);
			}
			
			currentPreviewLayoutKey = layoutComboBox.selectedItem as String;
			currentPreviewArray = layoutObject[currentPreviewLayoutKey];
			
			layoutUtil.buildLayout(currentPreviewLayoutKey,previewSprite);
			
			var tap:Gestures;
			for(var i:int = 0 ; i < previewSprite.numChildren ; i++){
				previewSprite.getChildAt(i).touchable = true;
				tap = new TapGestures(previewSprite.getChildAt(i),tapSymbol(previewSprite.getChildAt(i)));
			}
		}
		
		/**
		 * 选择单个原件
		 */		
		private function tapSymbol(display:DisplayObject):Function{
			return function():void{
				if(currentSelectSymbol){
					currentSelectSymbol.filter = null;
				}
				currentSelectSymbol = display;
				currentSelectSymbolIndex = currentSelectSymbol.parent.getChildIndex(currentSelectSymbol);
				display.filter = currentSelectSymbolFilter;
				
				currentSelectSymbolTypeLabel.visible = currentSelectSymbolClassNameLabel.visible = currentSelectSymbolNameLabel.visible = currentSelectSymbolNameInput.visible = currentSelectSymbolNameBtn.visible = true;
				if(currentPreviewArray[currentSelectSymbolIndex].name){
					currentSelectSymbolNameInput.text = currentPreviewArray[currentSelectSymbolIndex].name;
				}else{
					currentSelectSymbolNameInput.text = "";
				}
				currentSelectSymbolClassNameLabel.text = "原件Class：" + currentPreviewArray[currentSelectSymbolIndex].cname;
				currentSelectSymbolTypeLabel.text = "原件类型：" + currentPreviewArray[currentSelectSymbolIndex].type;
			}
		}
		
		private function onSaveBtn(e:Event):void{
			var exportLayoutObject:Object = {images:layoutUtil.imagesData,layout:layoutObject};
			var file:File = new File(filesPath+layoutFileName+".info");
			var fs:FileStream = new FileStream();
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(JSON.stringify(exportLayoutObject));
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		
		private function onCurrentSelectSymbolNameBtn(e:Event):void{
			currentPreviewArray[currentSelectSymbolIndex].name = currentSelectSymbolNameInput.text;
			layoutObject[currentPreviewLayoutKey] = currentPreviewArray;
		}
		
		private function getName(rawAsset:Object):String
		{
			var matches:Array;
			var name:String;
			
			if (rawAsset is String || rawAsset is FileReference)
			{
				name = rawAsset is String ? rawAsset as String : (rawAsset as FileReference).name;
				name = name.replace(/%20/g, " "); // URLs use '%20' for spaces
				matches = /(.*[\\\/])?([\w\s\-]+)(\.[\w]{1,4})?/.exec(name);
				
				if (matches && matches.length == 4) return matches[2];
				else throw new ArgumentError("Could not extract name from String '" + rawAsset + "'");
			}
			else
			{
				name = getQualifiedClassName(rawAsset);
				throw new ArgumentError("Cannot extract names for objects of type '" + name + "'");
			}
		}
	}
}