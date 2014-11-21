(function(){
    /**
     * iLike.category.getCategory(productName)
     * @return single product category, Object
     * 
     * @return array of product categories, Array
     */
    var iCategory = {
        $categoryLi : $('#category'),
        $tagsUl : $('#style ul.styles'),
		styleChooseTip : "",
        CATEGORIES_URL : GLOBAL.URL.getUrlByDomain('/condor-1/rest/myrunway/categorystyles'),
        //CATEGORIES_URL : 'http://www.myrunway.com.cn:8080/categorystyles.json',
        productName : "",
        categories: [],

        /*
         * Initialize the category from the server.
         */
        init : function() {
        	this.cateLang = (sapLang.currentLang == "en") ? "nameEN" : "nameZH";
            this.styleChooseTip = "<span class='style-tip' iLikeLang='styleSelect'>" + sapLang.getText('styleSelect') + "</span>";
        	this.getCategoryFromServer();
        },
        
        getCategoryFromServer : function() {
        	var self = this;
        	
        	$.ajax({
                type: 'GET',
                url: this.CATEGORIES_URL,
                contentType: "application/json; charset=utf-8",
                success: function(data) {
			var new_data = JSON.parse(data);
                	self.categories = new_data;
                	self.initCategoryView();
                	if (self.productName) {
                    	self.fillCateByName(self.productName);
                	}
                    self.tagBarClick();
                    self.inputStyleClick();
                },
                error: function(e, a){
                	console.log(e, a);
                }
            });
        	
        },
        
        /*
         * Fill category and tag input by product name.
         */
        fillCateByName : function(productName) {
            for(var i = 0; i < this.categories.length; i++) {
            	var superCate = this.categories[i];
            	
            	if (superCate.subCategory) {
                    for(var j = 0; j < superCate.subCategory.length; j++) {
                        var subCate = superCate.subCategory[j];
                        
                        if(productName.indexOf(subCate[this.cateLang]) > -1) {
                            var cateTabClassStr = "#category_view ul.cate-menu li.category-" + superCate.defaultName.toLowerCase().replace(" ", "-"),
                            $cateTab = $(cateTabClassStr);
                            
                            $cateTab.click();
                            $("#category_view div.cate-content li.subCate-" + subCate.defaultName.replace(" ", "-")).click();
                            this.initTagView(subCate);
                            
                            return true;
                        }
                    }            	    
            	}
            }
        },
        
        /*
         * Initialize the category view.
         */
        initCategoryView : function() {
            var $menuTabs = $("#category_view ul.cate-menu li"),
            $cateContent = $("div.cate-content"),
            categories = this.categories,
            self = this;
            
            for (var i = 0; i < categories.length; i++) {
            	var cateObj = categories[i];

            	if (cateObj.subCategory) {
                    $menuTabs.each(function() {
                        var $tab = $(this);
                        if($tab.attr("pid").toLowerCase() == cateObj.defaultName.toLowerCase()) {
                            $tab.on("click", function(cateObj) {
                                return function() {
                                    var cateVal = cateObj.defaultName.toLowerCase(),
                                    activeClassStr = "category-" + cateVal.replace(" ", "-") + "-active",
                                    $this = $(this);
                                    
                                    if($("#style > i").hasClass("tag-bar-up")) {
                                        $("#style > i").removeClass("tag-bar-up");
                                        $("#tag_view").hide();
                                    }
                                    self.$tagsUl.html(self.styleChooseTip);
                                    
                                    self.$categoryLi.attr("categoryName", "");
                                    if($this.hasClass(activeClassStr)) {
                                        $this.removeClass(activeClassStr).removeClass("selected");
                                        $cateContent.hide();
                                        self.removeSubCateHighlight();
                                    }else {
                                        self.removeSuperCateHighlight();
                                        $this.addClass(activeClassStr).addClass("selected");
                                        var subCateArray = cateObj.subCategory;
                                        $cateContent.empty();
                                        
                                        for (var i = 0; i < subCateArray.length; i++) {
                                            var subCateObj = subCateArray[i];
                                            var $item = self.initCateDom(subCateObj);
                                            $cateContent.append($item);
                                            
                                            $item.on("click", function (cateObj, subCateObj, $tab) {
                                                return function() {
                                                    self.$categoryLi.attr("categoryName", "");
                                                    if($(this).hasClass("highlight")) {
                                                        $(this).removeClass("highlight");
                                                    }else {
                                                        self.$categoryLi.attr('categoryName', subCateObj.defaultName);
                                                        self.removeSubCateHighlight();
                                                        $(this).addClass("highlight");
                                                        self.initTagView(subCateObj);
                                                    }
                                                };
                                            }(cateObj, subCateObj, $this));
                                        }
                                        
                                        $cateContent.show();
                                    }
                                };
                            }(cateObj));
                            return;
                        }
                    });
            	}
        	}
        },

        /*
         * Initialize category tab Dom
         */
        initCateDom : function(cateObj) {
            var tab = $("<li></li>");
            
            tab.text(cateObj[this.cateLang]);
            tab.attr("pid", cateObj.defaultName);
        	tab.addClass("subCate-" + cateObj.defaultName.replace(" ", "-"));
            
            return tab;
        },

        removeSuperCateHighlight : function() {
            var $superCateLi = $("#category_view ul.cate-menu li.selected");
            if($superCateLi.size()) {
                activeClassStr = "category-" + $superCateLi.attr("pid").toLowerCase().replace(" ", "-") + "-active";
                $superCateLi.removeClass(activeClassStr).removeClass("selected");
            }
        },
        
        removeSubCateHighlight : function() {
            var $subCateLi = $("#category_view div.cate-content li.highlight");
            if($subCateLi.size()) {
                $subCateLi.removeClass("highlight");
            }
        },
        
        initTagView : function(subCate) {
            this.$tagsUl.html(this.styleChooseTip);
            
            if (0 == $('#tag_view').length) {
                var tagViewHtml = '<div id="tag_view">'
                        + '<div class="line"></div>'
                        + '<ul class="tag-menu"></ul>'
                    + '</div>';
                this.$tagsUl.parent().append(tagViewHtml);
            }
            
            var $tagMenu = $('#tag_view ul.tag-menu');
            $tagMenu.empty();
            this.renderStyleItems($tagMenu, subCate);
                
        },
        
        // $tagMenu: Jquery object where style items place
        renderStyleItems : function($tagMenu, subCate) {
        	var tags = subCate.hotStyle,
                self = this;
        	
            for (var i = 0, l = tags.length; i < l; i++) {
                var $tagItem = $('<li class="style-item"></li>');
                $tagItem.addClass("tag-" + tags[i].replace(" ", "-"));
                $tagItem.text(tags[i]);
                //$tagItem.append('<span class="delete-icon"></span>');
                $tagMenu.append($tagItem);
            }
            
            $tagMenu.undelegate('li.style-item', 'click').delegate('li.style-item', 'click', function(e) {
                e.stopPropagation();
                self.inputStyleBlur();
                var $this = $(this);
                sap.messageBox.hideMsg();
                
                if ($this.hasClass('selected')) {
                    //to do nothing
                } else {
                    if(self.$tagsUl.find("li").size() < 6) {
                        var $tag = $("<li><span>" + $this.text() + "</span><i class='delete-icon'></i></li>");
                        self.$tagsUl.append($tag);
                        $this.addClass('selected');
                    }else {
                        sap.messageBox.showMsg(sapLang.getText('maxStyleNumTip'));
                    }
                }
            });
            
            self.$tagsUl.undelegate('i.delete-icon', 'click').delegate('i.delete-icon', 'click', function(e) {
                e.stopPropagation();
                var tagName = $(this).parent().text();
                $(this).parent().remove();
                sap.messageBox.hideMsg();
                $tagMenu.find("li.tag-" + tagName.replace(" ", "-")).removeClass("selected");
            });
            
            var addBtn = $('<li class="add-btn"></li>'),
                addIcon = $('<span class="add-icon">+</span>'),
                minusIcon = $('<span class="add-icon">-</span>'),
                addInput = $('<input class="add-input" type="" />');
            minusIcon.hide();
            addBtn.append(addIcon).append(addInput);
            addBtn.append(minusIcon);
            $tagMenu.append(addBtn);
            
            addBtn.on('click', function(e) {
                e.stopPropagation();
            });
            
            addIcon.on('click', function(e) {
                e.stopPropagation();
                var moreTags = subCate.style;
                
                for (var i = 0; i < moreTags.length; i++) {
                    var $tagItem = $('<li class="style-item"></li>');
                    $tagItem.text(moreTags[i]);
                    $tagItem.insertBefore(addBtn);
                    addIcon.hide();
                    minusIcon.show();
                }
            });
            
            minusIcon.on('click', function(e) {
                e.stopPropagation();
                var moreTags = subCate.style;
                
                for (var i = 0; i < moreTags.length; i++) {
                    var removeItem = addBtn.prev();
                    removeItem.remove();
                    
                    minusIcon.hide();
                    addIcon.show();
                }
            });
        },
        
        tagBarClick : function() {
        	var self = this;
            $("#style > i").on("click", function(e) {
                e.stopPropagation();
                if (self.$categoryLi.attr("categoryName")) {
                    if($(this).hasClass("tag-bar-up")) {
                        if(!self.$tagsUl.find("li").size()){
                            self.$tagsUl.html(self.styleChooseTip);
                        }
                        $(this).removeClass("tag-bar-up");
                        $("#tag_view").hide();
                    }else {
                        if(!self.$tagsUl.find("li").size()){
                            self.$tagsUl.empty();
                        }
                        $(this).addClass("tag-bar-up");
                        $("#tag_view").show();
                    }
                    
                    self.inputStyleBlur();
                } else {
                    sap.messageBox.showMsg(sapLang.getText('selectCategoryTip'));
                }
            });
        },
        
        inputStyleClick : function() {
            var self = this;
            self.$tagsUl.mousedown(function(e) {
                e.stopPropagation();
            });
            
            self.$tagsUl.on('click', function(e) {
                e.stopPropagation();
                if (!self.$categoryLi.attr("categoryName")) {
                    sap.messageBox.showMsg(sapLang.getText('selectCategoryTip'));
                    return;
                }
                
                var size = $(this).find("li").size();
                if(size == 0){
                    $(this).empty();
                }else if(size == 6){
                    sap.messageBox.showMsg(sapLang.getText('maxStyleNumTip'));
                    return;
                }
                
                if($(this).find("li.inputStyle").size() == 0) {
                    var $inputStyle = $('<li class="inputStyle"><input type="text" /></li>');
                    
                    $inputStyle.find('input').on('keypress', function(e) {
                        e.stopPropagation();
                        
                        if(e.keyCode == 13) {
                            e.preventDefault();
                            self.inputStyleBlur();
                        }
                        
                        var inputVal = $(this).val();
                        if(inputVal.length >= 20) {
                            e.preventDefault();
                            sap.messageBox.showMsg(sapLang.getText('styleMaxLengthTip'));
                        }else {
                            sap.messageBox.hideMsg();
                        }
                    });
                    
                    $(this).append($inputStyle);
                }
                
                $(this).find("li.inputStyle > input").focus();
            });
        },
        
        inputStyleBlur : function() {
            var self = this;
            var $inputNode = self.$tagsUl.find("li.inputStyle > input");
            if($inputNode.size()) {
                var inputVal = $inputNode.val().trim();
                $inputNode.parent().remove();
                
                if(inputVal) {
                    var existFlag = false;
                    self.$tagsUl.find("li").each(function() {
                        if(inputVal == $(this).find('span').text().trim()) {
                            existFlag = true;
                            return false;
                        }
                    });
                    
                    if(!existFlag) {
                        var $tag = $("<li><span>" + inputVal + "</span><i class='delete-icon'></i></li>");
                        self.$tagsUl.append($tag);
                    }
                }else {
                    if(!$("#style > i").hasClass("tag-bar-up") && !self.$tagsUl.find("li").size()){
                        self.$tagsUl.html(self.styleChooseTip);
                    }
                }
            }
        }
    };
    
    if(typeof(window.iLike) == 'undefined') {
        window.iLike = {};
    }
    iLike.category = iCategory;
    iLike.category.init();
    
    $('body').on('click', function() {
        iLike.category.inputStyleBlur();
        if($("#style > i").hasClass("tag-bar-up")) {
            if(!iLike.category.$tagsUl.find("li").size()){
                iLike.category.$tagsUl.html(self.styleChooseTip);
            }
            $("#style > i").removeClass("tag-bar-up");
            $("#tag_view").hide();
        }
    });
})();
