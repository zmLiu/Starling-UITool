package
{
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import fl.motion.MatrixTransformer;
	
	public class UIExportFLA extends Sprite
	{
		public function UIExportFLA()
		{
		}
		
		public static function getSkewX(matrix:Matrix):Number{
			return MatrixTransformer.getSkewX(matrix);
		}
		
		public static function getSkewY(matrix:Matrix):Number{
			return MatrixTransformer.getSkewY(matrix);
		}
		
	}
}