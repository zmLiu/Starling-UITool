package
{
	import flash.filesystem.File;
	
	import lzm.starling.STLConstant;
	import lzm.starling.STLMainClass;
	import lzm.starling.ui.layout.LayoutUitl;
	
	import starling.utils.AssetManager;

	public class MainClass extends STLMainClass
	{
		private var asset:AssetManager;
		
		public function MainClass()
		{
			asset = new AssetManager(STLConstant.scale,STLConstant.useMipMaps);
			
//			var file:File = File.applicationDirectory;
//			asset.enqueue(file.resolvePath("asset/2x"));
			asset.enqueue("asset/2x/BigImages/background.png");
			asset.enqueue("asset/2x/icon_attack.png");
			asset.enqueue("asset/2x/icon_cup.png");
			asset.enqueue("asset/2x/icon_hp.png");
			asset.enqueue("asset/2x/layout.info");
			asset.enqueue("asset/2x/s9_test.png");
			asset.enqueue("asset/2x/square_blue.png");
			asset.enqueue("asset/2x/square_purple.png");
			asset.enqueue("asset/2x/square_red.png");
			asset.loadQueue(loading);
		}
		
		private function loading(ratio:Number):void{
			if(ratio == 1){
				var layoutUtil:LayoutUitl = new LayoutUitl(asset.getOther("layout"),asset);
				layoutUtil.buildLayout("test",this);
			}
		}
	}
}