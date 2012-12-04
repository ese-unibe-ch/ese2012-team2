var Emporium = {

    tags : {
        initialize : function() {
            $.get("/tags/all", function(data) {
               $("#add_tag").autocomplete({
                   source : data.tags,
                   minLength : 0
               })
            });

            $("#add_tag_button").click(function() {
                var tag = $("#add_tag").val();
                if (tag) {
                  Emporium.tags.add(tag);
                  $("#add_tag").val("");
                }
            });

            this.initTags();
        },
        add : function(tag) {
            $("#tags").append("<input type='hidden' name='tags[]' value='" + tag + "'>");
            $("#tags").append("<span class='tag'>" + tag +"</span>");
            this.initTags();
        },
        initTags : function() {
            $("span.tag").hover(
                function() {
                    $(this).attr("data", $(this).html());
                    $(this).html("remove?");
                    $(this).css("cursor", "pointer");
                },
                function() {
                    $(this).html($(this).attr("data"));
                    $(this).css("cursor", "pointer");
                }
            );

            // click event removes both the visible tag and the hidden input fields
            $("span.tag").click( function(){
                $("input[value='" + $(this).attr("data").trim() + "']").remove();
                $(this).remove();
            });
        }
    },

    validate : {
        existing : function(input, source, message, messageEmpty) {
            var checkExisting = function(){
                var exists = false;
                $.ajax({
                    url: source,
                    type : "POST",
                    data : {
                        existing : $(input).val()
                    },
                    async : false,
                    success: function(data){
                        exists = data.exists;
                    }
                });
                return exists;
            };

            var validateExisting = function() {
                if ($(input).val() == "") {
                    Emporium.validate.helpers.addError(input, messageEmpty);
                } else {
                    if (checkExisting()) {
                        Emporium.validate.helpers.addError(input, message);
                    }   else {
                        Emporium.validate.helpers.removeError(input);
                    }
                }
            };

            $(input).keyup(function() {
                validateExisting();
             });
            validateExisting();
        },
        nonEmpty : function(input, mess) {
            var message = mess || 'Value must not be empty!';
            var validateNonEmpty = function() {
                if(!$(input).val()) {
                    Emporium.validate.helpers.addError(input, message);
                } else {
                    Emporium.validate.helpers.removeError(input);
                }
            };
            $(input).keyup(function(){
                validateNonEmpty();
            });
            validateNonEmpty();
        },

        helpers : {
            hintId : function(input) {
                return $(input).attr("id") + "_error_hint";
            },
            addError : function(input, message) {
                $(input).addClass("err");
                if ($("#" + this.hintId(input)).length <= 0) {
                    $(input).after("<span id='" + this.hintId(input) + "' class='hint'>" + message + "</span>")
                }
            },
            removeError : function(input) {
                $("#" + this.hintId(input)).remove();
                $(input).removeClass("err");
            }
        },
        password : function(input, message) {
            var validatePassword = function() {
                var pw = $(input).val();
                if (pw.length < 6) {
                    Emporium.validate.helpers.addError(input, message);
                } else if (pw.length > 9) {
                    Emporium.validate.helpers.removeError(input);
                } else {
                   var regex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s).*$/;
                   if ($(input).val().match(regex)) {
                      Emporium.validate.helpers.removeError(input);
                   } else {
                       Emporium.validate.helpers.addError(input, message);
                   }
                }

            };
            $(input).keyup(function(){
                validatePassword();
            });
            validatePassword();
        },
        passwordRepetition : function(password, repetition, mess) {
           var message = mess || "Password repetition must match";
           var validateRepetition = function() {
              if ($(password).val() == $(repetition).val()) {
                 Emporium.validate.helpers.removeError(repetition);
              } else {
                 Emporium.validate.helpers.addError(repetition, message);
              }
           };
           $(password).keyup(function(){
             validateRepetition();
           });
           $(repetition).keyup(function(){
             validateRepetition();
           });
           validateRepetition();
        },
        regex : function(input, regex, errorMessage, optional, missingErrorText) {
            var opt = optional && true;
            var missing = missingErrorText || "Must not be empty";
            var validateRegex = function() {
                var text = $(input).val();
                if (text) {
                    if ($(input).val().match(regex)) {
                        Emporium.validate.helpers.removeError(input);
                    } else {
                        Emporium.validate.helpers.addError(input, errorMessage);
                    }
                } else {
                    if (opt) {
                        Emporium.validate.helpers.removeError(input);
                    } else {
                        Emporium.validate.helpers.removeError(input);
                        Emporium.validate.helpers.addError(input, missing);
                    }
                }
            };
            $(input).keyup(function(){
                validateRegex();
            });
            validateRegex();
        },
        date : function(input, message) {
            // regex not perfect yet for months and days...
            this.regex(input, /[0-3][0-9]-[0-1][0-9]-[0-9]{4}$/, message);
        },
        time : function(input, message) {
            // regex not perfect for hours (should stop at 23..)
            this.regex(input, /^[0-2][0-9]:[0-5][0-9]$/, message);
        },
        number : function(input, message, optional, missingText) {
            this.regex(input, /^[0-9]+$/ , message, optional, missingText);
        }
    }
}