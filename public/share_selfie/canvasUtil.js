// ;define(function (require, exports, module) {
	var canvasTools = {} ;

	canvasTools.drawTags = function (config) {
		var ctx, rate, i = 0; 
		if (config.canvas.getContext) {
			ctx = config.canvas.getContext('2d') ; 
		} else {
			console.error('你的浏览器不支持获取context') ;
			//break;
		}

		rate = this.getRate(config); 

		for (; i < config.data.tags.length; i++ ){
			var _tag = config.data.tags[i] ;
			this.drawCanva(ctx, _tag.point_x*rate, _tag.point_y*rate, _tag.name) ;
		}
	}

    /// 画一个canvas， 
    /// param: ctx:上下文绘图环境， x，y: x和y坐标， text:填充的文本
	canvasTools.drawCanva = function (ctx, x, y, text) {
		var white = '#fff' , black='rgba(18, 16, 15, 0.8)' , direct ;

        // 添加文字
		ctx.fillStyle = '#fff'
        ctx.font = '16px Calibri' ;
        // ctx.fillText(text, x + 30, y+5) ;
        // ctx.measureText(text) 获取文字添加到canvas之后的长度
        // 根据这个长度设置tag的长度
        length = ctx.measureText(text).width + 15;
        direct = (x + length + 30) > document.body.offsetWidth ? -1 : 1;
        if (direct > 0) ctx.fillText(text, x + 30, y + 5) ;
        else ctx.fillText(text, x - 20 - length , y+5) ;

        // 由于要根据text设置tag背景长度，所以tag背景要在文字之后添加，但是默认的背景会把
        // 文字层覆盖，设置globalCompositeOperation可以改变绘图的叠加方式，即这里要让文字层显示在上面
        ctx.globalCompositeOperation = 'destination-over';
		ctx.beginPath(); 
		ctx.moveTo(x, y) ; 
		ctx.arc(x, y, 5, 0,2*Math.PI, true) ; 
		ctx.fillStyle = white; 
		ctx.fill(); 
		ctx.closePath();

        // 添加标签背景
		ctx.beginPath() ; 
		ctx.moveTo(x+14*direct, y+2);
		ctx.quadraticCurveTo(x+12*direct, y, x+14*direct, y-2) ; //前两个参数控制点，后两个参数终点
		ctx.lineTo(x+25*direct, y-13) ; 
		ctx.quadraticCurveTo(x+27*direct, y-15, x+29*direct,y-15);
		ctx.lineTo(x+(length+25)*direct,y-15);
		ctx.arcTo(x+(length+27)*direct, y-15, x+(length+27)*direct, y-13, 2) ; // 前两个参数为圆心位置， 后两个参数终点， 最后一个参数半径

		ctx.lineTo(x+(length+27)*direct, y+13); 
		ctx.arcTo(x+(length+27)*direct, y+15, x+(length+25)*direct, y+15, 2); 
		ctx.lineTo(x+29*direct, y+15);
		ctx.quadraticCurveTo(x+27*direct, y+15, x+25*direct, y+13);
		ctx.fillStyle = black; 
		ctx.fill() ; 
		ctx.closePath();	
	}

	canvasTools.getRate = function (config) {
		var a = config.canvas.width , 
		    f = config.data.width ;
		return a / f; 
	}

	// module.exports = canvasTools ;
// })