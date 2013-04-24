package export
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	/**
	 *  
	 * @author lzm
	 * 
	 */	
	public class Util
	{
		
		public static function getMoviclipInfo(mc:MovieClip):Object{
			var rect:Rectangle = getPivotAndMaxRect(mc);
			var combinantion:Object = getMovieCombinantion(mc);
			var framesInfo:Object = getMovieFramesInfo(mc);
			var pivot:Array = [rect.x,rect.y];
			return {combinantion:combinantion,framesInfo:framesInfo,pivot:pivot};
		}

		/**
		 * 获取动画的所有组成部分
		 */		
		private static function getMovieCombinantion(mc:MovieClip):Object{
			var combination:Object = new Object;
			var keys:Array = [];
			var keyIndex:int = 0;
			
			var totalFrames:int = mc.totalFrames;
			var comNumber:int;
			var comName:String;
			var bitmapdata:BitmapData;
			var pivot:Array;
			var rect:Rectangle;
			var child:DisplayObject;
			for(var i:int = 1; i <= totalFrames ; i++){
				mc.gotoAndStop(i);
				comNumber = mc.numChildren;
				for(var j:int=0;j<comNumber;j++){
					child = mc.getChildAt(j);
					comName = child.name;
					if(keys.indexOf(comName) == -1){
						
						rect = child.getBounds(child);
						pivot = [-rect.x,-rect.y];
						var obj:Object = new Object();
						obj["pivot"] = pivot;
						
						keys[keyIndex] = comName;
						combination[comName] = obj;
						keyIndex++;
					}
				}
			}
			return combination;
		}
		
		private static function getMovieFramesInfo(mc:MovieClip):Object{
			var labels:Array = mc.currentLabels;
			var labelsLength:int = labels.length;
			var currentLabel:FrameLabel;
			var totalFrames:int = mc.totalFrames;
			var currentFrame:int = 0;
			
			var framesObject:Object = new Object();
			
			for(var i:int=0;i<labelsLength;i++){
				currentLabel = labels[i];
				currentFrame = currentLabel.frame;
				mc.gotoAndStop(currentLabel.name);
				
				var labelFramesObject:Array = [];
				var index:int = 0;
				
				while(mc.currentLabel == currentLabel.name && currentFrame <= totalFrames){
					var childNumber:int = mc.numChildren;
					var child:DisplayObject;
					var data:Array = [];
					for(var j:int=0;j<childNumber;j++){
						child = mc.getChildAt(j);
						data[j] = [child.name,child.x,child.y,int(child.rotation)];
					}
					labelFramesObject[index] = data;
					index ++;
					
					currentFrame ++;
					mc.gotoAndStop(currentFrame);
				}
				
				framesObject[currentLabel.name] = labelFramesObject;
			}
			return framesObject;
		}
		
		public static function getPivotAndMaxRect(mc:DisplayObject):Rectangle{
			var pivotx:Number = -1000000;
			var pivoty:Number = -1000000;
			var maxW:Number = -1000000;
			var maxH:Number = -1000000;
			var rect:Rectangle;
			
			var isMc:Boolean = mc is MovieClip;
			var totalFrames:int = isMc?(mc as MovieClip).totalFrames:1;
			
			for(var i:int = 1; i <= totalFrames ; i++){
				if(isMc) (mc as MovieClip).gotoAndStop(i);
				
				rect = mc.getBounds(mc);
				
				if(pivotx == -1000000 || pivoty == -1000000){
					pivotx = rect.x;
					pivoty = rect.y;
				}else{
					pivotx = rect.x < pivotx ? rect.x : pivotx;
					pivoty = rect.y < pivoty ? rect.y : pivoty;
				}
				
				if(maxH == -1000000 || maxW == -1000000){
					maxH = rect.height;
					maxW = rect.width;
				}else{
					maxW = (rect.width + rect.x - pivotx) < maxW ? maxW : (rect.width + rect.x - pivotx);
					maxH = (rect.height + rect.y - pivoty) < maxH ? maxH : (rect.height + rect.y - pivoty);
				}
			}
			return new Rectangle(-pivotx,-pivoty,maxW,maxH);
		}
		
		/** Converts an angle from degrees into radians. */
		public static function deg2rad(deg:Number):Number
		{
			return deg / 180.0 * Math.PI;   
		}
		
		/** Converts an angle from radions into degrees. */
		public static function rad2deg(rad:Number):Number
		{
			return rad / Math.PI * 180.0;            
		}
	}
}