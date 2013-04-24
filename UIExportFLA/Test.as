package
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.text.TextField;
	
	import fl.motion.MatrixTransformer;
	import fl.motion.MatrixTransformer3D;

	public class Test extends MovieClip
	{
		private var _tt:TextField;
		private var _shape:Shape;
		public function Test()
		{
			_tt = (getChildByName("ttt") as TextField);
			_shape = getChildAt(0) as Shape;
			
			_tt.text = (MatrixTransformer.getRotation(_shape.transform.matrix) + "\n");
			_tt.appendText(MatrixTransformer.getRotationRadians(_shape.transform.matrix) + "\n");
			_tt.appendText(MatrixTransformer.getScaleX(_shape.transform.matrix) + "\n");
			_tt.appendText(MatrixTransformer.getScaleY(_shape.transform.matrix) + "\n");
			
			_tt.appendText(MatrixTransformer.getSkewX(_shape.transform.matrix) + "\n");
			_tt.appendText(MatrixTransformer.getSkewXRadians(_shape.transform.matrix) + "\n");
			_tt.appendText(MatrixTransformer.getSkewY(_shape.transform.matrix) + "\n");
			_tt.appendText(MatrixTransformer.getSkewYRadians(_shape.transform.matrix) + "\n");
		}
	}
}