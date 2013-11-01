package 
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import lzm.starling.STLStarup;
	import preview.UIPreviewMain;

	[SWF(width=1000,height=1000)]
	public class UIPreview extends STLStarup
	{
		public function UIPreview()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			
			initStarling(UIPreviewMain,480,false,true);
			
		}
	}
}