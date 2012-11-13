function changeDate(i, year){
    var e = document.getElementById('day');
    while(e.length>0)
        e.remove(e.length-1);
    var j=-1;
    if(i=="na")
        k=0;
    else if(i==2)
        k=28;
    else if(i==4||i==6||i==9||i==11)
        k=30;
    else
        k=31;
    while(j++<k){
        var s=document.createElement('option');
        var e=document.getElementById('day');
        if(j==0){
            s.text="Day";
            s.value="na";
            try{
                e.add(s,null);}
            catch(ex){
                e.add(s);}}
        else{
            s.text=j;
            s.value=j;
            try{
                e.add(s,null);}
            catch(ex){
                e.add(s);}}}
    var e = document.getElementById('year');
    while(e.length>0)
        e.remove(e.length-1);
    var y = year-1;
    while (y++<year + 10){
        var s = document.createElement('option');
        var e = document.getElementById('year');
        s.text=y;
        s.value=y;
        try{
            e.add(s,null);}
        catch(ex){
            e.add(s);}}
    var e = document.getElementById('hour');
    while(e.length>0)
        e.remove(e.length-1);
    var h = 0;
    while (h ++< 24){
        var s = document.createElement('option');
        var e = document.getElementById('hour');
        s.text=h;
        s.value=h;
        try{
            e.add(s,null);}
        catch(ex){
            e.add(s);}}
}

function validate_data(form, year, month, day, hour){
    if (form.name.value == ""){
        form.name.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please enter a name!";
        return false;
    }

    else if(form.minimal.value == ""){
        form.minimal.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please enter a minimal price";
        return false;
    }

    else if (form.increment.value == "" || form.increment.value == 0){
        form.increment.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please enter a positive increment!";
        return false;
    }

    else if (form.month.value == "na"){
        form.month.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please choose a month!";
        return false;
    }
    else if (form.day.value == "na"){
        form.day.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please choose a day!";
        return false;
    }

    else if (form.year.value == "na"){
        form.year.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please choose a year!";
        return false;
    }

    else if (form.hour.value == "na"){
        form.hour.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please choose an hour!";
        return false;
    }

    else if(form.year.value == year && form.month.value < month){
        form.month.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please choose a correct month for the due date!";
        return false;
    }
    else if(form.year.value == year && form.month.value == month && form.day.value < day){
        form.day.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please choose a correct day for the due date!";
        return false;
    }
    else if(form.year.value == year && form.month.value == month && form.day.value == day && form.hour.value <= hour){
        form.hour.style.backgroundColor = "rgba(245, 106, 82, 0.41)";
        document.getElementById('error_message').innerHTML = "Please choose a correct hour for the due date!";
        return false;
    }
    return true;
}