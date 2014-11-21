//= require jquery
//= require ./m/jquery.cookie
//= require ./m/zepto
//= require ./m/app.min
//= require ./m/home
//= require ./m/dapei

// in your apps main method
try {
    // try to restore previous session
    App.restore();
} catch (err) {
    // else start from scratch
    App.load('home');
}