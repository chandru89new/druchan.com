$(document).ready(function(){
    var dataSrc = "d.json";
    
    var app = new Vue({
        el: '#app',
        data() {
            return {
                work: '',
                skills: '',
                projects: '',
                misc: '',
                wip: ''
            };
        },
        beforeCreate: function(){
            var inst = this;
            $.ajax({
                url: dataSrc,
                method: 'GET',
                success: function(result){
                    for (i=0; i<result.length; i++){
                        type = result[i].type;
                        switch (type) {
                            case 'skills': 
                                inst.skills = result[i].content;
                                break;
                            case 'projects': 
                                inst.projects = result[i].content;
                                break;
                            case 'work': 
                                inst.work = result[i].content;
                                break;
                            case 'wip': 
                                inst.wip = result[i].content;
                                break;
                            default: 
                                inst.misc = result[i].content;
                                break;
                        }
                    }
                }
            });
        }
    });
});