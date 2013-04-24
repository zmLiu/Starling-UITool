package 
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.bit101.components.ScrollPane;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import export.PNGEncoder;
	import export.Util;
	
	/**
	 * ui布局导出器
	 * @author lzm
	 */	
	[SWF(width="800",height="600")]
	public class UIExport extends Sprite
	{
		
		private var exportDir:String = "";//图片输入路径
		private var exportTarget:String = "";//输出目标
		
		private var swfPathLabel:Label;//swf地址
		private var swfPathInput:InputText;
		private var chooseFileBtn:PushButton;
		
		private var exportPathLabel:Label;//输出地址
		private var exportPathInput:InputText;
		private var chooseExportPathBtn:PushButton;
		
		private var layoutFileNameLabel:Label;//layout.info的名字
		private var layoutFileNameInput:InputText;
		
		private var exportScale:int = 1;
		private var exportScaleLabel:Label;
		private var exportScaleNumStep:NumericStepper;
		
		private var uiExportBtn:PushButton;
		private var exportStateLable:Label;
		
		private var animationPanel:ScrollPane;
		
		private var showX:Number = 0;
		private var showY:Number = 0;
		
		private var appDomain:ApplicationDomain;//当前导出文档的信息
		private var clazzKeys:Vector.<String>;
		
		private var oldLayoutsData:Object;
		private var layoutFileName:String = "";//布局文件的名字
		private var exportImages:Dictionary;//需要输出的图片
		private var exportImagesData:Object;//需要输出的图片的信息，主要是记录注册点
		private var exportUiLayouts:Dictionary;//需要输出的ui布局
		private var exportUiLayoutsData:Object;//需要输出的ui布局信息
		
		private var tempContent:Sprite = new Sprite();
		
		public function UIExport()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			swfPathLabel = new Label(this,17,12,"swf地址：");
			swfPathInput = new InputText(this,72,12);
			swfPathInput.enabled = false;
			swfPathInput.height = 18;
			chooseFileBtn = new PushButton(this,180,10,"选择文件swf",onSelectSwfBtn);
			
			exportPathLabel = new Label(this,12,36,"输出地址：");
			exportPathInput = new InputText(this,72,36);
			exportPathInput.enabled = false;
			exportPathInput.height = 18;
			chooseExportPathBtn = new PushButton(this,180,34,"选择输出路径",onSelectExportPathBtn);
			
			layoutFileNameLabel = new Label(this,300,36,"布局文件名：");
			layoutFileNameInput = new InputText(this,372,36,"layout.info");
			layoutFileNameInput.height = 18;
			
			exportScaleLabel = new Label(this,12,60,"输出倍数：");
			exportScaleNumStep = new NumericStepper(this,72,60);
			exportScaleNumStep.minimum = 1;
			exportScaleNumStep.maximum = 10;
			exportScaleNumStep.value = 1;
			exportScaleNumStep.width = 60;
			
			uiExportBtn = new PushButton(this,12,84,"输出UI",onExportUiBtn);
			uiExportBtn.width = 100;
			
			exportStateLable = new Label(this,12,108,"等待输出");
			
			animationPanel = new ScrollPane(this,0,132);
			animationPanel.width = 800;
			animationPanel.height = 600 - 132;
			animationPanel.dragContent = false;
			animationPanel.autoHideScrollBar = true;
			addChild(animationPanel);
			
			tempContent.y = 800;
			addChild(tempContent);
		}
		
		private function onSelectSwfBtn(e:Event):void{
			var file:File = new File();
			file.browse([new FileFilter("Flash","*.swf")]);
			file.addEventListener(Event.SELECT,selectSwfOK);
		}
		private function selectSwfOK(e:Event):void{
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT,selectSwfOK);
			swfPathInput.text = file.url;
			layoutFileNameInput.text = getName(file.url) + ".info";
		}
		
		private function onSelectExportPathBtn(e:Event):void{
			var file:File = new File();
			file.browseForDirectory("输出路径");
			file.addEventListener(Event.SELECT,selectExportPathOK);
		}
		private function selectExportPathOK(e:Event):void{
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT,selectExportPathOK);
			exportPathInput.text = file.url + "/";
		}
		
		private function onExportUiBtn(e:MouseEvent):void{
			exportTarget = swfPathInput.text;
			exportDir = exportPathInput.text;
			layoutFileName = layoutFileNameInput.text;
			
			if(exportDir=="" || exportTarget=="") return;
			if(layoutFileName == null || layoutFileName == "") return;
			
			layoutFileName = layoutFileName.split(".")[0] + ".info"
			exportScale = exportScaleNumStep.value;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
			loader.load(new URLRequest(exportTarget));
			
			exportStateLable.text = "开始输出...";
			
			if(animationPanel.content.numChildren > 0){
				animationPanel.content.removeChildren(0,animationPanel.content.numChildren-1);
			}
			showX = 0;
			showY = 0;
		}
		
		private function loadComplete(e:Event):void{
			
			var file:File = new File(exportDir + layoutFileName);
			if(file.exists){
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				urlLoader.load(new URLRequest(exportDir + layoutFileName));
				urlLoader.addEventListener(Event.COMPLETE,loadOk);
				
				function loadOk(e:Event):void{
					urlLoader.removeEventListener(Event.COMPLETE,loadOk);
					oldLayoutsData = JSON.parse(urlLoader.data as String)["layout"];
					export();
				}
			}else{
				export();
			}
			
			function export():void{
				var loaderInfo:LoaderInfo = e.target as LoaderInfo;
				loaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
				
				appDomain = loaderInfo.content.loaderInfo.applicationDomain;
				clazzKeys = appDomain.getQualifiedDefinitionNames();
				
				parseExportTarget();
				exportImageToDisk();
				exportUiLayoutToDisk();
				
				loaderInfo.loader.unloadAndStop();
			}
		}
		
		/**
		 * 获取应该输入的图片和ui布局的对象
		 * */
		private function parseExportTarget():void{
			exportImages = new Dictionary();
			exportUiLayouts = new Dictionary();
			
			var clazz:Class;
			var mc:MovieClip;
			var length:int = clazzKeys.length;
			for (var i:int = 0; i < length; i++) {
				clazz = appDomain.getDefinition(clazzKeys[i]) as Class;
				mc = new clazz() as MovieClip;
				if(mc.currentLabels.length == 0){
					exportImages[getQualifiedClassName(mc)] = mc;
				}else{
					exportUiLayouts[getQualifiedClassName(mc)] = mc;
				}
			}
		}
		
		/**
		 * 输出图片到硬盘
		 * */
		private function exportImageToDisk():void{
			exportImagesData = new Object();
			
			var k:String;
			var mc:MovieClip;
			var rect:Rectangle;
			var bitmapdata:BitmapData;
			var imageData:ByteArray;
			var file:File;
			var fs:FileStream;
			var imgPostionData:Object;
			for (k in exportImages) {
				mc = exportImages[k];
				
				mc.scaleX = mc.scaleY = exportScale;
				addMcToTempContent(mc);
				
				rect = mc.getRect(tempContent);
				mc.x = -rect.x;
				mc.y = -rect.y;
				
				bitmapdata = new BitmapData(rect.width,rect.height,true,0);
				bitmapdata.draw(tempContent);
				
				imageData = PNGEncoder.encode(bitmapdata);
				if(rect.width > (150*exportScale) && rect.height > (150*exportScale)){
					file = new File(exportDir+"BigImages/"+k+".png");
				}else{
					file = new File(exportDir+k+".png");
				}
				
				fs = new FileStream();
				fs.open(file,FileMode.WRITE);
				fs.writeBytes(imageData);
				fs.close();
				
				mc.scaleX = mc.scaleY = 1;
				addMovieClip(mc);
				
				imgPostionData = {x:formatNumber(rect.x / exportScale) ,y:formatNumber(rect.y / exportScale)};
				if(k.indexOf("s9_") == 0){
					imgPostionData.s9gw = formatNumber(rect.width / exportScale * 0.25);//9宫格的x，y
				}
				exportImagesData[k] = imgPostionData;
			}
		}
		
		/**
		 * 输入出布局信息到硬盘
		 * */
		private function exportUiLayoutToDisk():void{
			exportUiLayoutsData = new Object();
			exportUiLayoutsData["images"] = exportImagesData;
			
			var layoutInfo:Object = new Object();
			
			var k:String;
			var mc:MovieClip;
			var length:int;
			
			var child:DisplayObject;
			var childName:String;
			var oldChildInfos:Array;
			var childInfos:Array;
			var childInfo:Object;
			var rect:Rectangle;
			
			for (k in exportUiLayouts) {
				mc = exportUiLayouts[k];
				addMcToTempContent(mc);
				
				length = mc.numChildren;
				if(oldLayoutsData) oldChildInfos = oldLayoutsData[k];
				childInfos = [];
				for (var i:int = 0; i < length; i++) {
					child = mc.getChildAt(i) as DisplayObject;
					childName = getQualifiedClassName(child);
					rect = child.getBounds(mc);
					childInfo = {
						cname:childName,
						x:formatNumber(child.x),
						y:formatNumber(child.y),
						w:formatNumber(child.width),
						h:formatNumber(child.height),
						sx:formatNumber(child.scaleX),
						sy:formatNumber(child.scaleY),
//						r:formatNumber(child.rotation),
						skx:MatrixUtil.getSkewX(child.transform.matrix),
						sky:MatrixUtil.getSkewY(child.transform.matrix)
					};
					
					if(child.name.indexOf("instance") == -1){
						childInfo.name = child.name;
					}
					
					if(childName.indexOf("s9_") == 0){//目标为9宫格
						childInfo.type = "s9image";
					}else if(childName.indexOf("batch_") == 0){//目标再程序解析中解析喂quadbatch
						childInfo.type = "batch";
					}else if(childName.indexOf("btn_") == 0){
						childInfo.type = "btn";
					}else if(childName == "flash.text::TextField"){
						childInfo.type = "text";
						childInfo.font = (child as TextField).defaultTextFormat.font;
						childInfo.color = (child as TextField).defaultTextFormat.color;
						childInfo.size = (child as TextField).defaultTextFormat.size;
						childInfo.align = (child as TextField).defaultTextFormat.align;
						childInfo.italic = (child as TextField).defaultTextFormat.italic;
						childInfo.bold = (child as TextField).defaultTextFormat.bold;
						childInfo.text = (child as TextField).text;
					}else if(exportUiLayouts[childName] != null){//目标为子布局
						childInfo.type = "sprite";
					}else{
						childInfo.type = "image";
					}
					childInfos[i] = childInfo;
					if(oldChildInfos && oldChildInfos.length > i){
						if(!childInfo.name
							&& oldChildInfos[i].name
							&& childInfo.cname == oldChildInfos[i].cname
							&& childInfo.type == oldChildInfos[i].type
						){
							childInfo.name = oldChildInfos[i].name;
						}
					}
				}
				layoutInfo[k] = childInfos;
			}
			exportUiLayoutsData["layout"] = layoutInfo;
			
			var file:File = new File(exportDir+layoutFileName);
			var fs:FileStream = new FileStream();
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(JSON.stringify(exportUiLayoutsData));
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		
		/**
		 * 那对象添加到临时容器
		 * */
		private function addMcToTempContent(display:DisplayObject):void{
			while(tempContent.numChildren > 0){
				tempContent.removeChildAt(0);
			}
			tempContent.addChild(display);
		}
		
		private function addMovieClip(mc:DisplayObject):void{
			tempContent.addChild(mc);
			var rect:Rectangle = Util.getPivotAndMaxRect(mc);
			mc.x = rect.x + showX;
			mc.y = rect.y + showY;
			
			showX += rect.width;
			if(showX > 800){
				showX = rect.width;
				showY = animationPanel.content.height;
				mc.x = rect.x;
				mc.y = rect.y + showY;
			}
			animationPanel.content.addChild(mc);
			animationPanel.update();
		}
		
		/**
		 * 保留两位小数
		 */		
		private function formatNumber(_num:Number):Number{
			return Math.round(_num * (0 || 100)) / 100;
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